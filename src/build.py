#!/usr/bin/env python3

import argparse
import concurrent.futures
import hashlib
import json
import logging
import os
import shutil
import subprocess
import sys
import tarfile
import threading
import zipfile
import glob
import re
from pathlib import Path
from typing import Dict, List, Optional, Union, Set

# Third-party imports
import requests
import tenacity
import yaml

# Check for Python 3.12+
if sys.version_info < (3, 12):
    sys.exit("Python 3.12 or higher is required.")

class PackageBuilder:
    """Build system for personal setup packages with caching and parallel execution.

    Manages downloading, extracting, building, and installing packages from various
    sources (git repositories, archives, single files) with support for artifact
    caching and parallel builds.
    """

    def __init__(self, out_dir: str, parallel: int, retry: int, fast_fail: bool):
        """Initialize the package builder.

        Args:
            out_dir: Output directory for installed packages.
            parallel: Number of parallel build workers.
            retry: Number of download retry attempts.
            fast_fail: Whether to abort all builds on first failure.
        """
        self.out_dir = Path(out_dir).resolve()
        self.parallel = parallel
        self.retry = retry
        self.fast_fail = fast_fail

        # Directories
        self.build_dir = Path('build').resolve()
        self.temp_dir = self.build_dir / 'temp'
        self.log_dir = self.build_dir / 'logs'
        self.cache_dir = Path("~/.cache/personal-setup").expanduser().resolve()
        self.repo_cache_dir = self.cache_dir / 'repos'
        self.download_cache_dir = self.cache_dir / 'downloads'
        self.build_cache_dir = self.build_dir / 'cache'
        self.artifacts_cache_dir = self.build_cache_dir / 'artifacts'
        self.extracted_cache_dir = self.build_cache_dir / 'extracted'

        # Store log file path for subprocess redirection (Always enabled now)
        self.log_file_path = self.log_dir / 'build.log'

        # Threading synchronization
        self.registry_lock = threading.Lock()
        self.abort_event = threading.Event()

        # Git Repo locks to prevent concurrent git operations on the same bare repo
        self.repo_locks = {}
        self.repo_locks_mutex = threading.Lock()

        # Registry file
        self.registry_file = self.cache_dir / 'registry.json'

        # Initialize directories
        self._init_dirs()
        self._setup_logging()

        # Load registry into memory
        self.registry = self._load_registry()

        # Package names for cache cleaning
        self.package_names: Set[str] = set()

    def _init_dirs(self):
        """Create necessary directories."""
        for p in [self.out_dir, self.build_dir, self.temp_dir, self.log_dir, self.cache_dir,
                  self.repo_cache_dir, self.download_cache_dir, self.build_cache_dir,
                  self.artifacts_cache_dir, self.extracted_cache_dir]:
            p.mkdir(parents=True, exist_ok=True)

    def _setup_logging(self):
        """Configure logging to output to both stdout and build.log file."""
        handlers = [
            logging.StreamHandler(sys.stdout),
            logging.FileHandler(self.log_file_path)
        ]

        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=handlers
        )

    def _load_registry(self) -> Dict:
        """Load registry safely. Note: In a class init, we don't need the lock yet."""
        if self.registry_file.exists():
            try:
                with open(self.registry_file, 'r') as f:
                    return json.load(f)
            except json.JSONDecodeError:
                return {}
        return {}

    def _save_registry(self, lock: bool = True):
        """Thread-safe registry save."""
        if lock:
            with self.registry_lock:
                self._save_registry(lock=False)
        else:
            with open(self.registry_file, "w") as f:
                json.dump(self.registry, f, indent=2)

    def _update_registry_key(self, key: str, subkey: str, value):
        """Thread-safe helper to update a specific key."""
        with self.registry_lock:
            self.registry.setdefault(key, {})[subkey] = value
        # Save immediately to persist state
        self._save_registry()

    def _check_abort(self):
        """Check if the abort event is set and raise RuntimeError if so."""
        if self.abort_event.is_set():
            raise RuntimeError("Process aborted due to fast-fail.")

    def _get_repo_lock(self, repo_name: str) -> threading.Lock:
        """Get or create a lock for a specific repository."""
        with self.repo_locks_mutex:
            if repo_name not in self.repo_locks:
                self.repo_locks[repo_name] = threading.Lock()
            return self.repo_locks[repo_name]

    def _run_command(self, cmd: Union[str, List[str]], cwd: Path, env: Optional[Dict] = None, shell: bool = False):
        """
        Run a command with specific output handling:
        - stdout -> log file only
        - stderr -> terminal AND log file
        - Supports real-time unbuffered stderr to detect prompts
        """
        # Ensure python's logging buffers are flushed before subprocess writes
        for handler in logging.getLogger().handlers:
            handler.flush()

        logging.debug(f"Running command: {cmd}")

        with open(self.log_file_path, 'a') as f:
            # stdout goes directly to file (not terminal)
            # stderr goes to pipe so we can duplicate it.
            # Use text=False (binary) to avoid line buffering issues.
            proc = subprocess.Popen(
                cmd,
                cwd=str(cwd),
                env=env,
                stdout=f,
                stderr=subprocess.PIPE,
                stdin=subprocess.DEVNULL,
                shell=shell,
                text=False # Binary mode to prevent line buffering
            )

            # Read stderr efficiently but responsively
            if proc.stderr:
                fd = proc.stderr.fileno()
                while True:
                    try:
                        # Unlike file.read(n), this blocks only until *some* data is available (not full n),
                        # preventing hangs on prompts while being much faster than 1-byte reads.
                        chunk = os.read(fd, 4096)
                    except OSError:
                        break

                    if not chunk:
                        # EOF
                        break

                    # Write to log file (unfiltered)
                    try:
                        f.write(chunk.decode('utf-8', errors='replace'))
                        f.flush()
                    except Exception as e:
                        logging.warning(f"Failed to write to log file: {e}")

                    # Write to terminal
                    sys.stderr.buffer.write(chunk)
                    sys.stderr.buffer.flush()

            proc.wait()

            if proc.returncode != 0:
                raise subprocess.CalledProcessError(proc.returncode, cmd)

    # ==========================
    # Hash / Helpers
    # ==========================

    def compute_sha256(self, filepath: Path) -> str:
        """Compute SHA256 hash of a file.

        Args:
            filepath: Path to the file to hash.

        Returns:
            Hexadecimal string representation of the SHA256 hash.
        """
        hash_sha256 = hashlib.sha256()
        with open(filepath, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_sha256.update(chunk)
        return hash_sha256.hexdigest()

    def compute_dir_sha256(self, dir_path: Path) -> str:
        """Compute SHA256 hash of all files in a directory tree.

        Args:
            dir_path: Path to the directory to hash.

        Returns:
            Hexadecimal string representation of the combined SHA256 hash.
        """
        hash_sha = hashlib.sha256()
        for root, dirs, files in os.walk(dir_path):
            dirs.sort()
            for file in sorted(files):
                filepath = Path(root) / file
                with open(filepath, 'rb') as f:
                    for chunk in iter(lambda: f.read(4096), b""):
                        hash_sha.update(chunk)
        return hash_sha.hexdigest()

    def get_file_ext(self, url: str) -> str:
        """Extract file extension from a URL.

        Args:
            url: URL to parse for file extension.

        Returns:
            File extension string (e.g., 'tar.gz', 'zip') or empty string if unknown.
        """
        if (url_path := url.split('?')[0]).endswith(('.tar.gz', '.tgz')):
            return 'tar.gz'
        if url_path.endswith('.tar.xz'):
            return 'tar.xz'
        if url_path.endswith('.tar.bz2'):
            return 'tar.bz2'
        if url_path.endswith('.zip'):
            return 'zip'
        if url_path.endswith('.AppImage'):
            return 'AppImage'
        return ''

    def _force_copy(self, src, dst):
        """
        Helper to copy files, forcing overwrite if destination is read-only.
        Used as copy_function in shutil.copytree or self._recursive_copy.
        """
        try:
            # Preserve symlinks by setting follow_symlinks=False
            shutil.copy2(src, dst, follow_symlinks=False)
        except (PermissionError, FileExistsError):
            # Handle read-only destination file (e.g. 444 permission) or existing symlink
            if os.path.lexists(dst):
                try:
                    # Only chmod if it's NOT a link (chmod on link changes target on Linux)
                    if not os.path.islink(dst):
                        os.chmod(dst, 0o644) # Add write permission
                    os.unlink(dst)       # Remove existing file
                    shutil.copy2(src, dst, follow_symlinks=False)
                except OSError:
                    raise
            else:
                raise

    def _recursive_copy(self, src: Union[Path, str], dst: Union[Path, str],
                        symlinks=False, ignore=None, copy_function=shutil.copy2,
                        ignore_dangling_symlinks=False, dirs_exist_ok=False):
        """
        Robust recursive copy replacing shutil.copytree, handling:
        - Destination symlink existing error
        - Support both File and Dir inputs
        - All standard shutil.copytree arguments
        """
        src = os.fspath(src)
        dst = os.fspath(dst)

        # 1. Handle Symlinks (Source)
        # Check islink first because isdir follows symlinks by default
        if os.path.islink(src):
            if not symlinks:
                # If not preserving symlinks, follow them.
                # If it points to a dir, fall through to dir handling.
                # If file, fall through to file handling.
                if not os.path.isdir(src):
                    copy_function(src, dst)
                    return
                # If it is a dir and we follow symlinks, let it proceed to #3
            else:
                # Preserve link, forcing overwrite
                if os.path.lexists(dst):
                    if os.path.isdir(dst) and not os.path.islink(dst):
                        shutil.rmtree(dst)
                    else:
                        os.unlink(dst)

                # shutil.copy2 with follow_symlinks=False creates the link
                try:
                    shutil.copy2(src, dst, follow_symlinks=False)
                except FileExistsError:
                    pass
                return

        # 2. Handle Files (Non-dir, or symlink-to-file when symlinks=False)
        if not os.path.isdir(src):
            if os.path.exists(dst) and os.path.isdir(dst) and not os.path.islink(dst):
                shutil.rmtree(dst)
            copy_function(src, dst)
            return

        # 3. Handle Directories
        if not dirs_exist_ok and os.path.exists(dst):
            raise FileExistsError(f"Destination {dst} already exists")

        os.makedirs(dst, exist_ok=True)

        errors = []
        entries = []
        try:
            with os.scandir(src) as itr:
                entries = list(itr)
        except OSError as err:
            if ignore_dangling_symlinks:
                return
            errors.append((src, dst, str(err)))

        # Handle ignore callback
        if ignore is not None:
            ignored_names = ignore(src, [x.name for x in entries])
        else:
            ignored_names = set()

        for entry in entries:
            if entry.name in ignored_names:
                continue

            srcname = entry.path # Full path string
            dstname = os.path.join(dst, entry.name)

            try:
                # Recursive call handles files, dirs, and symlinks
                self._recursive_copy(srcname, dstname, symlinks, ignore, copy_function, ignore_dangling_symlinks, dirs_exist_ok)
            except Exception as err:
                errors.append((srcname, dstname, str(err)))

        if errors:
            raise shutil.Error(errors)

    # ==========================
    # Checksum Resolutions
    # ==========================

    @staticmethod
    def _canonical_sha256(value: Optional[str]) -> Optional[str]:
        """Return a normalized SHA256 value, rejecting ambiguous metadata."""
        if not isinstance(value, str):
            return None
        value = value.strip().lower()
        return value if re.fullmatch(r"[0-9a-f]{64}", value) else None

    @staticmethod
    def _canonical_git_commit(value: Optional[str]) -> Optional[str]:
        """Return a normalized full Git commit ID, rejecting abbreviated refs."""
        if not isinstance(value, str):
            return None
        value = value.strip().lower()
        return value if re.fullmatch(r"[0-9a-f]{40}", value) else None

    def _resolve_github_release_sha(self, url: str, filename: str) -> Optional[str]:
        """Fetch SHA256 from GitHub Release assets (checksum files)."""
        # Expected URL format: https://github.com/{owner}/{repo}/releases/download/{tag}/{filename}
        # API URL: https://api.github.com/repos/{owner}/{repo}/releases/tags/{tag}

        parts = url.split('/')
        if 'github.com' not in parts:
            return None

        try:
            # Parse URL
            idx_gh = parts.index('github.com')
            owner = parts[idx_gh + 1]
            repo = parts[idx_gh + 2]

            if 'download' in parts:
                idx_dl = parts.index('download')
                tag = parts[idx_dl + 1]
            else:
                return None # Not a standard release download URL

            api_url = f"https://api.github.com/repos/{owner}/{repo}/releases/tags/{tag}"
            headers = {"Accept": "application/vnd.github.v3+json"}

            # Use Token if available to avoid rate limits
            token = os.environ.get("GITHUB_TOKEN")
            if token:
                headers["Authorization"] = f"Bearer {token}"

            logging.info(f"Fetching release metadata for {owner}/{repo}@{tag}")
            resp = requests.get(api_url, headers=headers, timeout=10)
            resp.raise_for_status()
            data = resp.json()

            # 1. Check for digest in the asset object itself (GitHub automatic checksum)
            for asset in data.get('assets', []):
                if asset['name'] == filename:
                    digest = asset.get('digest')
                    if digest and isinstance(digest, str) and digest.startswith('sha256:'):
                        logging.info(f"Found GitHub asset digest for {filename}")
                        return self._canonical_sha256(digest[7:])

            # 2. Look for checksum files in assets
            checksum_candidates = ['checksums.txt', 'sha256sums.txt', 'sha256sums', 'sha256', f'{filename}.sha256']
            checksum_assets = [a for a in data.get('assets', []) if a['name'].lower() in checksum_candidates]

            for asset in checksum_assets:
                dl_url = asset['browser_download_url']
                logging.info(f"Checking checksum file: {asset['name']}")
                c_resp = requests.get(dl_url, timeout=10)
                c_resp.raise_for_status()
                content = c_resp.text

                # Parse lines: usually "HASH  FILENAME"
                for line in content.splitlines():
                    parts = line.strip().split()
                    if len(parts) >= 2:
                        hash_val = parts[0]
                        f_name = parts[1].lstrip('*') # Remove binary indicator

                        # Match filename (exact or relative)
                        if f_name == filename or f_name.endswith(f"/{filename}"):
                            # Verify hash format (64 hex chars for sha256)
                            canonical = self._canonical_sha256(hash_val)
                            if canonical:
                                return canonical

            return None

        except Exception as e:
            logging.warning(f"Failed to resolve GitHub checksum: {e}")
            return None

    def _resolve_http_sha(self, checksum_url: str, filename: str) -> Optional[str]:
        """Fetch SHA256 from a remote HTTP file."""
        try:
            logging.info(f"Fetching checksum from {checksum_url}")
            resp = requests.get(checksum_url, timeout=10)
            resp.raise_for_status()
            content = resp.text.strip()

            # Case 1: File contains ONLY the hash
            if len(content) == 64 and all(c in '0123456789abcdefABCDEF' for c in content):
                return self._canonical_sha256(content)

            # Case 2: Standard checksum file format
            for line in content.splitlines():
                parts = line.strip().split()
                if len(parts) >= 2:
                    hash_val = parts[0]
                    f_name = parts[1].lstrip('*')

                    if f_name == filename or f_name.endswith(f"/{filename}"):
                        canonical = self._canonical_sha256(hash_val)
                        if canonical:
                            return canonical

            # Case 3: A single-entry sidecar may use a filename different from
            # the download URL (for example, a provider's redirect endpoint).
            lines = [line for line in content.splitlines() if line.strip()]
            if len(lines) == 1:
                canonical = self._canonical_sha256(lines[0].split()[0])
                if canonical:
                    return canonical

        except Exception as e:
            logging.warning(f"Failed to fetch HTTP checksum: {e}")
        return None

    # ==========================
    # Git Logic
    # ==========================

    def resolve_tag(self, url: str, version: str) -> str:
        """Resolve a version string to an actual git tag name.

        Args:
            url: Git repository URL.
            version: Version string to resolve.

        Returns:
            Resolved tag name or the original version if not found.
        """
        key = f"{Path(url).stem.replace('.git', '')}-{version}"

        # Check cache first (thread-safe read)
        with self.registry_lock:
            cached_tag = self.registry.get(key, {}).get('tag')
        if cached_tag:
            return cached_tag

        # Git ls-remote
        try:
            result = subprocess.run(
                ['git', 'ls-remote', '--tags', url],
                stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                universal_newlines=True, check=True, timeout=30
            )
            for line in result.stdout.strip().split('\n'):
                if not line:
                    continue
                _, ref = line.split('\t')
                tag_name = ref.replace('refs/tags/', '')
                if tag_name.lstrip('v') == version.lstrip('v'):
                    self._update_registry_key(key, 'tag', tag_name)
                    return tag_name
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired):
            pass

        # Fallback
        self._update_registry_key(key, 'tag', version)
        return version

    def download_git(
        self,
        url: str,
        version: str,
        name: str,
        checksum_source: str,
        cache_key: Optional[str] = None,
        git_commit: Optional[str] = None,
    ) -> Path:
        """Download and checkout a git repository at a specific version.

        Args:
            url: Git repository URL.
            version: Version/tag/commit to checkout.
            name: Package name for workspace directory.
            checksum_source: Source for checksum validation (should be 'git-refs' or 'none').

        Returns:
            Path to the checked-out workspace directory.
        """
        expected_commit = self._canonical_git_commit(git_commit)
        if checksum_source != 'git-refs' or not expected_commit:
            raise ValueError(f"Git package {name} requires a full git_commit with checksum_source: git-refs")

        repo_name = Path(url).stem.replace('.git', '')
        repo_identity = hashlib.sha256(url.encode()).hexdigest()

        # Workspace directory where files are checked out
        clone_dir = self.build_dir / (cache_key or f"{name}-{version}")
        if clone_dir.exists():
            shutil.rmtree(clone_dir)

        # Bare Repo directory
        cache_repo_dir = self.repo_cache_dir / f"{repo_name}-{repo_identity}"

        # A full commit avoids mutable tags and does not require tag resolution.
        resolved_tag = expected_commit

        # Critical Section: Lock this specific repo to prevent concurrent fetch/prune
        with self._get_repo_lock(repo_name):
            if cache_repo_dir.exists():
                logging.info(f"Updating cached repo {repo_name}...")
                try:
                    # Fetch updates and prune dead worktrees
                    subprocess.run(['git', 'fetch', '--quiet', '--all', '--tags', '--force'], cwd=str(cache_repo_dir), check=True)
                    subprocess.run(['git', 'worktree', 'prune'], cwd=str(cache_repo_dir), check=True)
                except subprocess.CalledProcessError:
                    # If repo is corrupt, blow it away and re-clone
                    logging.warning(f"Repo {repo_name} appears corrupt, re-cloning...")
                    shutil.rmtree(cache_repo_dir)
                    subprocess.run(['git', 'clone', '--quiet', '--bare', url, str(cache_repo_dir)], check=True)
            else:
                logging.info(f"Cloning {repo_name}...")
                subprocess.run(['git', 'clone', '--quiet', '--bare', url, str(cache_repo_dir)], check=True)

            # Create the worktree
            logging.info(f"Checking out {repo_name} @ {resolved_tag}")
            subprocess.run(['git', 'worktree', 'add', '--quiet', '--force', str(clone_dir), resolved_tag], cwd=str(cache_repo_dir), check=True)

            actual_commit = subprocess.check_output(
                ['git', 'rev-parse', 'HEAD'], cwd=str(clone_dir), text=True
            ).strip().lower()
            if actual_commit != expected_commit:
                shutil.rmtree(clone_dir, ignore_errors=True)
                raise ValueError(f"Git commit mismatch for {name}: expected {expected_commit}, got {actual_commit}")

        return clone_dir

    # ==========================
    # File Download Logic
    # ==========================

    def download_file(self, url: str, version: str, name: str, checksum_source: str) -> Path:
        """Download a file from a URL with checksum verification.

        Args:
            url: URL to download from (may include {version} placeholder).
            version: Version string to substitute in URL.
            name: Package name for cache file naming.
            checksum_source: Source for checksum validation (URL, 'github-release', hash, or 'none').

        Returns:
            Path to the downloaded file in the cache directory.
        """
        actual_url = url.replace("{version}", version)
        url_identity = hashlib.sha256(actual_url.encode()).hexdigest()
        original_filename = Path(actual_url.split('?')[0]).name

        # Determine extension/filename
        filename = original_filename
        if name:
            ext = self.get_file_ext(actual_url)
            # If no extension in URL, try HEAD request
            if not ext:
                try:
                    head_resp = requests.head(actual_url, allow_redirects=False, timeout=10)
                    if 'content-type' in head_resp.headers:
                        ct = head_resp.headers['content-type'].lower()
                        if 'gzip' in ct or 'x-tar' in ct:
                            ext = 'tar.gz'
                        elif 'zip' in ct:
                            ext = 'zip'
                except requests.RequestException:
                    pass
            filename = f"{name}-{version}.{ext}" if ext else f"{name}-{version}"

        # Download directly to global cache
        cache_filepath = self.download_cache_dir / url_identity / filename
        cache_filepath.parent.mkdir(parents=True, exist_ok=True)
        registry_key = f"{name}-{version}-{url_identity}"

        # 1. Resolve Expected Checksum
        expected_sha = None
        if checksum_source == 'github-release':
            expected_sha = self._resolve_github_release_sha(actual_url, original_filename)
        elif checksum_source.startswith('http'):
            # Source is a URL to a checksum file
            checksum_url = checksum_source.replace("{version}", version)
            expected_sha = self._resolve_http_sha(checksum_url, original_filename)
        elif len(checksum_source) == 64:
            # Source is a literal SHA256 hash
            expected_sha = self._canonical_sha256(checksum_source)

        if expected_sha:
            logging.info(f"Resolved expected SHA256 for {name}: {expected_sha}")
        else:
            if checksum_source != 'none':
                logging.warning(f"Could not resolve checksum for {name} using source '{checksum_source}'")

        # 2. Check Cache Integrity. A registry digest is trusted only after
        # re-hashing the bytes; it allows an outage in the checksum service
        # without ever accepting an unverified download.
        with self.registry_lock:
            cache_record = self.registry.get(registry_key, {})
            cached_sha = cache_record.get('download_sha256')
            cached_url = cache_record.get('download_url')

        cached_sha = self._canonical_sha256(cached_sha)
        if cache_filepath.exists():
            # If we have a cached file, verify it
            # If we have a registry SHA, it should match expected (if expected is known)
            valid_cache = False

            if cached_sha:
                actual_file_sha = self.compute_sha256(cache_filepath)
                cache_url_matches = expected_sha or cached_url == actual_url
                if actual_file_sha == cached_sha and cache_url_matches and (not expected_sha or cached_sha == expected_sha):
                    valid_cache = True
                elif expected_sha:
                    logging.warning(f"Cached SHA {cached_sha} does not match expected {expected_sha}.")
            if valid_cache:
                if not expected_sha:
                    logging.warning(f"Checksum service unavailable; using verified cache for {name}.")
                return cache_filepath

        # A configured checksum source is an integrity requirement. Never
        # download bytes when its metadata could not be resolved.
        if checksum_source != 'none' and not expected_sha:
            raise ValueError(f"Could not resolve required checksum for {name}")

        # 3. Download
        part_filepath = cache_filepath.with_name(cache_filepath.name + ".part")
        part_filepath.unlink(missing_ok=True)

        retryer = tenacity.Retrying(
            stop=tenacity.stop_after_attempt(self.retry),
            wait=tenacity.wait_exponential(multiplier=1, min=1, max=5),
            retry=tenacity.retry_if_exception_type(requests.RequestException)
        )

        def _do_download():
            logging.info(f"Downloading {actual_url}")
            part_filepath.unlink(missing_ok=True)
            with requests.get(actual_url, stream=True, timeout=30) as r:
                r.raise_for_status()
                with open(part_filepath, 'wb') as f:
                    for chunk in r.iter_content(chunk_size=8192):
                        f.write(chunk)

        try:
            retryer(_do_download)

            # 4. Verify & Commit
            computed_sha = self.compute_sha256(part_filepath)

            if expected_sha and computed_sha != expected_sha:
                raise ValueError(f"SHA mismatch for {filename}: expected {expected_sha}, got {computed_sha}")

            # Update Cache
            self._update_registry_key(registry_key, 'download_sha256', computed_sha)
            self._update_registry_key(registry_key, 'download_url', actual_url)

            # Rename .part to final filename
            os.replace(part_filepath, cache_filepath)
        except Exception:
            part_filepath.unlink(missing_ok=True)
            raise

        return cache_filepath

    # ==========================
    # Extraction & Artifacts
    # ==========================

    def extract_archive(self, archive_path: Path, target_path: Path) -> None:
        """Extract an archive file to a target directory.

        Args:
            archive_path: Path to the archive file (tar.gz, zip, etc.).
            target_path: Target directory for extraction.
        """
        if target_path.exists():
            shutil.rmtree(target_path)

        temp_extract_dir = self.temp_dir / f"temp_extract_{target_path.name}"
        if temp_extract_dir.exists():
            shutil.rmtree(temp_extract_dir)
        temp_extract_dir.mkdir(parents=True, exist_ok=True)

        try:
            if tarfile.is_tarfile(archive_path):
                with tarfile.open(archive_path, 'r:*') as tar:
                    tar.extractall(temp_extract_dir, filter='tar')
            elif zipfile.is_zipfile(archive_path):
                with zipfile.ZipFile(archive_path, 'r') as zf:
                    zf.extractall(temp_extract_dir)
            else:
                # Assuming simple file, just copy
                temp_extract_dir.joinpath(archive_path.name).write_bytes(archive_path.read_bytes())

            contents = list(temp_extract_dir.iterdir())

            # Ensure parent exists
            target_path.parent.mkdir(parents=True, exist_ok=True)

            # If single directory, move it up (strip top-level component)
            if len(contents) == 1 and contents[0].is_dir():
                shutil.move(str(contents[0]), str(target_path))
                temp_extract_dir.rmdir()
            else:
                shutil.move(str(temp_extract_dir), str(target_path))

        except Exception as e:
            if temp_extract_dir.exists():
                shutil.rmtree(temp_extract_dir)
            raise e

    def cache_artifacts(
        self, pkg: Dict, extracted_dir: Path, name: str, version: str, cache_key: Optional[str] = None
    ):
        """Cache build artifacts for faster subsequent builds.

        Args:
            pkg: Package configuration dictionary.
            extracted_dir: Path to the extracted package directory.
            name: Package name.
            version: Package version.
        """
        if 'cache' not in pkg:
            return

        # Fallback to parent dir if extracted_dir is a file (single-file package)
        base_dir = extracted_dir.parent if extracted_dir.is_file() else extracted_dir

        artifact_key = cache_key or f"{name}-{version}"
        cache_base = self.artifacts_cache_dir / artifact_key

        for pattern in pkg['cache']:
            # Globbing
            full_pattern = str(base_dir / pattern)
            matches = glob.glob(full_pattern)
            for match in matches:
                match_path = Path(match)
                if match_path.exists():
                    rel_path = match_path.relative_to(base_dir)
                    dest = cache_base / rel_path
                    dest.parent.mkdir(parents=True, exist_ok=True)

                    if match_path.is_dir():
                        if dest.exists():
                            shutil.rmtree(dest)
                        self._recursive_copy(match_path, dest, symlinks=True, copy_function=self._force_copy)
                    else:
                        self._force_copy(match_path, dest)

        sha = self.compute_dir_sha256(cache_base)
        self._update_registry_key(artifact_key, 'artifacts_sha256', sha)

    def restore_cache(
        self, pkg: Dict, extracted_dir: Path, name: str, version: str, cache_key: Optional[str] = None
    ) -> bool:
        """Restore cached build artifacts if available and valid.

        Args:
            pkg: Package configuration dictionary.
            extracted_dir: Path to the extracted package directory.
            name: Package name.
            version: Package version.

        Returns:
            True if cache was successfully restored, False otherwise.
        """
        if 'cache' not in pkg:
            return False

        artifact_key = cache_key or f"{name}-{version}"
        cache_base = self.artifacts_cache_dir / artifact_key
        if not cache_base.exists():
            return False

        # Fallback to parent dir if extracted_dir is a file
        base_dir = extracted_dir.parent if extracted_dir.is_file() else extracted_dir

        with self.registry_lock:
            expected_sha = self.registry.get(artifact_key, {}).get('artifacts_sha256')

        expected_sha = self._canonical_sha256(expected_sha)
        if not expected_sha:
            logging.warning(f"Artifact cache for {name} has no valid registry checksum")
            return False
        if self.compute_dir_sha256(cache_base) != expected_sha:
            logging.warning(f"Artifact cache corrupted for {name}")
            return False

        for pattern in pkg['cache']:
            full_pattern = str(cache_base / pattern)
            matches = glob.glob(full_pattern)
            for match in matches:
                source = Path(match)
                if source.exists():
                    rel_path = source.relative_to(cache_base)
                    target = base_dir / rel_path

                    target.parent.mkdir(parents=True, exist_ok=True)

                    if source.is_dir():
                        if target.exists():
                            shutil.rmtree(target)
                        self._recursive_copy(source, target, symlinks=True, copy_function=self._force_copy)
                    else:
                        self._force_copy(source, target)
        return True

    def copy_files(self, extracted_dir: Path, files: List[Dict], out_dir: Path, version: str):
        """Copy files from extracted directory to output directory.

        Args:
            extracted_dir: Source directory containing the files.
            files: List of file copy specifications with 'src', 'dst', and optional 'chmod'.
            out_dir: Target output directory.
            version: Package version associated with the package. `{version}`
                substitutions are performed by `process_package` before this method.
        """
        for file_info in files:
            src = file_info['src']
            dst = out_dir / file_info['dst']

            # Check for HTTP source first to bypass local path resolution
            if src.startswith('http') or src.startswith('https'):
                dst.parent.mkdir(parents=True, exist_ok=True)
                logging.info(f"Downloading resource {src}")
                try:
                    expected_sha = self._canonical_sha256(file_info.get('sha256'))
                    if not expected_sha:
                        raise ValueError(f"HTTP resource {src} is missing valid sha256 metadata")
                    resource_name = f"resource-{hashlib.sha256(src.encode()).hexdigest()}"
                    staged = self.download_file(src, version, resource_name, expected_sha)
                    self._force_copy(staged, dst)
                except (requests.RequestException, ValueError) as e:
                    raise RuntimeError(f"Failed to download resource {src}: {e}") from e
            else:
                src_path = None

                # 1. Check inside the Extracted Workspace (Download)
                if extracted_dir.is_file():
                     # Handle single-file workspace (e.g. AppImage)
                     if src == '.' or src == extracted_dir.name:
                         src_path = extracted_dir
                     else:
                         raise ValueError(f"Source mismatch: Package is a single file '{extracted_dir.name}', but src requested '{src}'. Use '.' or the exact filename.")
                else:
                    # Handle directory workspace
                    src_path = extracted_dir if src == '.' else extracted_dir / src
                    if not src_path.exists():
                         raise FileNotFoundError(f"Source {src_path} not found")

                dst.parent.mkdir(parents=True, exist_ok=True)

                self._recursive_copy(src_path, dst, symlinks=True, copy_function=self._force_copy, dirs_exist_ok=True)

            # Chmod logic
            if 'chmod' in file_info:
                val = file_info['chmod']
                if isinstance(val, str):
                    val = int(val, 8)

                # Security checks
                if val & 0o002:
                    raise ValueError(f"Unsafe chmod {oct(val)}: World-writable permissions are not allowed")
                if val & 0o6000:
                    raise ValueError(f"Unsafe chmod {oct(val)}: SUID/SGID bits are not allowed")
                if dst.is_dir() and val & 0o100 != 0o100:
                    raise ValueError(f"Suspicious chmod {oct(val)}: Directory usually has execution permission for owner")

                os.chmod(dst, val)

    def run_build_cmds(self, cmds: List[str], cwd: Path, version: str, pkg_dir: str):
        """Run build commands in the specified working directory.

        Args:
            cmds: List of shell commands to execute.
            cwd: Working directory for command execution.
            version: Package version for substitution in commands.
            pkg_dir: Package directory path for substitution in commands.
        """
        # If cwd is a file (e.g. single file package), run in its parent directory
        actual_cwd = cwd.parent if cwd.is_file() else cwd

        for cmd in cmds:
            cmd = cmd.replace('{version}', version)
            cmd = cmd.replace('{out_dir}', str(self.out_dir))
            cmd = cmd.replace('{pkg_dir}', pkg_dir)
            self._run_command(["/bin/bash", "-e", "-c", cmd], cwd=actual_cwd)

    # ==========================
    # Package Type Processors
    # ==========================

    def _process_git_package(
        self,
        pkg: Dict,
        url: str,
        checksum_source: str,
        processed_files: List[Dict],
        cache_key: Optional[str] = None,
        git_commit: Optional[str] = None,
    ):
        """Process a git-based package.

        Args:
            pkg: Package configuration dictionary.
            url: Git repository URL.
            checksum_source: Source for checksum validation.
            processed_files: List of files to copy after building.

        Returns:
            Path to the workspace directory.
        """
        name = pkg['name']
        version = pkg['version']
        build_cmds = pkg.get('build_cmds', [])
        pkg_dir = pkg.get('pkg_dir', '')

        # Git Flow: Repo Cache -> Workspace
        workspace_dir = self.download_git(url, version, name, checksum_source, cache_key, git_commit)

        # Restore -> Build -> Cache -> Copy
        self.restore_cache(pkg, workspace_dir, name, version, cache_key)
        self.run_build_cmds(build_cmds, workspace_dir, version, pkg_dir)
        self.cache_artifacts(pkg, workspace_dir, name, version, cache_key)
        self.copy_files(workspace_dir, processed_files, self.out_dir, version)

        return workspace_dir

    def _process_archive_package(
        self,
        pkg: Dict,
        url: str,
        checksum_source: str,
        processed_files: List[Dict],
        cache_key: Optional[str] = None,
    ):
        """Process an archive-based package (tar.gz, zip, etc.).

        Args:
            pkg: Package configuration dictionary.
            url: URL to the archive file.
            checksum_source: Source for checksum validation.
            processed_files: List of files to copy after building.

        Returns:
            Path to the workspace directory.
        """
        name = pkg['name']
        version = pkg['version']
        build_cmds = pkg.get('build_cmds', [])
        pkg_dir = pkg.get('pkg_dir', '')

        # Archive Flow: Download -> Pristine Cache -> Workspace
        archive_path = self.download_file(url, version, name, checksum_source)

        # 1. Ensure Pristine Cache Exists & Verify Integrity
        archive_key = cache_key or f"{name}-{version}"
        pristine_extract_dir = self.extracted_cache_dir / archive_key
        needs_extract = True

        if pristine_extract_dir.exists():
            with self.registry_lock:
                expected_sha = self.registry.get(archive_key, {}).get('extracted_sha256')

            if expected_sha:
                logging.info(f"Verifying cached extraction for {name}...")
                computed_sha = self.compute_dir_sha256(pristine_extract_dir)
                if computed_sha == expected_sha:
                    needs_extract = False
                    logging.info(f"Cached extraction verified for {name}")
                else:
                    logging.warning(f"Cached extraction corrupted for {name}, re-extracting...")
                    shutil.rmtree(pristine_extract_dir)
            else:
                logging.warning(f"Cached extraction found but no registry checksum for {name}, re-extracting...")
                shutil.rmtree(pristine_extract_dir)

        if needs_extract:
            logging.info(f"Extracting {name} to cache...")
            self.extract_archive(archive_path, pristine_extract_dir)
            # Compute and Save SHA to seal the cache
            extracted_sha = self.compute_dir_sha256(pristine_extract_dir)
            self._update_registry_key(archive_key, 'extracted_sha256', extracted_sha)

        # 2. Create Workspace from Pristine Cache
        workspace_dir = self.build_dir / archive_key
        if workspace_dir.exists():
            shutil.rmtree(workspace_dir)

        logging.info(f"Creating workspace for {name}...")
        self._recursive_copy(pristine_extract_dir, workspace_dir, symlinks=True, copy_function=self._force_copy)

        # Restore -> Build -> Cache -> Copy
        # If we have build artifacts cached (e.g. binaries), restore them and skip the build commands.
        if not self.restore_cache(pkg, workspace_dir, name, version, cache_key):
            self.run_build_cmds(build_cmds, workspace_dir, version, pkg_dir)
            self.cache_artifacts(pkg, workspace_dir, name, version, cache_key)
        else:
            logging.info(f"Using cached artifacts for {name}, skipping build cmds.")

        self.copy_files(workspace_dir, processed_files, self.out_dir, version)

        return workspace_dir

    def _process_single_file_package(
        self,
        pkg: Dict,
        url: str,
        checksum_source: str,
        processed_files: List[Dict],
        cache_key: Optional[str] = None,
    ):
        """Process a single-file package (e.g., AppImage, binary).

        Args:
            pkg: Package configuration dictionary.
            url: URL to the file.
            checksum_source: Source for checksum validation.
            processed_files: List of files to copy after building.

        Returns:
            Path to the downloaded file.
        """
        name = pkg['name']
        version = pkg['version']
        build_cmds = pkg.get('build_cmds', [])
        pkg_dir = pkg.get('pkg_dir', '')

        # Download directly to global cache
        downloaded_file = self.download_file(url, version, name, checksum_source)

        # The "workspace" is the file itself.
        # Note: run_build_cmds and cache/restore operations handle file paths by using the parent directory.
        workspace_dir = downloaded_file

        # Restore -> Build -> Cache -> Copy
        # Even for single files, users might want to restore sidecar files or run commands.
        if not self.restore_cache(pkg, workspace_dir, name, version, cache_key):
            self.run_build_cmds(build_cmds, workspace_dir, version, pkg_dir)
            self.cache_artifacts(pkg, workspace_dir, name, version, cache_key)
        else:
            logging.info(f"Using cached artifacts for {name}, skipping build cmds.")

        self.copy_files(workspace_dir, processed_files, self.out_dir, version)

        return workspace_dir

    def _process_downloadless_package(self, pkg: Dict, processed_files: List[Dict]):
        """Process a package without upstream downloads (local files or web resources only).

        Args:
            pkg: Package configuration dictionary.
            processed_files: List of files to copy.

        Returns:
            Path to the workspace directory (output directory).
        """
        name = pkg['name']
        version = pkg['version']
        build_cmds = pkg.get('build_cmds', [])
        pkg_dir = pkg.get('pkg_dir', '')

        # Local flow (No upstream URL)
        workspace_dir = self.out_dir

        for f in processed_files:
            src = f['src']
            is_web = src.startswith('http') or src.startswith('https')
            is_pkg_file = pkg_dir and src.startswith(pkg_dir)
            if not (is_web or is_pkg_file):
                raise ValueError(f"Package '{name}' has no upstream URL, so local file copy '{src}' is forbidden unless it is within {pkg_dir}. Use a URL source or {pkg_dir}.")

        self.copy_files(workspace_dir, processed_files, self.out_dir, version)
        self.run_build_cmds(build_cmds, workspace_dir, version, pkg_dir)

        return workspace_dir

    def _clean_old_versions(self, name: str, current_version: str):
        """Remove cache entries and files for older versions of the package."""
        # Pre-calculate sub-packages to avoid re-computing inside the loop.
        sub_packages = [p for p in self.package_names if p.startswith(f"{name}-")]
        keys_to_remove = []
        with self.registry_lock:
            keys_to_remove = []
            for key in self.registry:
                # A key must be for this package family to be considered.
                if not key.startswith(f"{name}-"):
                    continue
                # Exclude keys that belong to a more specific sub-package.
                if any(key.startswith(f"{p}-") for p in sub_packages):
                    continue
                # Exclude the key for the currently processed version.
                key_version = key.removeprefix(f"{name}-")
                if key_version == current_version or key_version.startswith(f"{current_version}-"):
                    continue
                keys_to_remove.append(key)

            if keys_to_remove:
                # Remove the old versions from registry
                for key in keys_to_remove:
                    del self.registry[key]
                # Save registry while still holding the lock
                self._save_registry(lock=False)

        # Clean up files (outside lock)
        for key in keys_to_remove:
            # Artifacts and Extracted cache
            for cache_type, cache_base_dir in [
                ("artifact", self.artifacts_cache_dir),
                ("extracted", self.extracted_cache_dir),
            ]:
                dir_to_remove = cache_base_dir / key
                if dir_to_remove.exists():
                    logging.info(f"Removing old {cache_type} cache: {dir_to_remove}")
                    try:
                        shutil.rmtree(dir_to_remove)
                    except OSError as e:
                        logging.warning(f"Failed to remove old {cache_type} cache {dir_to_remove}: {e}")

            # Downloads
            url_identity = key.rsplit("-", 1)[-1]
            if self._canonical_sha256(url_identity):
                download_dir = self.download_cache_dir / url_identity
                download_prefix = key[: -(len(url_identity) + 1)]
                candidates = download_dir.glob(f"{download_prefix}*")
            else:
                download_dir = None
                download_prefix = key
                candidates = self.download_cache_dir.glob(f"{glob.escape(key)}*")

            for f in candidates:
                # Ensure we match '{key}' exactly or '{key}.ext' to avoid accidentally
                # deleting a file where the version is a prefix (e.g. 'pkg-1.2' vs 'pkg-1.2-beta').
                if f.is_file() and (f.name == download_prefix or f.name.startswith(f"{download_prefix}.")):
                    logging.info(f"Removing old download cache: {f}")
                    try:
                        f.unlink()
                    except OSError as e:
                        logging.warning(f"Failed to delete {f}: {e}")
            if download_dir is not None and download_dir.exists():
                try:
                    download_dir.rmdir()
                except OSError:
                    pass

    def process_package(self, pkg: Dict) -> bool:
        """Process a single package: download, build, and install.

        Args:
            pkg: Package configuration dictionary.

        Returns:
            True if package processing succeeded, False otherwise.
        """
        if self.abort_event.is_set():
            return False

        name = pkg['name']
        version = pkg['version']
        url = pkg.get('url')
        files = pkg.get('files', [])
        checksum_source = pkg.get('checksum_source', 'none')
        git_commit = pkg.get('git_commit')
        pkg_dir = pkg.get('pkg_dir', '')

        try:
            # Prepare substitutions
            if url:
                url = url.replace("{version}", version)
                cache_key = f"{name}-{version}-{hashlib.sha256(url.encode()).hexdigest()}"
            else:
                cache_key = None

            if checksum_source != 'none':
                checksum_source = checksum_source.replace("{version}", version)

            processed_files = []
            for f in files:
                new_f = f.copy()
                new_f['src'] = f['src'].replace('{version}', version).replace('{pkg_dir}', pkg_dir)
                new_f['dst'] = f['dst'].replace('{version}', version).replace('{pkg_dir}', pkg_dir)
                processed_files.append(new_f)

            # Every network file is independently verified before installation.
            for f in processed_files:
                if f['src'].startswith(('http://', 'https://')) and not self._canonical_sha256(f.get('sha256')):
                    raise ValueError(f"HTTP resource {f['src']} is missing valid sha256 metadata")

            if url and not url.endswith('.git') and checksum_source == 'none':
                raise ValueError(f"Network package {name} is missing required checksum_source")

            # Dispatch based on package type
            workspace_dir = None
            if url:
                if url.endswith('.git'):
                    if checksum_source != 'git-refs' or not self._canonical_git_commit(git_commit):
                        raise ValueError(f"Git package {name} requires a full git_commit with checksum_source: git-refs")
                    workspace_dir = self._process_git_package(
                        pkg, url, checksum_source, processed_files, cache_key, git_commit
                    )
                elif pkg.get('extract', False):
                    # Explicit extract=True implies Archive Package
                    workspace_dir = self._process_archive_package(pkg, url, checksum_source, processed_files, cache_key)
                else:
                    # Default / extract=False implies Single File Package
                    workspace_dir = self._process_single_file_package(pkg, url, checksum_source, processed_files, cache_key)
            else:
                workspace_dir = self._process_downloadless_package(pkg, processed_files)

            # Symlink for cache visibility
            if 'init_cmds' in pkg and workspace_dir and workspace_dir.exists():
                link_path = self.out_dir / '.cache' / 'personal-setup' / f"{name}-{version}"
                link_path.parent.mkdir(parents=True, exist_ok=True)
                if link_path.exists():
                    link_path.unlink()
                try:
                    os.symlink(workspace_dir, link_path)
                except FileExistsError:
                    pass

            logging.info(f"Completed {name}")

            # Clean old versions
            self._clean_old_versions(name, version)

            return True

        except Exception as e:
            logging.error(f"Failed {name}: {e}")
            if self.fast_fail:
                self.abort_event.set()
            return False

    def run_package_init(self, pkg: Dict, env: Dict):
        """Execute init commands for a single package."""
        if self.abort_event.is_set():
            return

        if 'init_cmds' in pkg:
            logging.info(f"Running init for {pkg['name']}")
            for cmd in pkg['init_cmds']:
                if self.abort_event.is_set():
                    return

                cmd = cmd.replace('{version}', pkg['version'])
                cmd = cmd.replace('{pkg_dir}', pkg.get('pkg_dir', ''))

                try:
                    # Add explicit exit to ensure interactive shell closes
                    self._run_command(
                        ["/bin/bash", "-i", "+m", "-e", "-c", f'unalias -a\n{cmd}\nexit 2> /dev/null'],
                        env=env, cwd=self.out_dir
                    )
                except Exception as e:
                    logging.error(f"Init failed for {pkg['name']}: {e}")
                    if self.fast_fail:
                        self.abort_event.set()
                    raise e
            logging.info(f"Init completed for {pkg['name']}")

    def run_init(self, packages: List[Dict]):
        """Run initialization commands for all packages in parallel.

        Args:
            packages: List of package configuration dictionaries.
        """
        env = os.environ.copy()
        env['HOME'] = str(self.out_dir.resolve())

        with concurrent.futures.ThreadPoolExecutor(max_workers=self.parallel) as executor:
            # Submit all init tasks
            futures = [executor.submit(self.run_package_init, pkg, env) for pkg in packages]

            # Wait for results and handle exceptions
            for future in concurrent.futures.as_completed(futures):
                future.result()

def main():
    """Build personal setup environment from package definitions."""
    parser = argparse.ArgumentParser(description="Build personal setup environment")
    parser.add_argument("--out-dir", required=True, help="Output directory")
    parser.add_argument("--parallel", type=int, default=4)
    parser.add_argument("--retry", type=int, default=3)
    parser.add_argument("--fast-fail", action="store_true")
    args = parser.parse_args()

    builder = PackageBuilder(args.out_dir, args.parallel, args.retry, args.fast_fail)

    # Load Packages
    packages_dir = Path('packages')
    packages = []
    if packages_dir.exists():
        for pd in sorted(packages_dir.iterdir()):
            if pd.is_dir():
                yaml_file = pd / 'package.yaml'
                if yaml_file.exists():
                    with open(yaml_file, 'r') as f:
                        pkg = yaml.safe_load(f)
                        pkg['version'] = str(pkg['version'])
                        pkg['pkg_dir'] = str(pd.resolve())
                        packages.append(pkg)

    print(f"Loaded {len(packages)} packages")

    # Populate package names for cache cleaning
    builder.package_names = {pkg['name'] for pkg in packages}

    # Copy skeleton
    if Path('src/settings').exists():
        builder._recursive_copy('src/settings', builder.out_dir, symlinks=True, copy_function=builder._force_copy, dirs_exist_ok=True)

    # Run Parallel
    with concurrent.futures.ThreadPoolExecutor(max_workers=builder.parallel) as executor:
        results = list(executor.map(builder.process_package, packages))

    if all(results) and not builder.abort_event.is_set():
        print("Build success. Running init...")
        try:
            builder.run_init(packages)
            print("Init completed.")
        except Exception as e:
            print(f"Init failed: {e}")
            sys.exit(1)
    else:
        print("Build failed.")
        sys.exit(1)

if __name__ == "__main__":
    main()

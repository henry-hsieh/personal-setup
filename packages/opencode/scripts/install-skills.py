#!/usr/bin/env python3
"""Install pre-pinned OpenCode agent skills from packages/opencode/skills.yaml.

Reads the YAML lock file (one entry per skill), downloads each skill's sources
as a GitHub codeload zipball (tag or branch/commit), extracts it, strips the
single repository top-level directory, and copies the declared subpath into the
user's OpenCode skills directory.

Runs at build time (the opencode package's init phase), so the release archive
ships the skills offline (airgap-safe). The lock file is Renovate-tracked (see
renovate.json5 "OpenCode Skills" managers); each entry's `version` is bumped
automatically.
"""

import os
import shutil
import tempfile
import time
import urllib.request
import zipfile

import yaml

LOCK_PATH = os.path.join(os.path.dirname(__file__), "..", "skills.yaml")
MAX_RETRIES = 3


def _fetch(url: str, dest: str) -> None:
    """Download `url` to `dest` with GITHUB_TOKEN auth and a few retries."""
    token = os.environ.get("GITHUB_TOKEN")
    last_err: Exception | None = None
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "personal-setup"})
            if token:
                req.add_header("Authorization", f"Bearer {token}")
            with (
                urllib.request.urlopen(req, timeout=120) as resp,
                open(dest, "wb") as fh,
            ):
                while True:
                    chunk = resp.read(8192)
                    if not chunk:
                        break
                    fh.write(chunk)
            return
        except Exception as err:  # noqa: BLE001 - retry on any network failure
            last_err = err
            print(f"[opencode] download attempt {attempt}/{MAX_RETRIES} failed: {err}")
            time.sleep(min(2**attempt, 10))
    raise SystemExit(f"[opencode] ERROR: failed to download {url}: {last_err}")


def _install_skill(entry: dict) -> None:
    name = entry["name"]
    package = entry["package"]
    ref = entry["version"]
    src = entry["src"]
    dst_rel = entry["dst"]
    url = f"https://api.github.com/repos/{package}/zipball/{ref}"

    home = os.path.expanduser("~")
    skills_root = os.path.abspath(os.path.join(home, ".config", "opencode", "skills"))
    dst_abs = os.path.abspath(os.path.join(home, dst_rel))
    if (
        os.path.commonpath((skills_root, dst_abs)) != skills_root
        or dst_abs == skills_root
    ):
        raise SystemExit(f"[opencode] ERROR: unsafe dst path for {name}: {dst_rel}")

    print(f"[opencode] installing skill {name} ({package}@{ref})")
    with tempfile.TemporaryDirectory() as tmp:
        zip_path = os.path.join(tmp, "skill.zip")
        _fetch(url, zip_path)

        extract_dir = os.path.join(tmp, "extracted")
        with zipfile.ZipFile(zip_path) as zf:
            zf.extractall(extract_dir)  # trusted, repo-pinned sources

        # GitHub zipballs nest everything under a single <owner>-<repo>-<sha> dir.
        top_entries = [p for p in os.listdir(extract_dir) if not p.startswith(".")]
        if len(top_entries) != 1 or not os.path.isdir(
            os.path.join(extract_dir, top_entries[0])
        ):
            raise SystemExit(f"[opencode] ERROR: unexpected archive layout for {name}")
        repo_root = os.path.join(extract_dir, top_entries[0])

        src_path = os.path.join(repo_root, src)
        if not os.path.isdir(src_path) or not os.path.exists(
            os.path.join(src_path, "SKILL.md")
        ):
            raise SystemExit(
                f"[opencode] ERROR: skill subpath '{src}' (with SKILL.md) not found in {package}@{ref}"
            )

        if os.path.exists(dst_abs):
            shutil.rmtree(dst_abs)
        os.makedirs(os.path.dirname(dst_abs), exist_ok=True)
        shutil.copytree(src_path, dst_abs)

    print(f"[opencode] skill {name} -> {dst_abs}")


def main() -> None:
    with open(LOCK_PATH) as fh:
        data = yaml.safe_load(fh)
    skills = (data or {}).get("skills", [])
    if not skills:
        print("[opencode] no skills declared in skills.yaml")
        return
    for entry in skills:
        _install_skill(entry)


if __name__ == "__main__":
    main()

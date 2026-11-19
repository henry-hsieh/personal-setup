#!/usr/bin/env python3
"""Pre-download AFT's embedding model and ONNX Runtime for offline (airgap) use.

Mirrors exactly what the AFT daemon would fetch on first semantic-search use:

* Embedding model Qdrant/all-MiniLM-L6-v2-onnx into the HF-hub-style layout
  <storage>/semantic/models/models--<namespace>--<name>/ (refs/ snapshots/
  blobs/), with LFS files named by their sha256 oid and regular files by
  git blob sha1.
* ONNX Runtime (version determined at build time from AFT source) shared
  libraries plus the .aft-onnx-installed marker into
  <storage>/onnxruntime/<version>/.

<storage> is $HOME/.local/share/cortexkit/aft — the AFT daemon's default
storage root on Linux. Both trees ship in the release archive so the airgap
machine never hits the network.
"""

import hashlib
import base64
import io
import json
import os
import re
import sys
import tarfile
import urllib.error
import urllib.request
import zipfile
from datetime import datetime, timezone

REPO = "Qdrant/all-MiniLM-L6-v2-onnx"
# hf-hub Rust crate (what fastembed/AFT uses) names cache dirs
# models--<namespace>--<name>, replacing the slash with a double dash.
HUB_REPO = REPO.replace("/", "--")
FILES = ["model.onnx", "tokenizer.json"]
HF = "https://huggingface.co"


def fetch(url):
    """Fetch content from a URL.

    Args:
        url: URL to fetch (must be a trusted HTTPS path).

    Returns:
        Raw bytes of the response content.
    """
    # Fixed HTTPS paths only (HF_REPO/REPO, release tarballs) — no untrusted input.
    req = urllib.request.Request(url, headers={"User-Agent": "personal-setup-build"})  # noqa: S310
    return urllib.request.urlopen(req, timeout=300).read()  # noqa: S310


def git_blob_sha(data):
    """Compute git blob SHA-1 hash of data.

    Args:
        data: Raw bytes to hash.

    Returns:
        Hexadecimal string of the git blob SHA-1 hash.
    """
    # HF hub blob IDs are git-blob SHA-1 by design (not used for security).
    return hashlib.sha1(b"blob %d\0" % len(data) + data).hexdigest()  # noqa: S324


def bridge_runtime(source):
    """Read the exact Linux x64 version and library pin from the installed bridge."""
    versions = re.findall(r'\bconst\s+ORT_VERSION\s*=\s*"(\d+\.\d+\.\d+)"', source)
    blocks = re.findall(
        r"\blinux\s*:\s*\{\s*x64\s*:\s*\{(.*?)\n\s*\},", source, re.DOTALL
    )
    if len(versions) != 1 or len(blocks) != 1:
        raise RuntimeError(
            "Cannot determine AFT ONNX Runtime version and Linux x64 pin"
        )
    hashes = re.findall(r'\blibrarySha256\s*:\s*"([0-9a-f]{64})"', blocks[0])
    if len(hashes) != 1:
        raise RuntimeError("Cannot determine AFT ONNX Runtime Linux x64 pin")
    return versions[0], hashes[0]


def download_nuget(version):
    """Fetch NuGet's CPU package and check the registry's package hash."""
    base = (
        "https://api.nuget.org/v3-flatcontainer/microsoft.ml.onnxruntime/%s/" % version
    )
    url = base + "microsoft.ml.onnxruntime.%s.nupkg" % version
    data = fetch(url)
    # NuGet's checksum detects transfer corruption, but is not an independent
    # trust anchor for the provider library: both arrive from the same registry.
    registration_url = (
        "https://api.nuget.org/v3/registration5-semver1/"
        "microsoft.ml.onnxruntime/%s.json" % version
    )
    registration = json.loads(fetch(registration_url))
    catalog_url = registration["catalogEntry"]
    if not catalog_url.startswith("https://api.nuget.org/v3/catalog0/data/"):
        raise RuntimeError("Unexpected NuGet catalog URL")
    catalog = json.loads(fetch(catalog_url))
    if catalog.get("packageHashAlgorithm") != "SHA512":
        raise RuntimeError("Unexpected NuGet package hash algorithm")
    expected_package = catalog["packageHash"].encode("ascii")
    if base64.b64encode(hashlib.sha512(data).digest()) != expected_package:
        raise RuntimeError("ONNX Runtime NuGet package checksum mismatch")
    digest = hashlib.sha256(data).hexdigest()
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        lib = archive.read("runtimes/linux-x64/native/libonnxruntime.so")
        providers = archive.read(
            "runtimes/linux-x64/native/libonnxruntime_providers_shared.so"
        )
    return lib, providers, digest


def download_ort(version, expected_sha256):
    """Prefer GitHub releases; use NuGet when the release cannot be downloaded."""
    url = (
        "https://github.com/microsoft/onnxruntime/releases/download/v%s/"
        "onnxruntime-linux-x64-%s.tgz" % (version, version)
    )
    try:
        data = fetch(url)
    except (OSError, TimeoutError, urllib.error.URLError) as exc:
        print(
            "[opencode] GitHub ONNX Runtime download failed (%s); trying NuGet" % exc,
            file=sys.stderr,
        )
        lib, providers, digest = download_nuget(version)
    else:
        digest = hashlib.sha256(data).hexdigest()
        prefix = "onnxruntime-linux-x64-%s/lib/" % version
        with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as archive:
            lib_entry = archive.extractfile(prefix + "libonnxruntime.so.%s" % version)
            providers_entry = archive.extractfile(
                prefix + "libonnxruntime_providers_shared.so"
            )
            if lib_entry is None or providers_entry is None:
                raise RuntimeError("ONNX Runtime archive is missing expected libraries")
            lib, providers = lib_entry.read(), providers_entry.read()
    if hashlib.sha256(lib).hexdigest() != expected_sha256:
        raise RuntimeError("ONNX Runtime library does not match the AFT bridge pin")
    return lib, providers, digest


def precache_model(storage):
    """Reuse complete model snapshots without network access; repair incomplete ones."""
    root = os.path.join(storage, "semantic/models", "models--%s" % HUB_REPO)
    try:
        with open(os.path.join(root, "refs", "main")) as fh:
            cached_rev = fh.read().strip()
        if re.fullmatch(r"[0-9a-f]{40}", cached_rev) and all(
            os.path.isfile(os.path.join(root, "snapshots", cached_rev, name))
            for name in FILES
        ):
            return
    except (OSError, UnicodeError):
        pass

    api = json.loads(fetch("%s/api/models/%s" % (HF, REPO)).decode())
    rev = api["sha"]
    tree = json.loads(fetch("%s/api/models/%s/tree/main" % (HF, REPO)).decode())
    lfs_oids = {f["path"]: (f.get("lfs") or {}).get("oid") for f in tree}

    blobs = os.path.join(root, "blobs")
    os.makedirs(blobs, exist_ok=True)
    for name in FILES:
        oid = lfs_oids.get(name)
        if oid:
            blob = oid
            blob_path = os.path.join(blobs, blob)
            if not os.path.exists(blob_path):
                data = fetch("%s/%s/resolve/%s/%s" % (HF, REPO, rev, name))
                if hashlib.sha256(data).hexdigest() != oid:
                    raise RuntimeError("LFS checksum mismatch for %s" % name)
                with open(blob_path, "wb") as fh:
                    fh.write(data)
        else:
            data = fetch("%s/%s/resolve/%s/%s" % (HF, REPO, rev, name))
            blob = git_blob_sha(data)
            with open(os.path.join(blobs, blob), "wb") as fh:
                fh.write(data)
        snap = os.path.join(root, "snapshots", rev)
        os.makedirs(snap, exist_ok=True)
        link = os.path.join(snap, name)
        if os.path.islink(link) or os.path.exists(link):
            os.remove(link)
        os.symlink(os.path.join("..", "..", "blobs", blob), link)
    refs = os.path.join(root, "refs")
    os.makedirs(refs, exist_ok=True)
    with open(os.path.join(refs, "main"), "w") as fh:
        fh.write(rev)


def main(ort_version, expected_sha256):
    """Pre-download AFT embedding model and ONNX Runtime for offline use."""
    storage = os.path.expanduser("~/.local/share/cortexkit/aft")
    precache_model(storage)

    ort_dir = os.path.join(storage, "onnxruntime", ort_version)
    lib_path = os.path.join(ort_dir, "libonnxruntime.so.%s" % ort_version)
    prov_path = os.path.join(ort_dir, "libonnxruntime_providers_shared.so")
    so1_link = os.path.join(ort_dir, "libonnxruntime.so.1")
    so_link = os.path.join(ort_dir, "libonnxruntime.so")
    marker_path = os.path.join(ort_dir, ".aft-onnx-installed")
    required = [lib_path, prov_path, so1_link, so_link, marker_path]
    valid = all(os.path.isfile(p) for p in required) and all(
        os.path.realpath(link) == os.path.realpath(lib_path)
        for link in (so1_link, so_link)
    )
    if valid:
        try:
            with open(lib_path, "rb") as fh:
                valid = hashlib.sha256(fh.read()).hexdigest() == expected_sha256
            with open(marker_path) as fh:
                marker = json.load(fh)
            valid = (
                valid
                and isinstance(marker, dict)
                and marker.get("sha256") == expected_sha256
                and marker.get("version") == ort_version
            )
        except (OSError, ValueError):
            valid = False
    if not valid:
        lib_data, prov_data, archive_sha256 = download_ort(ort_version, expected_sha256)
        for stale in [lib_path, prov_path, so1_link, so_link, marker_path]:
            if os.path.lexists(stale):
                os.remove(stale)
        os.makedirs(ort_dir, exist_ok=True)
        with open(lib_path, "wb") as fh:
            fh.write(lib_data)
        os.chmod(lib_path, 0o644)
        with open(prov_path, "wb") as fh:
            fh.write(prov_data)
        os.chmod(prov_path, 0o644)
        os.symlink("libonnxruntime.so.%s" % ort_version, so1_link)
        os.symlink("libonnxruntime.so.1", so_link)
        now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.") + (
            "%03dZ" % (datetime.now(timezone.utc).microsecond // 1000)
        )
        marker = {
            "version": ort_version,
            "installedAt": now,
            "sha256": hashlib.sha256(lib_data).hexdigest(),
            "archiveSha256": archive_sha256,
        }
        with open(marker_path, "w") as fh:
            json.dump(marker, fh)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: precache-aft.py <aft-bridge-onnx-runtime.js>")
    with open(sys.argv[1]) as bridge:
        version, library_sha256 = bridge_runtime(bridge.read())
    main(version, library_sha256)

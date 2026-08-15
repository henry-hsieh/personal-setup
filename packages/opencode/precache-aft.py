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
import io
import json
import os
import sys
import tarfile
import urllib.request
from datetime import datetime, timezone

if len(sys.argv) < 2:
    raise SystemExit("Usage: precache-aft.py <ort-version>")
ORT_VERSION = sys.argv[1]
REPO = "Qdrant/all-MiniLM-L6-v2-onnx"
# hf-hub Rust crate (what fastembed/AFT uses) names cache dirs
# models--<namespace>--<name>, replacing the slash with a double dash.
HUB_REPO = REPO.replace("/", "--")
FILES = ["model.onnx", "tokenizer.json"]
HF = "https://huggingface.co"


def fetch(url):
    # Fixed HTTPS paths only (HF_REPO/REPO, release tarballs) — no untrusted input.
    req = urllib.request.Request(url, headers={"User-Agent": "personal-setup-build"})  # noqa: S310
    return urllib.request.urlopen(req, timeout=300).read()  # noqa: S310


def git_blob_sha(data):
    # HF hub blob IDs are git-blob SHA-1 by design (not used for security).
    return hashlib.sha1(b"blob %d\0" % len(data) + data).hexdigest()  # noqa: S324


def main():
    storage = os.path.expanduser("~/.local/share/cortexkit/aft")

    api = json.loads(fetch("%s/api/models/%s" % (HF, REPO)).decode())
    rev = api["sha"]
    tree = json.loads(fetch("%s/api/models/%s/tree/main" % (HF, REPO)).decode())
    lfs_oids = {f["path"]: (f.get("lfs") or {}).get("oid") for f in tree}

    root = os.path.join(storage, "semantic/models", "models--%s" % HUB_REPO)
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

    ort_dir = os.path.join(storage, "onnxruntime", ORT_VERSION)
    lib_path = os.path.join(ort_dir, "libonnxruntime.so.%s" % ORT_VERSION)
    if not os.path.exists(lib_path):
        os.makedirs(ort_dir, exist_ok=True)
        tgz = fetch(
            "https://github.com/microsoft/onnxruntime/releases/download/v%s/"
            "onnxruntime-linux-x64-%s.tgz" % (ORT_VERSION, ORT_VERSION)
        )
        archive_sha256 = hashlib.sha256(tgz).hexdigest()
        tf = tarfile.open(fileobj=io.BytesIO(tgz), mode="r:gz")
        lib_entry = tf.extractfile(
            "onnxruntime-linux-x64-%s/lib/libonnxruntime.so.%s"
            % (ORT_VERSION, ORT_VERSION)
        )
        prov_entry = tf.extractfile(
            "onnxruntime-linux-x64-%s/lib/libonnxruntime_providers_shared.so"
            % ORT_VERSION
        )
        if lib_entry is None or prov_entry is None:
            raise RuntimeError("ONNX Runtime archive is missing expected libraries")
        lib_data = lib_entry.read()
        prov_data = prov_entry.read()
        with open(lib_path, "wb") as fh:
            fh.write(lib_data)
        os.chmod(lib_path, 0o644)
        prov_path = os.path.join(ort_dir, "libonnxruntime_providers_shared.so")
        with open(prov_path, "wb") as fh:
            fh.write(prov_data)
        os.chmod(prov_path, 0o644)
        os.symlink(
            "libonnxruntime.so.%s" % ORT_VERSION,
            os.path.join(ort_dir, "libonnxruntime.so.1"),
        )
        os.symlink("libonnxruntime.so.1", os.path.join(ort_dir, "libonnxruntime.so"))
        now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.") + (
            "%03dZ" % (datetime.now(timezone.utc).microsecond // 1000)
        )
        marker = {
            "version": ORT_VERSION,
            "installedAt": now,
            "sha256": hashlib.sha256(lib_data).hexdigest(),
            "archiveSha256": archive_sha256,
        }
        with open(os.path.join(ort_dir, ".aft-onnx-installed"), "w") as fh:
            json.dump(marker, fh)


if __name__ == "__main__":
    main()

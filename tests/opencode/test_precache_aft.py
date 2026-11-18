"""Tests for the AFT ONNX Runtime NuGet precache."""

import base64
import hashlib
import importlib.util
import io
import json
import os
import sys
import subprocess
import tarfile
import tempfile
import unittest
import zipfile
from pathlib import Path
from unittest.mock import patch

SCRIPT = (
    Path(__file__).resolve().parents[2] / "packages/opencode/scripts/precache-aft.py"
)
SPEC = importlib.util.spec_from_file_location("precache_aft", SCRIPT)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError("Unable to load AFT precache script")
aft = importlib.util.module_from_spec(SPEC)
previous_bytecode_setting = sys.dont_write_bytecode
sys.dont_write_bytecode = True
SPEC.loader.exec_module(aft)
sys.dont_write_bytecode = previous_bytecode_setting

LIB = b"main library"
PROVIDERS = b"providers library"
PIN = hashlib.sha256(LIB).hexdigest()
REVISION = "a" * 40
BRIDGE = (
    """const ORT_VERSION = "1.24.4";
const ORT_PLATFORM_MAP = { darwin: { arm64: { librarySha256: "other" } },
 linux: { x64: { assetName: `onnxruntime-linux-x64-${ORT_VERSION}`,
 librarySha256: "%s",
 }, arm64: { librarySha256: "different" } } };"""
    % PIN
)


def package_bytes(include_provider=True):
    data = io.BytesIO()
    with zipfile.ZipFile(data, "w") as archive:
        archive.writestr("runtimes/linux-x64/native/libonnxruntime.so", LIB)
        if include_provider:
            archive.writestr(
                "runtimes/linux-x64/native/libonnxruntime_providers_shared.so",
                PROVIDERS,
            )
    return data.getvalue()


class PrecacheAftTests(unittest.TestCase):
    def test_github_primary_and_checksum_failure(self):
        stream = io.BytesIO()
        with tarfile.open(fileobj=stream, mode="w:gz") as archive:
            for name, content in [
                ("libonnxruntime.so.1.24.4", LIB),
                ("libonnxruntime_providers_shared.so", PROVIDERS),
            ]:
                info = tarfile.TarInfo("onnxruntime-linux-x64-1.24.4/lib/" + name)
                info.size = len(content)
                archive.addfile(info, io.BytesIO(content))
        data = stream.getvalue()
        with patch.object(aft, "fetch", return_value=data) as fetch:
            self.assertEqual(
                aft.download_ort("1.24.4", PIN),
                (LIB, PROVIDERS, hashlib.sha256(data).hexdigest()),
            )
            self.assertEqual(fetch.call_count, 1)
            self.assertIn(
                "github.com/microsoft/onnxruntime/releases", fetch.call_args.args[0]
            )
        with (
            patch.object(aft, "fetch", return_value=data) as fetch,
            self.assertRaisesRegex(RuntimeError, "bridge pin"),
        ):
            aft.download_ort("1.24.4", "0" * 64)
        self.assertEqual(fetch.call_count, 1)

    def test_bridge_pin_selection_and_upgrade(self):
        self.assertEqual(aft.bridge_runtime(BRIDGE), ("1.24.4", PIN))
        self.assertEqual(
            aft.bridge_runtime(BRIDGE.replace("1.24.4", "1.25.0")), ("1.25.0", PIN)
        )
        for source in ("", BRIDGE.replace(PIN, "bad"), BRIDGE + BRIDGE):
            with self.subTest(source=source), self.assertRaises(RuntimeError):
                aft.bridge_runtime(source)

    def test_nuget_download_and_pin(self):
        data = package_bytes()
        checksum = base64.b64encode(hashlib.sha512(data).digest())
        registration = json.dumps(
            {"catalogEntry": "https://api.nuget.org/v3/catalog0/data/test"}
        ).encode()
        catalog = json.dumps(
            {"packageHashAlgorithm": "SHA512", "packageHash": checksum.decode()}
        ).encode()
        with patch.object(
            aft,
            "fetch",
            side_effect=[OSError("GitHub unavailable"), data, registration, catalog],
        ) as fetch:
            lib, providers, digest = aft.download_ort("1.24.4", PIN)
        self.assertEqual(
            (lib, providers, digest), (LIB, PROVIDERS, hashlib.sha256(data).hexdigest())
        )
        self.assertEqual(
            fetch.call_args_list[1].args[0],
            "https://api.nuget.org/v3-flatcontainer/microsoft.ml.onnxruntime/1.24.4/microsoft.ml.onnxruntime.1.24.4.nupkg",
        )

    def test_fail_closed_for_corruption_wrong_pin_and_missing_file(self):
        data = package_bytes()
        checksum = base64.b64encode(hashlib.sha512(data).digest())
        registration = json.dumps(
            {"catalogEntry": "https://api.nuget.org/v3/catalog0/data/test"}
        ).encode()
        catalog = json.dumps(
            {"packageHashAlgorithm": "SHA512", "packageHash": checksum.decode()}
        ).encode()
        with (
            patch.object(
                aft,
                "fetch",
                side_effect=[
                    OSError("GitHub unavailable"),
                    data,
                    registration,
                    catalog.replace(checksum, b"bad"),
                ],
            ),
            self.assertRaisesRegex(RuntimeError, "package checksum"),
        ):
            aft.download_ort("1.24.4", PIN)
        with (
            patch.object(
                aft,
                "fetch",
                side_effect=[
                    OSError("GitHub unavailable"),
                    data,
                    registration,
                    catalog,
                ],
            ),
            self.assertRaisesRegex(RuntimeError, "bridge pin"),
        ):
            aft.download_ort("1.24.4", "0" * 64)
        data = package_bytes(include_provider=False)
        checksum = base64.b64encode(hashlib.sha512(data).digest())
        catalog = json.dumps(
            {"packageHashAlgorithm": "SHA512", "packageHash": checksum.decode()}
        ).encode()
        with (
            patch.object(
                aft,
                "fetch",
                side_effect=[
                    OSError("GitHub unavailable"),
                    data,
                    registration,
                    catalog,
                ],
            ),
            self.assertRaises(KeyError),
        ):
            aft.download_ort("1.24.4", PIN)

    def test_cache_layout_and_invalid_existing_cache_repaired(self):
        data = package_bytes()
        checksum = base64.b64encode(hashlib.sha512(data).digest())

        def fetch(url):
            if "github.com" in url:
                raise OSError("GitHub unavailable")
            if url.endswith(".nupkg"):
                return data
            if "/registration5-semver1/" in url:
                return json.dumps(
                    {"catalogEntry": "https://api.nuget.org/v3/catalog0/data/test"}
                ).encode()
            if "/catalog0/data/" in url:
                return json.dumps(
                    {"packageHashAlgorithm": "SHA512", "packageHash": checksum.decode()}
                ).encode()
            if "/api/models/" in url:
                return json.dumps([] if "/tree/" in url else {"sha": REVISION}).encode()
            return b"model"

        with (
            tempfile.TemporaryDirectory() as home,
            patch.dict(os.environ, {"HOME": home}),
            patch.object(aft, "fetch", side_effect=fetch),
        ):
            aft.main("1.24.4", PIN)
            root = Path(home) / ".local/share/cortexkit/aft/onnxruntime/1.24.4"
            self.assertEqual((root / "libonnxruntime.so").read_bytes(), LIB)
            self.assertEqual(
                (root / "libonnxruntime_providers_shared.so").read_bytes(), PROVIDERS
            )
            marker = json.loads((root / ".aft-onnx-installed").read_text())
            self.assertEqual(marker["sha256"], PIN)
            self.assertEqual(marker["archiveSha256"], hashlib.sha256(data).hexdigest())
            with patch.object(
                aft, "fetch", side_effect=AssertionError("unexpected network request")
            ):
                aft.main("1.24.4", PIN)
            (root / "libonnxruntime.so.1.24.4").write_bytes(b"wrong")
            aft.main("1.24.4", PIN)
            self.assertEqual((root / "libonnxruntime.so").read_bytes(), LIB)

            for link in ("libonnxruntime.so", "libonnxruntime.so.1"):
                with self.subTest(link=link):
                    (root / link).unlink()
                    (root / link).symlink_to("libonnxruntime_providers_shared.so")
                    aft.main("1.24.4", PIN)
                    self.assertEqual(
                        (root / link).resolve(),
                        (root / "libonnxruntime.so.1.24.4").resolve(),
                    )

            for marker in (
                None,
                [],
                "text",
                42,
                True,
                {},
                {"sha256": PIN, "version": "wrong"},
            ):
                with self.subTest(marker=marker):
                    (root / ".aft-onnx-installed").write_text(json.dumps(marker))
                    aft.main("1.24.4", PIN)
                    self.assertEqual(
                        json.loads((root / ".aft-onnx-installed").read_text())[
                            "sha256"
                        ],
                        PIN,
                    )

            # Exercise the real CLI with a complete cache and networking disabled.
            bridge = Path(home) / "onnx-runtime.js"
            bridge.write_text(BRIDGE)
            result = subprocess.run(  # noqa: S603
                [
                    sys.executable,
                    "-B",
                    "-c",
                    "import runpy,socket,sys; "
                    "socket.create_connection=lambda *a,**k: sys.exit('unexpected network'); "
                    "sys.argv=sys.argv[1:]; runpy.run_path(sys.argv[0],run_name='__main__')",
                    str(SCRIPT),
                    str(bridge),
                ],
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_incomplete_model_cache_is_repaired(self):
        def fetch(url):
            if "/api/models/" in url:
                return json.dumps([] if "/tree/" in url else {"sha": REVISION}).encode()
            return b"model"

        with (
            tempfile.TemporaryDirectory() as storage,
            patch.object(aft, "fetch", side_effect=fetch) as network,
        ):
            aft.precache_model(storage)
            root = (
                Path(storage) / "semantic/models/models--Qdrant--all-MiniLM-L6-v2-onnx"
            )
            snapshot = root / "snapshots" / REVISION
            with patch.object(
                aft, "fetch", side_effect=AssertionError("unexpected network")
            ):
                aft.precache_model(storage)
            for name in aft.FILES:
                with self.subTest(name=name):
                    # A dangling snapshot link must not count as a cached file.
                    (snapshot / name).resolve().unlink()
                    network.reset_mock()
                    aft.precache_model(storage)
                    self.assertTrue(network.called)
                    self.assertTrue((snapshot / name).is_file())
            for revision in ("", "../../outside"):
                with self.subTest(revision=revision):
                    (root / "refs/main").write_text(revision)
                    aft.precache_model(storage)
                    self.assertEqual((root / "refs/main").read_text(), REVISION)
            (root / "refs/main").write_bytes(b"\xff\xfe")
            network.reset_mock()
            aft.precache_model(storage)
            self.assertTrue(network.called)
            self.assertEqual((root / "refs/main").read_text(), REVISION)


if __name__ == "__main__":
    unittest.main()

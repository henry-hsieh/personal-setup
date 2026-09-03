#!/usr/bin/env python3
"""Network-free tests for build artifact integrity boundaries."""

import importlib.util
import hashlib
import tempfile
import threading
import unittest
from unittest.mock import MagicMock, patch
from pathlib import Path


BUILD_PATH = Path(__file__).parents[2] / "src" / "build.py"
SPEC = importlib.util.spec_from_file_location("personal_setup_build", BUILD_PATH)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError(f"Unable to load {BUILD_PATH}")
BUILD = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(BUILD)


class IntegrityTests(unittest.TestCase):
    def make_builder(self, root: Path):
        builder = object.__new__(BUILD.PackageBuilder)
        builder.abort_event = threading.Event()
        builder.fast_fail = False
        builder.retry = 1
        builder.download_cache_dir = root / "downloads"
        builder.download_cache_dir.mkdir()
        builder.registry = {}
        builder.registry_lock = threading.Lock()
        builder.registry_file = root / "registry.json"
        return builder

    @staticmethod
    def response(content: bytes):
        response = MagicMock()
        response.__enter__.return_value = response
        response.__exit__.return_value = False
        response.iter_content.return_value = [content]
        return response

    def test_sha256_is_strictly_canonicalized(self):
        digest = "A" * 64
        self.assertEqual(BUILD.PackageBuilder._canonical_sha256(f"  {digest} "), "a" * 64)
        self.assertIsNone(BUILD.PackageBuilder._canonical_sha256("a" * 63))
        self.assertIsNone(BUILD.PackageBuilder._canonical_sha256("g" * 64))
        self.assertEqual(BUILD.PackageBuilder._canonical_git_commit("A" * 40), "a" * 40)
        self.assertIsNone(BUILD.PackageBuilder._canonical_git_commit("a" * 39))

    def test_single_entry_checksum_sidecar_allows_provider_filename(self):
        builder = object.__new__(BUILD.PackageBuilder)
        response = MagicMock()
        response.text = f"{'A' * 64}  provider-filename.tar.gz\n"
        with patch.object(BUILD.requests, "get", return_value=response):
            self.assertEqual(
                builder._resolve_http_sha("https://example.invalid/checksum", "download-name"),
                "a" * 64,
            )

    def test_http_resource_without_digest_fails_preflight(self):
        builder = object.__new__(BUILD.PackageBuilder)
        builder.abort_event = threading.Event()
        builder.fast_fail = False
        package = {
            "name": "test",
            "version": "1",
            "files": [{"src": "https://example.invalid/file", "dst": "file"}],
        }
        self.assertFalse(builder.process_package(package))

    def test_network_package_without_checksum_fails_preflight(self):
        builder = object.__new__(BUILD.PackageBuilder)
        builder.abort_event = threading.Event()
        builder.fast_fail = False
        builder._process_single_file_package = MagicMock(side_effect=AssertionError("must not download"))
        package = {
            "name": "test",
            "version": "1",
            "url": "https://example.invalid/test.tar.gz",
            "files": [],
        }
        self.assertFalse(builder.process_package(package))

    def test_git_package_without_pinned_commit_fails_preflight(self):
        builder = object.__new__(BUILD.PackageBuilder)
        builder.abort_event = threading.Event()
        builder.fast_fail = False
        builder._process_git_package = MagicMock(side_effect=AssertionError("must not clone"))
        package = {
            "name": "test",
            "version": "1",
            "url": "https://example.invalid/test.git",
            "checksum_source": "git-refs",
            "files": [],
        }
        self.assertFalse(builder.process_package(package))

    def test_verified_secondary_download_is_cached(self):
        content = b"verified resource"
        digest = hashlib.sha256(content).hexdigest()
        with tempfile.TemporaryDirectory() as temporary:
            builder = self.make_builder(Path(temporary))
            response = self.response(content)
            with patch.object(BUILD.requests, "get", return_value=response) as get:
                path = builder.download_file("https://example.invalid/file.sh", "1", "resource-test", digest)
                self.assertEqual(path.read_bytes(), content)
                self.assertFalse(path.with_name(path.name + ".part").exists())
                get.assert_called_once()

            with patch.object(BUILD.requests, "get") as get:
                self.assertEqual(builder.download_file("https://example.invalid/file.sh", "1", "resource-test", digest), path)
                get.assert_not_called()

    def test_mismatched_download_removes_partial_file(self):
        content = b"unexpected resource"
        digest = hashlib.sha256(b"expected resource").hexdigest()
        with tempfile.TemporaryDirectory() as temporary:
            builder = self.make_builder(Path(temporary))
            with patch.object(BUILD.requests, "get", return_value=self.response(content)):
                with self.assertRaises(ValueError):
                    builder.download_file("https://example.invalid/file.sh", "1", "resource-test", digest)
            self.assertEqual(list(builder.download_cache_dir.rglob("*.part")), [])

    def test_download_cache_isolated_by_url(self):
        first = b"first artifact"
        second = b"second artifact"
        first_digest = hashlib.sha256(first).hexdigest()
        second_digest = hashlib.sha256(second).hexdigest()
        with tempfile.TemporaryDirectory() as temporary:
            builder = self.make_builder(Path(temporary))
            responses = [self.response(first), self.response(second)]
            with patch.object(BUILD.requests, "get", side_effect=responses):
                first_path = builder.download_file("https://example.invalid/one.tar.gz", "1", "same", first_digest)
                second_path = builder.download_file("https://example.invalid/two.tar.gz", "1", "same", second_digest)
            self.assertNotEqual(first_path, second_path)
            self.assertEqual(first_path.read_bytes(), first)
            self.assertEqual(second_path.read_bytes(), second)

    def test_artifact_cache_isolated_by_source(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            builder = self.make_builder(root)
            builder.artifacts_cache_dir = root / "artifacts"
            builder.artifacts_cache_dir.mkdir()

            first_dir = root / "first"
            second_dir = root / "second"
            first_dir.mkdir()
            second_dir.mkdir()
            (first_dir / "artifact").write_text("first")
            (second_dir / "artifact").write_text("second")
            package = {"cache": ["artifact"]}

            builder.cache_artifacts(package, first_dir, "same", "1", "same-1-first")
            builder.cache_artifacts(package, second_dir, "same", "1", "same-1-second")

            self.assertEqual((builder.artifacts_cache_dir / "same-1-first" / "artifact").read_text(), "first")
            self.assertEqual((builder.artifacts_cache_dir / "same-1-second" / "artifact").read_text(), "second")

    def test_artifact_cache_without_registry_checksum_is_not_restored(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            builder = self.make_builder(root)
            builder.artifacts_cache_dir = root / "artifacts"
            builder.artifacts_cache_dir.mkdir()
            cache_base = builder.artifacts_cache_dir / "same-1-source"
            cache_base.mkdir()
            (cache_base / "artifact").write_text("unverified")

            self.assertFalse(
                builder.restore_cache(
                    {"cache": ["artifact"]}, root / "workspace", "same", "1", "same-1-source"
                )
            )

    def test_extraction_cache_reused_for_same_source(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            builder = self.make_builder(root)
            builder.build_dir = root / "build"
            builder.extracted_cache_dir = root / "extracted"
            builder.out_dir = root / "output"
            builder.build_dir.mkdir()
            builder.extracted_cache_dir.mkdir()
            builder.registry_file = root / "registry.json"
            archive = root / "archive.tar.gz"
            archive.write_bytes(b"archive")
            package = {"name": "same", "version": "1", "files": []}

            def extract(_archive: Path, target: Path):
                target.mkdir(parents=True)
                (target / "payload").write_text("payload")

            with (
                patch.object(builder, "download_file", return_value=archive),
                patch.object(builder, "extract_archive", side_effect=extract) as extract_archive,
                patch.object(builder, "restore_cache", return_value=True),
                patch.object(builder, "copy_files"),
            ):
                builder._process_archive_package(package, "https://example.invalid/one.tar.gz", "a" * 64, [], "same-1-url")
                builder._process_archive_package(package, "https://example.invalid/one.tar.gz", "a" * 64, [], "same-1-url")

            extract_archive.assert_called_once()

    def test_old_url_scoped_download_cache_is_removed(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            builder = self.make_builder(root)
            builder.package_names = {"same"}
            builder.artifacts_cache_dir = root / "artifacts"
            builder.extracted_cache_dir = root / "extracted"
            builder.artifacts_cache_dir.mkdir()
            builder.extracted_cache_dir.mkdir()
            old_url = "https://example.invalid/old.tar.gz"
            url_identity = hashlib.sha256(old_url.encode()).hexdigest()
            old_dir = builder.download_cache_dir / url_identity
            old_dir.mkdir()
            old_file = old_dir / "same-0.tar.gz"
            old_file.write_bytes(b"old")
            builder.registry = {f"same-0-{url_identity}": {"download_sha256": "a" * 64}}

            builder._clean_old_versions("same", "1")

            self.assertFalse(old_file.exists())
            self.assertFalse(old_dir.exists())

    def test_checksum_service_outage_reuses_url_bound_verified_cache(self):
        content = b"cached artifact"
        digest = hashlib.sha256(content).hexdigest()
        url = "https://example.invalid/file.tar.gz"
        with tempfile.TemporaryDirectory() as temporary:
            builder = self.make_builder(Path(temporary))
            with patch.object(BUILD.requests, "get", return_value=self.response(content)):
                path = builder.download_file(url, "1", "resource-test", digest)

            with patch.object(builder, "_resolve_http_sha", return_value=None), patch.object(BUILD.requests, "get") as get:
                self.assertEqual(builder.download_file(url, "1", "resource-test", "https://example.invalid/checksum"), path)
                get.assert_not_called()

    def test_checksum_service_outage_rejects_unverified_cache(self):
        with tempfile.TemporaryDirectory() as temporary:
            builder = self.make_builder(Path(temporary))
            with patch.object(builder, "_resolve_http_sha", return_value=None), patch.object(BUILD.requests, "get") as get:
                with self.assertRaises(ValueError):
                    builder.download_file("https://example.invalid/file.tar.gz", "1", "resource-test", "https://example.invalid/checksum")
                get.assert_not_called()

    def test_http_resource_with_digest_passes_preflight(self):
        builder = object.__new__(BUILD.PackageBuilder)
        builder.abort_event = threading.Event()
        builder.fast_fail = False
        builder._process_downloadless_package = lambda _pkg, _files: True
        builder._clean_old_versions = lambda _name, _version: None
        builder.out_dir = Path(".")
        builder.package_names = set()
        package = {
            "name": "test",
            "version": "1",
            "files": [{"src": "https://example.invalid/file", "dst": "file", "sha256": "a" * 64}],
        }
        self.assertTrue(builder.process_package(package))


if __name__ == "__main__":
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(IntegrityTests)
    result = unittest.TextTestRunner(verbosity=1).run(suite)
    failed = len(result.failures)
    errors = len(result.errors)
    passed = result.testsRun - failed - errors
    print(f"Integrity summary: {passed} passed, {failed} failed, {errors} errors.")
    raise SystemExit(not result.wasSuccessful())

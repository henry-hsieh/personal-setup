#!/usr/bin/env python3
"""Compile and embed Tailwind CSS for the Ensemble dashboard."""

from __future__ import annotations

import sys
from pathlib import Path


TAILWIND_CONFIG = """module.exports = {
  content: ["./src/**/*.ts"],
  theme: {
    extend: {
      colors: {
        base: {
          950: "#0c0e14",
          900: "#141822",
          850: "#1a1f2e",
          800: "#1e2433",
          700: "#2a3144",
          600: "#3a4358",
        },
        txt: {
          100: "#e2e8f0",
          200: "#c1c9d9",
          300: "#aab4c6",
          400: "#8a96aa",
          500: "#7b879b",
        },
      },
      fontFamily: {
        sans: ["Inter", "system-ui", "sans-serif"],
        mono: ["JetBrains Mono", "monospace"],
      },
    },
  },
}
"""

TAILWIND_INPUT = "@tailwind base;\n@tailwind components;\n@tailwind utilities;\n"
EXTERNAL_ASSETS_START = '<link rel="preconnect" href="https://fonts.googleapis.com">\n'
STYLE_START = "<style>\n"


def dashboard_paths(plugin_dir: Path) -> tuple[Path, Path, Path, Path]:
  source_dir = plugin_dir / "src"
  return (
    source_dir / "dashboard-html.ts",
    plugin_dir / ".personal-setup-tailwind.config.cjs",
    source_dir / ".personal-setup-dashboard.css",
    source_dir / "dashboard-tailwind.css",
  )


def prepare(plugin_dir: Path) -> None:
  dashboard_html, config_path, input_path, _ = dashboard_paths(plugin_dir)
  source = dashboard_html.read_text(encoding="utf-8")
  if "DASHBOARD_TAILWIND_CSS" not in source and (
    EXTERNAL_ASSETS_START not in source or STYLE_START not in source
  ):
    raise RuntimeError("unsupported Ensemble dashboard source; expected external Tailwind assets")

  config_path.write_text(TAILWIND_CONFIG, encoding="utf-8")
  input_path.write_text(TAILWIND_INPUT, encoding="utf-8")


def apply(plugin_dir: Path) -> None:
  dashboard_html, _, _, output_path = dashboard_paths(plugin_dir)
  source = dashboard_html.read_text(encoding="utf-8")
  if "DASHBOARD_TAILWIND_CSS" in source:
    if not output_path.is_file() or output_path.stat().st_size == 0:
      raise RuntimeError("previously patched Ensemble dashboard is missing dashboard-tailwind.css")
    return
  if EXTERNAL_ASSETS_START not in source or STYLE_START not in source:
    raise RuntimeError("unsupported Ensemble dashboard source; expected external Tailwind assets")
  if not output_path.is_file() or output_path.stat().st_size == 0:
    raise RuntimeError("Tailwind did not generate dashboard-tailwind.css")

  import_marker = "/** Dashboard HTML head and body structure. JS is appended separately. */\n"
  if import_marker not in source:
    raise RuntimeError("unsupported Ensemble dashboard source; expected dashboard header")

  source = source.replace(
    import_marker,
    'import { readFileSync } from "node:fs"\n\n'
    'const DASHBOARD_TAILWIND_CSS = readFileSync(\n'
    '  new URL("./dashboard-tailwind.css", import.meta.url),\n'
    '  "utf8",\n'
    ')\n\n'
    + import_marker,
    1,
  )
  start = source.index(EXTERNAL_ASSETS_START)
  end = source.index(STYLE_START, start) + len(STYLE_START)
  source = source[:start] + "<style>${DASHBOARD_TAILWIND_CSS}\\n" + source[end:]
  dashboard_html.write_text(source, encoding="utf-8")


def main() -> None:
  if len(sys.argv) != 3 or sys.argv[1] not in {"prepare", "apply"}:
    raise SystemExit(f"usage: {Path(sys.argv[0]).name} <prepare|apply> <plugin-dir>")

  plugin_dir = Path(sys.argv[2]).resolve()
  if not plugin_dir.is_dir():
    raise SystemExit(f"plugin directory does not exist: {plugin_dir}")

  try:
    if sys.argv[1] == "prepare":
      prepare(plugin_dir)
    else:
      apply(plugin_dir)
  except (OSError, RuntimeError) as error:
    raise SystemExit(f"failed to patch Ensemble dashboard: {error}") from error


if __name__ == "__main__":
  main()

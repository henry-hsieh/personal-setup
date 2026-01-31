import argparse
import json
import sys
from pathlib import Path

def main():
    parser = argparse.ArgumentParser(
        description="Create symlinks for opencode workflows from a manifest."
    )
    parser.add_argument("out_dir", type=Path, help="The output directory.")
    parser.add_argument(
        "manifest_path", type=Path, help="Path to the JSON manifest file."
    )
    args = parser.parse_args()

    out_dir = args.out_dir
    manifest_path = args.manifest_path

    try:
        with manifest_path.open() as f:
            manifest = json.load(f)
    except FileNotFoundError:
        sys.exit(f"Error: Manifest file not found at {manifest_path}")
    except json.JSONDecodeError as e:
        sys.exit(f"Error: Invalid JSON in {manifest_path}: {e}")
    except OSError as e:
        sys.exit(f"Error: Could not read manifest file at {manifest_path}: {e}")

    base_config_dir = out_dir / ".config" / "opencode"
    workflows_dir_name = "opencode-workflows"

    for category, items in manifest.items():
        category_dir = base_config_dir / category
        category_dir.mkdir(parents=True, exist_ok=True)

        for name, src_rel_path in items.items():
            if '..' in Path(src_rel_path).parts:
                print(f"Warning: Skipping '{name}' due to potentially unsafe path '{src_rel_path}'.", file=sys.stderr)
                continue

            target_path = category_dir / name
            # Source path relative to category_dir
            # e.g., from .config/opencode/agents/ to .config/opencode/opencode-workflows/path/to/file
            # is ../opencode-workflows/path/to/file
            src_link_target = Path("..") / workflows_dir_name / src_rel_path

            if target_path.is_dir() and not target_path.is_symlink():
                print(f"Warning: Skipping {target_path} because it is a directory.", file=sys.stderr)
                continue

            if target_path.exists() or target_path.is_symlink():
                target_path.unlink()

            print(f"Creating symlink: {target_path} -> {src_link_target}")
            target_path.symlink_to(src_link_target)


if __name__ == "__main__":
    main()

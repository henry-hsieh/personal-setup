#!/usr/bin/env bash

set -e

SHARE_DIR="$HOME/.local/share/personal-setup"
if [ -f "$SHARE_DIR/package.json" ]; then
  echo "Installing Bun dependencies in $SHARE_DIR..."
  export PATH="$HOME/.local/bin:$PATH"
  cd "$SHARE_DIR"
  # Production install with exact versions
  bun install -p -E --no-progress

  echo "Creating wrappers in .local/bin..."
  mkdir -p "$HOME/.local/bin"
  for bin_path in node_modules/.bin/*; do
    [ -e "$bin_path" ] || continue
    bin_name=$(basename "$bin_path")

    # Avoid overwriting core tools unless it's our own wrapper
    if [ -f "$HOME/.local/bin/$bin_name" ]; then
      if ! grep -qE "execution wrapper" "$HOME/.local/bin/$bin_name" 2>/dev/null; then
        echo "Skipping $bin_name: already exists in .local/bin (managed by other package)"
        continue
      fi
    fi

    # Use bun run --bun for all except copilot-language-server which needs node:sqlite
    # We use node directly for copilot-language-server
    if [ "$bin_name" != "copilot-language-server" ]; then
      runtime="bun"
      flags="run --bun"
    else
      runtime="node"
      flags=""
    fi
    cat <<EOF > "$HOME/.local/bin/$bin_name"
#!/usr/bin/env bash
# $runtime execution wrapper
exec "$runtime" $flags "\$HOME/.local/share/personal-setup/node_modules/.bin/$bin_name" "\$@"
EOF
    chmod 755 "$HOME/.local/bin/$bin_name"
  done
else
  echo "package.json not found in $SHARE_DIR" > /dev/stderr
  exit 1
fi

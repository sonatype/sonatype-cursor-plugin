#!/usr/bin/env bash
# Experimental: clone Sonatype Guide plugin into Cursor's URL cache so it might
# be discovered. Cursor may only load plugins from marketplace; this is a workaround
# when /add-plugin with a GitHub URL does nothing.

set -e
CACHE="${CURSOR_PLUGINS:-$HOME/.cursor/plugins}/cache/url"
SANITIZED="https---github-com-sonatype-sonatype-cursor-plugin"
REPO_URL="https://github.com/sonatype/sonatype-cursor-plugin.git"
PLUGIN_DIR="$CACHE/$SANITIZED/sonatype-cursor-plugin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Check if git is available when needed
if ! command -v git &>/dev/null; then
  if [[ ! -f "$LOCAL_ROOT/.cursor-plugin/plugin.json" ]]; then
    echo "Error: git is not installed. Please install git to clone the repository."
    exit 1
  fi
fi

echo "Target: $PLUGIN_DIR"

mkdir -p "$CACHE/$SANITIZED"

# If we're in the plugin repo and it has the manifest, copy locally (works before push)
if [[ -f "$LOCAL_ROOT/.cursor-plugin/plugin.json" ]]; then
  echo "Using local plugin at $LOCAL_ROOT"
  rm -rf "$PLUGIN_DIR"
  cp -R "$LOCAL_ROOT" "$PLUGIN_DIR"
  rm -rf "$PLUGIN_DIR/.git"
elif [[ -d "$PLUGIN_DIR/.git" ]]; then
  echo "Updating existing clone..."
  (cd "$PLUGIN_DIR" && git fetch origin && (git reset --hard origin/main 2>/dev/null || git reset --hard origin/master)) || {
    echo "Warning: Failed to update existing clone. Removing and re-cloning..."
    rm -rf "$PLUGIN_DIR"
    git clone --depth 1 "$REPO_URL" "$PLUGIN_DIR"
  }
else
  echo "Cloning $REPO_URL ..."
  git clone --depth 1 "$REPO_URL" "$PLUGIN_DIR"
fi

if [[ ! -f "$PLUGIN_DIR/.cursor-plugin/plugin.json" ]]; then
  echo "Error: .cursor-plugin/plugin.json not found in clone. Check repo structure."
  exit 1
fi

echo "Done. Restart Cursor and check Settings → Plugins."
echo "If the plugin still does not appear, submit it at https://cursor.com/marketplace/publish"

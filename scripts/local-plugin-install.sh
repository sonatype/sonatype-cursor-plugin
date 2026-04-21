#!/usr/bin/env bash
# Install Sonatype Guide plugin from local path for Cursor.
# Run from the plugin repo root. Backs up installed.json before modifying.

set -e
CURSOR_PLUGINS="${CURSOR_PLUGINS:-$HOME/.cursor/plugins}"
INSTALLED_JSON="$CURSOR_PLUGINS/installed.json"
PLUGIN_NAME="sonatype-cursor-plugin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ ! -f "$PLUGIN_ROOT/.cursor-plugin/plugin.json" ]]; then
  echo "Error: Plugin root not found at $PLUGIN_ROOT (.cursor-plugin/plugin.json missing)"
  exit 1
fi

if [[ ! -f "$INSTALLED_JSON" ]]; then
  echo "Error: Cursor plugins file not found: $INSTALLED_JSON"
  exit 1
fi

# Backup
cp "$INSTALLED_JSON" "$INSTALLED_JSON.bak"
echo "Backed up to $INSTALLED_JSON.bak"

# Add local plugin path using jq if available
if command -v jq &>/dev/null; then
  jq --arg name "$PLUGIN_NAME" --arg path "$PLUGIN_ROOT" \
    '.local[$name] = $path' "$INSTALLED_JSON.bak" > "$INSTALLED_JSON"
  echo "Added local plugin: $PLUGIN_NAME -> $PLUGIN_ROOT"
else
  # Fallback: try sed to add to local object
  echo "jq not found. Adding $PLUGIN_NAME to local section."
  if grep -q '"local":{}' "$INSTALLED_JSON"; then
    ESCAPED_PATH=$(echo "$PLUGIN_ROOT" | sed 's/[\/&]/\\&/g')
    sed "s/\"local\":{}/\"local\":{\"$PLUGIN_NAME\":\"$ESCAPED_PATH\"}/" "$INSTALLED_JSON.bak" > "$INSTALLED_JSON"
  else
    echo "Please add manually to $INSTALLED_JSON in the \"local\" object:"
    echo "  \"$PLUGIN_NAME\": \"$PLUGIN_ROOT\""
    cp "$INSTALLED_JSON.bak" "$INSTALLED_JSON"
    exit 1
  fi
fi

echo "Done. Restart Cursor and check Settings → Plugins. If the plugin does not appear, try Option A (GitHub) in INSTALL_TEST.md."

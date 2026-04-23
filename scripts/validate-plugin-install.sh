#!/usr/bin/env bash
# Validate Sonatype Guide Cursor plugin installation (config + files on disk).
# Does not verify Cursor UI; run this and also check Settings → Plugins in Cursor.

set -e
CURSOR_PLUGINS="${CURSOR_PLUGINS:-$HOME/.cursor/plugins}"
INSTALLED_JSON="$CURSOR_PLUGINS/installed.json"
PLUGIN_NAME="sonatype-cursor-plugin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PASS=0
FAIL=0

check() {
  if "$@"; then
    echo "  PASS: $*"
    ((PASS++)) || true
    return 0
  else
    echo "  FAIL: $*"
    ((FAIL++)) || true
    return 1
  fi
}

echo "=== Sonatype Cursor Plugin validation ==="
echo "Plugin root: $PLUGIN_ROOT"
echo ""

echo "1. Cursor registered plugin (installed.json)"
if grep -q "\"$PLUGIN_NAME\"" "$INSTALLED_JSON" 2>/dev/null; then
  echo "  PASS: $PLUGIN_NAME found in local plugins"
  ((PASS++)) || true
else
  echo "  FAIL: $PLUGIN_NAME not in $INSTALLED_JSON (run scripts/local-plugin-install.sh)"
  ((FAIL++)) || true
fi
echo ""

echo "2. Plugin path exists"
check test -d "$PLUGIN_ROOT"
echo ""

echo "3. Manifest (.cursor-plugin/plugin.json)"
check test -f "$PLUGIN_ROOT/.cursor-plugin/plugin.json"
if python3 -c "import json; json.load(open('$PLUGIN_ROOT/.cursor-plugin/plugin.json'))" 2>/dev/null; then
  echo "  PASS: valid JSON"
  ((PASS++)) || true
else
  echo "  FAIL: invalid JSON"
  ((FAIL++)) || true
fi
echo ""

echo "4. MCP config (mcp.json)"
check test -f "$PLUGIN_ROOT/mcp.json"
if grep -q 'mcpServers' "$PLUGIN_ROOT/mcp.json" && grep -q 'sonatype-guide' "$PLUGIN_ROOT/mcp.json"; then
  echo "  PASS: mcpServers.sonatype-guide present"
  ((PASS++)) || true
else
  echo "  FAIL: mcp.json missing mcpServers or sonatype-guide"
  ((FAIL++)) || true
fi
echo ""

echo "5. Skills (4)"
SKILL_COUNT=$(find "$PLUGIN_ROOT/skills" -maxdepth 2 -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$SKILL_COUNT" -eq 4 ]]; then
  echo "  PASS: $SKILL_COUNT skills (check-dependency, find-safer-version, audit-dependencies, setup-guide-mcp)"
  ((PASS++)) || true
else
  echo "  FAIL: expected 4 skills, found $SKILL_COUNT"
  ((FAIL++)) || true
fi
echo ""

echo "6. Rules (2)"
RULE_COUNT=$(find "$PLUGIN_ROOT/rules" -maxdepth 1 -name "*.mdc" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$RULE_COUNT" -eq 2 ]]; then
  echo "  PASS: $RULE_COUNT rules"
  ((PASS++)) || true
else
  echo "  FAIL: expected 2 rules, found $RULE_COUNT"
  ((FAIL++)) || true
fi
echo ""

echo "7. Agents (1)"
AGENT_COUNT=$(find "$PLUGIN_ROOT/agents" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$AGENT_COUNT" -ge 1 ]]; then
  echo "  PASS: $AGENT_COUNT agent(s)"
  ((PASS++)) || true
else
  echo "  FAIL: expected at least 1 agent"
  ((FAIL++)) || true
fi
echo ""

echo "=== Result: $PASS passed, $FAIL failed ==="
if [[ $FAIL -gt 0 ]]; then
  echo "Fix failures above. Then restart Cursor and check Settings → Plugins."
  exit 1
fi
echo "Config and files look good. In Cursor: restart if needed, then check Settings → Plugins and MCP list for 'sonatype-guide'."
exit 0

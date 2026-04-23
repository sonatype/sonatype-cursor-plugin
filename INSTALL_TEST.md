# Install test: Sonatype Guide Cursor plugin

Use this to run **P0-3** from [SPRINT_PLAN.md](./SPRINT_PLAN.md): confirm the plugin installs and the MCP server appears.

---

## Before you start

- **Token (optional for load test):** To actually call the MCP, set `SONATYPE_GUIDE_TOKEN` in your shell or Cursor env. For “does the plugin load?” you can skip this.
- **Cursor:** You need Cursor IDE (not only VS Code).

---

## Option A: Install from marketplace (only way `/add-plugin` works)

**Why `/add-plugin` with a GitHub URL does nothing:** Cursor only installs plugins that are **on the Cursor Marketplace**. Typing `/add-plugin sonatype/sonatype-guide-cursor-plugin` or a GitHub URL gives **no response** because the plugin is not in the marketplace yet.

**To make the plugin installable:**

1. **Submit the plugin** at [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish) with repo URL:  
   `https://github.com/sonatype/sonatype-guide-cursor-plugin`
2. After approval, Cursor will list it on the marketplace (with a slug like `sonatype-guide`).
3. **Then** users can run `/add-plugin sonatype-guide` in chat or install via **Settings → Plugins → Browse Marketplace**.

Until then, use **Option B** (local path) or **Option C** (clone into cache) below.

---

## Option B: Local install (for testing without publishing)

Use this to test the plugin from your machine without pushing to GitHub.

**Note:** Plugins added via the `local` section of `installed.json` may **not appear** in Settings → Plugins. If the plugin still doesn’t show or load, try **Option C** (clone into cache) or submit to the marketplace (Option A).

1. **Back up Cursor’s plugin list** (optional but recommended):
   ```bash
   cp ~/.cursor/plugins/installed.json ~/.cursor/plugins/installed.json.bak
   ```

2. **Run the local install script** from this repo:
   ```bash
   cd /path/to/sonatype-guide-cursor
   ./scripts/local-plugin-install.sh
   ```
   This script adds `sonatype-guide` to the `local` section of `~/.cursor/plugins/installed.json` (no copy to cache).

3. **Restart Cursor.** The plugin may still not appear under Installed.

4. **Uninstall (revert) when done testing:**
   ```bash
   ./scripts/local-plugin-uninstall.sh
   ```

---

## Option C: Clone into Cursor’s URL cache (experimental)

Cursor stores URL-installed plugins under `~/.cursor/plugins/cache/url/`. You can try copying this repo into that structure so Cursor might pick it up.

1. **Run the install-from-GitHub script** (clones this repo into Cursor’s cache; it does **not** modify `installed.json`):
   ```bash
   cd /path/to/sonatype-guide-cursor
   ./scripts/install-from-github-to-cache.sh
   ```
2. (Optional) To have Cursor treat it as user-installed, **manually add** `"sonatype-guide"` to the `user` array in `~/.cursor/plugins/installed.json` (see Option B for how to back up this file before editing).
3. **Restart Cursor** and check **Settings → Plugins** for Sonatype Guide.
4. If it doesn’t appear, the only reliable path is **Option A** (submit to marketplace).

5. **Uninstall (revert) when done testing:**
   ```bash
   rm -rf ~/.cursor/plugins/cache/url/https---github-com-sonatype-sonatype-guide-cursor-plugin
   ```
   If you manually added `sonatype-guide` to the `user` array in step 2, remove it from `~/.cursor/plugins/installed.json`.

---

## Verification checklist

After installing (A or B):

| Step | What to check | Pass? |
|------|----------------|-------|
| 1 | Plugin appears in **Settings → Plugins** (or Cursor’s plugin list) | ☐ |
| 2 | **MCP:** In Cursor, open MCP / integrations and confirm **sonatype-guide** is listed | ☐ |
| 3 | Enable the **sonatype-guide** MCP server (if there’s a toggle) | ☐ |
| 4 | **Skills:** In chat/agent, confirm skills like `check-dependency`, `find-safer-version`, `audit-dependencies`, `setup-guide-mcp` are available | ☐ |
| 5 | **Agent:** Confirm **dependency-advisor** agent is available | ☐ |
| 6 | **Rules:** Open a `package.json` or `pom.xml` and confirm dependency-hygiene / security-first-deps are suggested or active | ☐ |
| 7 | **Live MCP (optional):** Set `SONATYPE_GUIDE_TOKEN`, then in chat run: “Check lodash 4.17.21” and confirm you get a real response from Sonatype Guide | ☐ |

---

## If something fails

- **Plugin not listed:** Ensure repo root (or the folder you added) contains `.cursor-plugin/plugin.json` and the paths inside it are correct. Restart Cursor after install.
- **MCP not showing:** Confirm `mcp.json` is in the plugin root and is referenced in `plugin.json` under `mcpServers`. Our `mcp.json` uses a `mcpServers` wrapper.
- **MCP errors / 401:** Set `SONATYPE_GUIDE_TOKEN` and restart Cursor (and terminal if you set it in the shell). Token must be valid at [guide.sonatype.com](https://guide.sonatype.com).

---

## After the test

- If you used **Option B**, run `./scripts/local-plugin-uninstall.sh` and optionally restore `installed.json.bak`.
- Update [SPRINT_PLAN.md](./SPRINT_PLAN.md): check off P0-3 and note any issues.

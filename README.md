# Sonatype Cursor Plugin

AI-powered dependency intelligence for Cursor. Check vulnerabilities, find safer versions, and make better dependency decisions using Sonatype's component data.

## Installation

**Important:** `/add-plugin` with a GitHub URL or `owner/repo` **does nothing** in Cursor (no response). Cursor only installs plugins that are on the **Cursor Marketplace**. So you must either submit this plugin at [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish) first, or use a workaround below.

**After the plugin is on the marketplace**, in Cursor chat run:

```
/add-plugin sonatype-cursor-plugin
```

**Workarounds before it’s published:**

- **Local / cache:** See [INSTALL_TEST.md](INSTALL_TEST.md) — Option B (local path in `installed.json`) or Option C (clone into Cursor’s plugin cache).

## Prerequisites

You need a Sonatype Guide account and API token.

### Get Your Token

1. Visit [guide.sonatype.com/settings/tokens](https://guide.sonatype.com/settings/tokens)
2. Generate a new token
3. Copy the token value

### Configure Your Token


Add to `~/.zshrc`, `~/.bashrc`, or `~/.profile`:

```bash
export SONATYPE_GUIDE_TOKEN="your-token-here"
```

Then reload your shell:
```bash
source ~/.zshrc  # or ~/.bashrc
```
**Important for Linux users:** If you installed Cursor via deb/apt, the desktop launcher doesn't inherit shell environment variables. Either:                                         
  1. Add the token to `~/.profile` (not just `~/.bashrc`) and log out/in, or      
  2. Launch Cursor from a terminal: `export SONATYPE_GUIDE_TOKEN="..." && cursor`
### Cursor MCP Configuration

Add to `.cursor/mcp.json` in the "mcpServers" section:

```json
{
  "mcpServers": {
    "sonatype-mcp": {
      "type": "http",
      "url": "https://mcp.guide.sonatype.com/mcp",
      "headers": {
        "Authorization": "Bearer ${SONATYPE_GUIDE_TOKEN}"
      }
    }
  }
}
```

## Components

### Skills

| Skill | Description |
|:------|:------------|
| `check-dependency` | Analyze a dependency for vulnerabilities, license issues, and quality metrics |
| `find-safer-version` | Find recommended replacement versions ranked by Developer Trust Score |
| `audit-dependencies` | Comprehensive security audit of all project dependencies |
| `setup-guide-mcp` | Configure the Sonatype Guide MCP server connection |

### Rules

| Rule | Description |
|:-----|:------------|
| `dependency-hygiene` | Proactive guidance when editing package manifests |
| `security-first-deps` | Security-focused dependency selection guidance |

### Agents

| Agent | Description |
|:------|:------------|
| `dependency-advisor` | Specialized agent for evaluating dependencies, comparing alternatives, and planning upgrades |

## Usage Examples

**Check a specific package:**
```
/check-dependency lodash 4.17.20
```

**Find safer versions:**
```
/find-safer-version spring-core 5.3.20
```

**Audit all project dependencies:**
```
/audit-dependencies
```

**Natural language queries:**
```
What vulnerabilities exist in log4j 2.14.0?
```

```
Scan my package.json for vulnerable dependencies
```

```
What's the most secure version of commons-lang3 I should use?
```

## MCP Tools

This plugin connects to the Sonatype Guide MCP server and provides these tools:

| Tool | Purpose |
|------|---------|
| `getComponentVersion` | Detailed analysis of specific dependencies |
| `getLatestComponentVersion` | Find latest versions with quality data |
| `getRecommendedComponentVersions` | Top recommendations by Developer Trust Score |

## Troubleshooting

**MCP server not connecting:**
- Verify your token: `echo $SONATYPE_GUIDE_TOKEN`
- Ensure your token is valid at [guide.sonatype.com](https://guide.sonatype.com)
- Restart your IDE after setting the environment variable

**Token not recognized:**
- If using shell profile, restart your terminal
- Variable name must be exactly `SONATYPE_GUIDE_TOKEN`

## Links

- [Sonatype Guide](https://guide.sonatype.com)
- [Sonatype](https://www.sonatype.com)
- [Get Support](https://support.sonatype.com)

## License

MIT

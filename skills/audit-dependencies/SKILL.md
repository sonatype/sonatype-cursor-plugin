---
name: audit-dependencies
description: "Comprehensive security audit of all project dependencies using Sonatype Guide. Use when the user asks to audit dependencies, run a CVE scan, check for outdated packages, review supply chain security, or scan a package manifest (package.json, pom.xml, requirements.txt, go.mod, Cargo.toml, Gemfile, build.gradle) for vulnerabilities, license issues, or quality concerns."
---

# Audit dependencies

Scans every dependency in a project's package manifest against the Sonatype Guide MCP server, then reports vulnerabilities, license issues, and quality concerns prioritized by severity.

## Supported File Types

- `package.json` (npm/Node.js)
- `pom.xml` (Maven/Java)
- `build.gradle` / `build.gradle.kts` (Gradle/Java)
- `requirements.txt` / `pyproject.toml` (Python)
- `go.mod` (Go)
- `Cargo.toml` (Rust)
- `Gemfile` (Ruby)

## Workflow

1. **Detect manifests** — find dependency file(s) in the project root and subdirectories. If none found, ask the user which file to scan.
2. **Parse dependencies** — extract each dependency name and version from the manifest.
3. **Convert to PURL** — build a Package URL for each dependency:
   - npm: `pkg:npm/<name>@<version>`
   - Maven: `pkg:maven/<groupId>/<artifactId>@<version>`
   - PyPI: `pkg:pypi/<name>@<version>`
   - Go: `pkg:golang/<module>@<version>`
   - Rust: `pkg:cargo/<name>@<version>`
   - Ruby: `pkg:gem/<name>@<version>`
4. **Batch check via MCP** — call `getComponentVersion` with up to 20 PURLs per request:
   ```
   getComponentVersion({ purl: "pkg:npm/lodash@4.17.20" })
   ```
   If a PURL returns no data, log it and continue with the remaining dependencies.
5. **Classify findings** by severity:
   - **Critical**: actively exploited vulnerabilities (known KEV)
   - **High**: severe CVEs or license violations
   - **Medium**: moderate security or quality issues
   - **Low**: minor concerns or outdated packages
6. **Generate report** — produce an executive summary, detailed findings table, and prioritized remediation plan.

## Example

```
User: Audit my dependencies

Response:
## Dependency Audit Report — my-app

**Scanned**: package.json (47 dependencies)

| Severity | Count |
|----------|-------|
| Critical | 2     |
| High     | 5     |
| Medium   | 8     |
| Low      | 12    |
| Clean    | 20    |

**Critical — fix immediately:**
1. log4j-core 2.14.0 → CVE-2021-44228 (Log4Shell, RCE) → upgrade to 2.21.0
2. lodash 4.17.19 → CVE-2021-23337 (Prototype Pollution) → upgrade to 4.17.21

Would you like me to apply these fixes, or run `/find-safer-version` for upgrade options?
```

## Guardrails

- Limit batch size to 20 dependencies per `getComponentVersion` call
- Cache results for repeated audits in the same session
- Skip devDependencies by default (include with explicit user request)
- Respect .gitignore and lockfile patterns

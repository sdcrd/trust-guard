# Changelog

All notable changes to Trust Guard.

## [2.2.0] — 2026-06-05

### Added
- TL;DR section at top of SKILL.md for faster agent comprehension
- Real-world before/after example (production i18n incident)
- `allowed-tools` field to frontmatter (security signal)
- 8 additional tags for skills.sh discoverability (claude-code, cursor, copilot, codex, security, typescript, javascript, python)
- `references/quickstart.md` — 30-second setup guide
- `references/integrations.md` — copy-paste hook configs for all platforms
- `CONTRIBUTING.md` — bug report template and contribution guide
- `CHANGELOG.md` — this file
- `SECURITY.md` — security policy and vulnerability reporting
- `tools/README.md` — clarifies tools are human-only, never agent-executed

### Changed
- Renamed `optional-tools/` to `tools/` for cleaner naming
- Optimized tags for skills.sh search relevance

## [2.1.0] — 2026-06-05

### Added
- Auto-trigger system (keywords, tools, signals)
- Troubleshooting section (6 common issues)
- Version history tracking
- `references/glossary.md` (32 terms)

## [2.0.0] — 2026-06-05

### Changed (Breaking)
- Complete rewrite as pure natural language instructions
- Shell scripts moved to `optional-tools/` (agent never executes)
- All verification now uses agent's built-in tools (Read, Grep)

### Added
- Security audit documentation (Gen Agent Trust Hub + Socket)
- Enterprise readiness section
- 12 confirmed failure patterns with GitHub sources
- Eval test cases (5 scenarios with assertions)
- Cross-platform compatibility declarations

## [1.0.0] — 2026-06-05

### Added
- Initial release
- Core verification protocol (5-step: pre-flight → execute → post-flight → score → act)
- Trust score system (0-100 with 5 ranges)
- Tool-specific verification (Write, Edit, MultiEdit, Subagent, MCP)
- GitHub README with badges and install instructions

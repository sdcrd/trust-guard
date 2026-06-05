# Contributing to Trust Guard

Trust Guard improves with every new failure pattern discovered. Here's how to help.

## Reporting a New Silent Failure Pattern

Found a case where an AI agent's edit silently failed? Open an issue with:

### Bug Report Template

```markdown
**Tool Used:** [Write / Edit / MultiEdit / Task (subagent) / MCP tool]

**Agent & Model:** [e.g., Claude Code + DeepSeek V4 Pro]

**What the agent claimed:**
[Copy the agent's success message]

**What actually happened:**
[Describe what you found — file unchanged, partial update, wrong file, etc.]

**How you detected it:**
[Did Trust Guard catch it? Manual inspection? Production break?]

**Files affected:**
- [file path] — [what was supposed to change]
- [file path] — [what actually happened]

**Reproduction steps:**
1. [Step 1]
2. [Step 2]
3. [Step 3]
```

### What Makes a Good Report

- **Include the exact old_string and new_string** used in the Edit
- **Include file encoding info** if relevant (tabs vs spaces, BOM, line endings)
- **Include agent turn count** — failures increase after turn 40
- **Include model name** — different models have different failure patterns
- **Screenshots welcome** — before/after file contents

## Suggesting Improvements

Open an issue with:
1. What you want to improve
2. Why it matters
3. Your suggested approach

We prioritize improvements that:
- Catch new categories of silent failures
- Reduce false positives
- Work across more platforms
- Maintain audit-safe status (no executable code in agent path)

## Development

Trust Guard is intentionally simple. The SKILL.md is pure natural language. All verification is done by the agent's own tools.

### Key Design Principles
1. **Zero executable code in agent path** — all verification is natural language instructions
2. **Model-agnostic** — works with any AI model
3. **Platform-agnostic** — works with any Agent Skills compatible client
4. **Audit-safe** — passes Gen Agent Trust Hub and Socket security checks

### Testing Changes
1. Edit SKILL.md
2. Have agent perform edits and verify
3. Check that trust scores are accurate
4. Verify no regression in detection rate

## License

MIT. All contributions under the same license.

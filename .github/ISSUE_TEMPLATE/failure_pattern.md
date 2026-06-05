---
name: New Failure Pattern
about: Report a newly discovered way that AI agent edits silently fail
title: "[PATTERN] "
labels: failure-pattern, research
assignees: ""
---

## Pattern Name

<!-- Give it a short, descriptive name: e.g., "Symlink Redirect," "Encoding Mismatch" -->


## What Happened

### Tool Used:
<!-- Write / Edit / MultiEdit / Task (subagent) / MCP tool -->

### Agent Claimed:
<!-- Copy exactly what the agent said -->

### What Actually Happened:
<!-- Describe the reality -->


## Detection Method

<!-- How did you discover this? Trust Guard catch it? Manual inspection? Production break? -->


## Reproduction Steps

1. 
2. 
3. 


## Root Cause Analysis

<!-- If you figured out WHY this happened, explain here -->

- **Suspected root cause:** [e.g., old_string whitespace mismatch, subagent filesystem isolation, worktree path confusion]
- **Is this model-specific?** [e.g., only happens with DeepSeek, only after turn 50]
- **Is this tool-specific?** [e.g., only MultiEdit, only subagents]


## Files & Context

### File encoding:
<!-- UTF-8? BOM? Line endings (LF/CRLF)? -->

### old_string used:
```
[paste exact old_string]
```

### new_string used:
```
[paste exact new_string]
```

### Whitespace check:
<!-- Did you verify tabs vs spaces match? cat -A output helpful -->


## Session Context

- **Turn count when failure occurred:** [e.g., 47]
- **Model:** [e.g., deepseek-v4-pro]
- **Files changed in session:** [count]
- **Other active skills:** [e.g., think, drift-guard]


## Impact

- **Severity:** [Critical — production break / High — bug but caught / Medium — caught by trust-guard / Low — cosmetic]
- **Time lost:** [minutes]
- **Files affected:** [count]


## Proposed Detection

<!-- Any ideas for how Trust Guard could automatically detect this pattern? -->

---

Thank you for contributing to the trust-guard failure pattern library! Your report helps protect every developer using AI coding agents.

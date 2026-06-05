---
name: Bug Report
about: Report a bug or unexpected behavior with Trust Guard
title: "[BUG] "
labels: bug
assignees: ""
---

## Describe the Bug

<!-- What went wrong? What did you expect to happen? -->

## Trust Guard Version

<!-- e.g., 2.2.0 -->

## Environment

- **AI Agent:** [e.g., Claude Code, Cursor, Copilot, Codex]
- **Model:** [e.g., deepseek-v4-pro, claude-opus-4-7, gpt-5.4]
- **OS:** [e.g., Windows 11, macOS 14, Ubuntu 24.04]
- **Trust Guard Mode:** [strict / normal / light]

## What Happened

### Agent claimed:
<!-- Copy the agent's success message -->

### Actual result:
<!-- What actually happened to the file? -->

### Trust score reported:
<!-- e.g., 95/100 TRUSTED (but file was broken) -->


## Files Involved

| File | Expected Change | Actual Result |
|------|----------------|---------------|
| `src/example.ts` | Change X to Y | File unchanged / partial / wrong file |


## Reproduction

1. Agent performed: [Write / Edit / MultiEdit / Task]
2. Tool reported: [success / error message]
3. Verification found: [what went wrong]

## Screenshots

<!-- If applicable, add screenshots of before/after file contents -->

## Additional Context

- Turn count in session: [e.g., turn 47 of session]
- Cache hit rate (if known): [e.g., 72%]
- Was file read before edit? [yes / no]
- Any other skills active: [e.g., think, drift-guard]

# Trust Guard — Platform Integration Guides

Copy-paste hook configurations for every platform.

## Claude Code

### PostToolUse Hook (recommended)

Add to `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "node -e \"console.log(JSON.stringify({trust_guard:'Post-edit verification required — re-read file and verify content'}))\"",
            "timeout": 3000
          }
        ]
      }
    ]
  }
}
```

### PreToolUse Guard Hook

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "node -e \"const fs=require('fs');const p=process.env.CLAUDE_TOOL_INPUT;if(p){const i=JSON.parse(p);if(i.file_path&&!fs.existsSync(i.file_path)){console.log(JSON.stringify({permissionDecision:'allow',additionalContext:'WARNING: Target file does not exist yet. Verify after write.'}))}}\"",
            "timeout": 3000
          }
        ]
      }
    ]
  }
}
```

## Cursor

Cursor loads skills from `~/.agents/skills/`. Install via:

```bash
npx skills add emkaru/trust-guard
```

Or manually:
```bash
git clone https://github.com/emkaru/trust-guard.git ~/.agents/skills/trust-guard
```

Cursor automatically discovers skills in `~/.agents/skills/` on restart.

## GitHub Copilot

Copilot supports Agent Skills format natively. Install via skills.sh:

```bash
npx skills add emkaru/trust-guard
```

Or add to your project's `.agents/skills/trust-guard/` directory. Copilot discovers skills at session start.

## Codex (OpenAI)

Codex uses the Agent Skills specification. Install:

```bash
npx skills add emkaru/trust-guard
```

Codex discovers skills from `~/.agents/skills/` and `.agents/skills/` directories.

## Any MCP-Compatible Agent

Manual install — copy the skill folder:

```bash
cp -r trust-guard/ ~/.agents/skills/trust-guard/
# or project-level:
cp -r trust-guard/ .agents/skills/trust-guard/
```

Any agent implementing the Agent Skills specification will discover it.

## VS Code + Claude Code Extension

Skills are discovered from the Claude Code skills directory. Install normally:

```bash
npx skills add emkaru/trust-guard
```

The VS Code extension picks up skills automatically.

## CI/CD Integration

### GitHub Actions

```yaml
- name: Trust Guard Pre-Commit Check
  run: |
    bash tools/trust-check.sh --pre-commit --min-score 70
```

### Git Hooks

```bash
# Install pre-commit trust gate
cp tools/pre-commit-hook.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## Verification

After installing on any platform, verify it's working:

1. Ask the agent to edit any file
2. Check that the agent performs post-edit verification
3. Trust score should appear in the response

If the agent doesn't verify: check that the skill was discovered (agent should list "trust-guard" in available skills).

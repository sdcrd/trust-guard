# Trust Guard — Known Silent Failure Patterns

Compiled from confirmed GitHub issues on anthropics/claude-code. Each pattern is reproducible and verified by the deep research process.

## Pattern 1: Partial old_string Match

**Source:** anthropics/claude-code #64171, #4462

**Symptom:** Edit tool reports success. Changes appear applied. But one or more call sites remain unchanged because old_string matched only a whitespace variant or partial match.

**Real case:** Greeting string with two call sites. One edit silently failed. Agent reported success. Broken bundle deployed to production — UI showed raw i18n key to real customers.

**Detection:**
```bash
# Before edit — count all occurrences
grep -cn "old_string_pattern" <file>

# After edit — verify count changed
grep -cn "new_string_fragment" <file>
# Should match expected call site count
```

## Pattern 2: Subagent Ghost Write

**Source:** anthropics/claude-code #64171, #23801

**Symptom:** Subagent (Task tool) claims successful Write. Return message says file created. Actual file is empty or unchanged.

**Detection:**
```bash
# After subagent returns — verify
ls -la <claimed_output_path>
wc -l <claimed_output_path>
test -s <claimed_output_path> && echo "HAS CONTENT" || echo "EMPTY FILE"
```

## Pattern 3: Worktree Confusion

**Source:** anthropics/claude-code #23801

**Symptom:** Edit applies successfully but to the wrong git worktree. Agent reads file from worktree A, edits worktree B. Both claim success.

**Detection:**
```bash
# After edit — confirm which worktree was modified
git worktree list
git diff --name-only
# Verify the diff is in the expected worktree
```

## Pattern 4: Multi-Edit Partial Application

**Source:** anthropics/claude-code #4462

**Symptom:** MultiEdit with 3+ changes. Some apply, some don't. Tool reports overall success but some edits in the batch silently failed.

**Detection:**
```bash
# Verify each edit in the batch independently
for change in edit1 edit2 edit3; do
  grep -F "$change.new_fragment" target_file || echo "MISSING: $change"
done
```

## Pattern 5: MCP Write Silence

**Source:** anthropics/claude-code #11416

**Symptom:** MCP server tool performs write operation. Returns success/empty response. File was not actually written. No error surfaced to agent.

**Detection:**
```bash
# Always re-read after MCP writes
# MCP tools may not propagate filesystem errors
stat <file>  # Check modification time
grep -c "expected_content" <file>
```

## Pattern 6: Read-Before-Edit Skipped

**Source:** AMD analysis (Stella Laurenzo, 6,852 sessions)

**Symptom:** Agent edits file without reading it first. Read:Edit ratio collapsed from 6.6 to 2.0 after March 2026 regression. Edits without prior Read went from 6.2% to 33.7%.

**Detection:**
```
Pre-edit check: was this file read in the last 5 turns?
If NOT → HIGH RISK. Read the file first, then edit.
```

## Pattern 7: Whitespace Invisibility

**Source:** General pattern

**Symptom:** old_string uses tabs. File uses spaces (or vice versa). Exact match fails. Edit silently fails. Agent assumes success.

**Detection:**
```bash
# Check for whitespace mismatch
cat -A <file> | grep "old_string_fragment"
# ^I = tab, spaces = literal spaces
# If old_string uses spaces but file has tabs (or vice versa) → mismatch
```

## Pattern 8: Encoding Mismatch

**Source:** General pattern

**Symptom:** File has BOM, non-ASCII characters, or different line endings than expected. Edit match fails on invisible bytes.

**Detection:**
```bash
file <file>  # Check encoding
hexdump -C <file> | head -5  # Look for BOM (EF BB BF) or unusual bytes
```

## Pattern 9: Concurrent Overwrite

**Source:** Multi-agent scenario

**Symptom:** Two agents or one agent + user edit same file simultaneously. Last writer wins. First edit silently lost.

**Detection:**
```bash
# Check file modification time vs expected edit time
stat -c "%Y" <file>  # Unix timestamp
# Compare with when edit was made
```

## Pattern 10: Permission Denied (Silent)

**Source:** General system pattern

**Symptom:** File is read-only, owned by different user, or in protected directory. Write tool reports success but OS blocks the write.

**Detection:**
```bash
ls -la <file>  # Check permissions and owner
test -w <file> && echo "WRITABLE" || echo "READ-ONLY — edits will fail silently"
```

## Pattern 11: Disk Full / Quota Exceeded

**Source:** General system pattern

**Symptom:** Disk is full or user quota exceeded. Write appears to succeed but file is truncated or empty.

**Detection:**
```bash
df -h .  # Check disk space
quota -s 2>/dev/null  # Check user quota (if applicable)
```

## Pattern 12: Symlink Redirection

**Source:** General pattern

**Symptom:** Target file is a symlink. Edit writes through symlink but resolved path differs from expected. Agent checks original path, sees unchanged file.

**Detection:**
```bash
readlink -f <file>  # Resolve full path
ls -la <file>  # Check if it's a symlink (l in first column)
```

---

All patterns sourced from: https://github.com/anthropics/claude-code/issues/
Deep research verification: https://github.com/anthropics/claude-code/issues/64171

# Trust Guard — Evaluation Tests

These test scripts validate that Trust Guard catches the failure patterns it claims to detect. Each test simulates a specific silent failure scenario and verifies the detection works.

## Quick Run

```bash
# Run all evals
bash evals/run-all.sh

# Run a specific test
bash evals/test-silent-failure.sh
bash evals/test-partial-application.sh
bash evals/test-ghost-write.sh
```

## Test Cases

| Test | What It Simulates | Expected Result |
|------|------------------|-----------------|
| `test-silent-failure.sh` | Edit tool claims success but file is unchanged | Trust score 0-10 (CRITICAL/BROKEN) |
| `test-partial-application.sh` | Edit updates 1 of 2 call sites | Trust score 40-64 (UNTRUSTED) |
| `test-ghost-write.sh` | Subagent claims write but file is empty | Trust score 0-10 (CRITICAL) |

## Fixtures

The `fixtures/` directory contains test data files used by the eval scripts:

- `multi-site.txt` — File with 2 identical strings for partial application testing
- `empty-target.txt` — Empty file for ghost write detection testing

## Adding New Tests

1. Create a new test script in `evals/`
2. Add any test data to `evals/fixtures/`
3. The test should simulate the failure, run verification, and check the trust score
4. Exit 0 on pass, exit 1 on fail

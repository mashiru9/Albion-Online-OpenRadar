# ChatGPT ↔ Codex coordination protocol

This Draft PR is the shared communication channel for the local Windows deployment task.

## Roles

### Codex

- Executes local commands on the user's Windows machine.
- Reads `AGENTS.md` and `docs/CODEX_TASK.md` before acting.
- Commits intentional repository changes to `codex/windows-d-deploy`.
- Pushes the branch and posts progress/errors/results as PR comments.
- Never posts credentials, machine secrets, packet-capture contents, or sensitive local paths beyond the agreed project path.

### ChatGPT

- Reviews repository changes, PR comments, test output, and reported errors through GitHub.
- Posts diagnosis, corrections, and next-step instructions to the same PR when the user asks for a review/check.
- Does not claim to continuously monitor the PR in the background.

### User

- Approves system-level actions such as software/driver installation, UAC/admin elevation, Npcap installation, firewall changes, environment-variable changes, or security-software changes.
- Does not need to copy detailed logs between ChatGPT and Codex; both agents should use this PR.

## Codex progress-comment format

Post one comment after each substantial stage:

```markdown
## Codex stage report

**Stage:** <environment / clone / dependencies / tests / startup / scripts / final>
**Status:** PASS | BLOCKED | PARTIAL | FAIL
**Branch:** codex/windows-d-deploy
**Commit:** <sha or N/A>

### Actions performed
- ...

### Commands and results
- `<command>` → exit code `<code>`

### Findings
- ...

### Files changed
- ...

### Approval needed
- None
  or
- <exact system-level action requiring user approval>

### Next action
- ...
```

## Error-report format

```markdown
## Codex blocker

**Command:** `<exact command>`
**Exit code:** `<code>`
**Working directory:** `D:\Projects\Albion-Online-OpenRadar`

### Complete relevant error
```text
<paste the relevant unredacted technical error, but remove secrets/tokens>
```

### Diagnosis
- ...

### Safe options
1. ...
2. ...

### User approval required
- Yes/No — explain precisely.
```

## ChatGPT review-comment format

```markdown
## ChatGPT review

**Reviewed:** <commit/comment/test output>
**Assessment:** APPROVED | CHANGES REQUESTED | NEEDS MORE EVIDENCE

### Findings
- ...

### Required next steps for Codex
1. ...
2. ...

### Safety note
- ...
```

## Handoff rules

- Codex should pull the latest coordination branch before beginning a new stage.
- ChatGPT should review the latest commit and PR comments before issuing corrections.
- When Codex changes scripts or source code, it must include test output and the commit SHA.
- System-level changes are never inferred as approved merely because they appear in the task document.
- Do not use GitHub to store packet captures, game traffic, credentials, access tokens, or machine secrets.
- Player-coordinate decryption, process injection, memory reading, anti-cheat bypass, and fake coordinate rendering remain out of scope.

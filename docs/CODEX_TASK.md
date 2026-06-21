# Codex task: deploy OpenRadar on Windows D drive

## Goal

Deploy this repository locally on Windows 10/11 at:

`D:\Projects\Albion-Online-OpenRadar`

Validate the toolchain, install project dependencies, run tests, start development mode, verify the local web interface, and prepare reusable Windows scripts.

This task does not include enemy-coordinate recovery, decryption, injection, memory reading, anti-cheat bypass, or any equivalent mechanism.

## Phase 1 — environment audit

Confirm that the D drive exists and is writable. Create `D:\Projects` if needed.

Record the output of:

```powershell
git --version
node --version
npm --version
go version
bash --version
make --version
docker --version
```

Check Npcap without installing it:

- service status;
- `C:\Windows\System32\Npcap`;
- `Packet.dll` and `wpcap.dll`;
- whether the application can enumerate adapters.

Produce a status table with component, detected version, repository requirement, pass/fail, and recommended action.

Use the current repository files as the source of truth. At the time this task was created, `package.json` requires Node 24 or newer and `go.mod` declares Go 1.26, but re-read both files before acting.

Docker is not required for native Windows development mode.

Pause for user approval before any system-wide installation, UAC/admin operation, Npcap installation, environment-variable change, firewall change, or security-software change.

## Phase 2 — obtain the repository

Use the user's fork and the active coordination branch:

```powershell
git clone --branch codex/windows-d-deploy https://github.com/mashiru9/Albion-Online-OpenRadar.git D:\Projects\Albion-Online-OpenRadar
Set-Location "D:\Projects\Albion-Online-OpenRadar"
```

If the directory already exists:

- verify it is the correct repository;
- preserve local changes;
- show `git status`;
- do not use destructive reset or clean commands;
- fetch the remote and switch to `codex/windows-d-deploy` safely;
- only use `git pull --ff-only` when the working tree is clean.

Record:

```powershell
Get-Location
git remote -v
git branch --show-current
git log -1 --oneline
git status
```

## Phase 3 — inspect before running

Read at least:

- `README.md`
- `AGENTS.md`
- `Makefile`
- `package.json`
- `package-lock.json`
- `go.mod`
- `go.sum`
- `cmd/radar`
- `internal/capture`
- `internal/photon`
- `internal/server`
- `web/scripts/handlers/PlayersHandler.js`
- `web/scripts/drawings/PlayersDrawing.js`

Summarize:

- Windows development startup chain;
- Windows release build chain;
- Npcap and adapter-selection behavior;
- default port and URLs;
- configuration and log locations;
- whether administrator rights are actually required;
- known functional limitations, especially player coordinates.

Do not modify code during this inspection phase.

## Phase 4 — install project dependencies

From the repository root, run:

```powershell
npm ci
npm run build
go mod download
```

Do not delete or regenerate `package-lock.json`. Do not modify `go.mod` or `go.sum` merely to suppress an environment problem.

Do not run asset/data refresh commands such as `update-data`, `update-assets`, `download-icons`, `download-map`, `refresh-assets`, or `refresh-codes` unless required runtime files are demonstrably missing. Report the evidence before doing so.

## Phase 5 — tests

Run all of the following and preserve complete output:

```powershell
go test ./...
npm test
npm run typecheck
npm run lint
```

Classify failures as:

- deployment blocker;
- repository-existing failure;
- tool-version problem;
- Windows-specific issue;
- non-blocking warning.

Do not alter business logic just to make tests pass.

## Phase 6 — start development mode

Preferred route in Git Bash:

```bash
cd /d/Projects/Albion-Online-OpenRadar
make run
```

Equivalent PowerShell fallback:

```powershell
Set-Location "D:\Projects\Albion-Online-OpenRadar"
npm run css
npm run vendors
go run ./cmd/radar -dev
```

After startup:

- confirm the process remains alive;
- check port 5001;
- verify `http://localhost:5001`;
- record any LAN URL printed by the application;
- verify CSS, JavaScript, fonts, images, game databases, and WebSocket connectivity;
- capture backend and browser-console errors;
- explain how to stop the process safely with Ctrl+C.

Do not launch Albion Online automatically. Do not modify the firewall or kill an unknown process occupying port 5001.

## Phase 7 — Npcap and adapter readiness

Inspect only unless the user explicitly approves installation.

Record:

- Npcap service and DLL status;
- visible Wi-Fi, Ethernet, VPN, ExitLag, and virtual adapters;
- which adapters OpenRadar selects;
- whether packet capture can initialize.

If ExitLag is detected, mention the project's documented NDIS Legacy requirement but do not change ExitLag settings automatically.

## Phase 8 — create reusable local scripts

Create these files on the coordination branch:

### `scripts/check-environment.ps1`

It must:

- locate the repository root;
- report Windows, PowerShell, Git, Node, npm, Go, Bash, Make, Docker, and Npcap status;
- verify D-drive writability, required project files, `node_modules`, and port 5001;
- enumerate relevant network adapters;
- make no system changes;
- return a non-zero code when a critical dependency is missing.

### `scripts/start-windows-dev.ps1`

It must:

- enter `D:\Projects\Albion-Online-OpenRadar`;
- validate Node, npm, Go, project files, `node_modules`, and port 5001;
- run `npm run css`, `npm run vendors`, and `go run ./cmd/radar -dev`;
- support Ctrl+C;
- never auto-elevate, install software, alter the firewall, hide errors, or kill an unknown process.

### `scripts/test-windows.ps1`

It must:

- run the four test commands in sequence;
- continue after an individual failure;
- record timing and exit code for each step;
- print a final summary;
- return non-zero if any step fails;
- not auto-fix lint or modify source files.

### `docs/LOCAL_TEST_CHECKLIST_ZH.md`

Include checks for:

- adapter selection and packet capture;
- port/WebSocket/backend health;
- local-player position and map transitions;
- resource family, tier, enchant, living/depleted-node behavior;
- mobs, bosses, Mists, Roads, dungeons, portals, chests;
- player detection list, alerts, guild/alliance/faction/equipment data;
- stale-entity cleanup;
- parser, unknown-event, type-mismatch, WebSocket, database, and Npcap errors;
- confirmation that no injection, memory reading, unknown driver, firewall change, or security-software bypass occurred.

Review `.gitignore` and propose only safe additions for generated files such as local logs, packet captures, and local configuration. Do not remove existing rules.

## Phase 9 — commit and report

Commit intentional scripts and documentation to `codex/windows-d-deploy`. Do not commit:

- `node_modules`;
- `dist` binaries;
- logs;
- `.pcap` or `.pcapng` files;
- `network.json` or local configuration;
- credentials or machine-specific secrets.

Push the branch and post progress/final reports to the Draft PR using the format in `docs/AI_COORDINATION.md`.

The final report must include:

1. actual deployment path;
2. current branch and commit;
3. detected tool versions;
4. Npcap and adapter state;
5. dependency-install results;
6. all test results;
7. startup command and local URLs;
8. port 5001 state;
9. created/changed files;
10. `git diff --stat` and `git status`;
11. unresolved blockers;
12. steps for tomorrow's in-game test;
13. all system-level changes, or an explicit statement that none occurred;
14. explicit confirmation that enemy coordinates remain unsupported and no decryption/injection/memory reading/anti-cheat bypass was implemented.

# AGENTS.md

## Active task

This branch is the shared workspace for deploying OpenRadar on the user's Windows machine.

Read these files before taking action:

1. `docs/CODEX_TASK.md`
2. `docs/AI_COORDINATION.md`
3. `README.md`
4. `Makefile`
5. `package.json`
6. `go.mod`

## Fixed local path

Deploy and run the project at:

`D:\Projects\Albion-Online-OpenRadar`

Do not create a project copy on the C drive. Existing system installations and normal tool caches do not need to be moved, but repository files, `node_modules`, build artifacts, project logs, captures, and local configuration must remain under the D-drive project directory whenever the tool allows it.

## Execution rules

- Audit the environment before installing anything.
- Use the requirements in the current `package.json` and `go.mod` as the source of truth.
- Prefer PowerShell. Use Git Bash only where the Makefile requires Bash/GNU Make.
- Ordinary commands inside the repository may be executed directly.
- Stop and request user approval before any administrator/UAC action, Npcap installation, system environment variable change, firewall change, security-software change, driver installation, or system-wide package installation.
- Do not execute destructive Git commands such as `git reset --hard` or `git clean -fd`.
- Preserve user files and local changes.
- Do not silently ignore errors or failing tests.

## Safety boundary

This task is limited to local deployment, normal passive packet-capture setup, and functional testing.

Do not:

- implement player-position decryption;
- inject into, Hook, or read memory from Albion Online;
- extract keys or create a man-in-the-middle proxy;
- modify or bypass BattlEye or any anti-cheat mechanism;
- install unknown drivers or certificates;
- modify the hosts file;
- disable security software or add exclusions;
- draw fake player coordinates or claim that enemy positions are supported.

Player testing is limited to detection, list display, names, guild/alliance/faction information, available equipment data, and alerts.

## Validation

After JavaScript changes run:

- `npm test`
- `npm run typecheck`
- `npm run lint`

After Go changes run:

- `go test ./...`

Do not update game databases or run asset-refresh commands unless required files are demonstrably missing and the reason is reported first.

## GitHub coordination

Use the Draft PR for branch `codex/windows-d-deploy` as the shared communication thread.

At the end of each stage, post a PR comment using the format in `docs/AI_COORDINATION.md`. Commit only intentional source or documentation changes. Do not commit `node_modules`, build artifacts, logs, packet captures, or local configuration.

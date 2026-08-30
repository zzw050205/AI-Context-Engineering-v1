---
name: project-context-init
description: Initialize the minimal context-engineering structure for a new or existing Git project. Use only when the user explicitly asks to initialize project context or invokes $project-context-init. Do not use during ordinary development tasks.
---

# Project Context Initialization

Create a safe, minimal, repository-local context system without overwriting existing project knowledge.

## Inputs

- Current working directory or repository root.
- Optional project name and one-sentence purpose supplied by the user.
- Existing code, configuration, README, tests, CI, and Git history when present.

## Procedure

1. Confirm that the current directory is the intended project root.
2. Read applicable instructions and inspect:
   - `git status --short`;
   - current branch and latest commit;
   - existing `AGENTS.md`, README, `.gitignore`, `.ai/`, and `docs/`;
   - dependency, build, test, lint, type-check, and CI configuration.
3. Do not clean, stash, restore, reset, or overwrite user changes.
4. If existing modifications overlap files this initialization would edit and cannot be safely merged, stop and report the conflict.
5. Run `scripts/bootstrap_context.sh` from this skill directory, passing the repository root.
6. Review the script output. It may create only missing context files and directories; it must not modify business code or install dependencies.
7. Fill only facts that can be reliably established:
   - project purpose and current scope;
   - important directories only when they are non-obvious;
   - real install, run, test, lint, type-check, and build commands;
   - stable project-specific rules and sensitive boundaries;
   - the actual current project state.
8. For an existing non-empty file, preserve its content and propose a focused merge. Never replace it wholesale.
9. Do not create speculative architecture, API, task-log, project-map, changelog, or decision documents.
10. Show a concise initialization preview:
    - files created, merged, skipped, or conflicting;
    - inferred facts and their evidence;
    - unresolved placeholders or assumptions.
11. Validate the final diff. Stage only initialization-related files.
12. When validation succeeds, create one local commit:

    `chore: initialize project context`

13. Tell the user to end the current Codex session and start a new session from the repository root so the new `AGENTS.md` is loaded as project guidance.

## Safety boundaries

- Do not push, merge, deploy, modify remote resources, or change global Codex configuration.
- Do not read or expose secrets.
- Do not add dependencies or create technical-stack directories such as `src/` or `tests/`.
- If the directory is not a Git repository, the bootstrap script may run `git init`; it must not configure remotes.

## Output

Report:

- repository root;
- files created, merged, skipped, and unresolved;
- commands discovered;
- validation performed;
- commit hash, if created;
- the required new-session step.

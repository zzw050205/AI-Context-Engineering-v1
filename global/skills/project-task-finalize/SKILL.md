---
name: project-task-finalize
description: Finalize a completed coding task that changed repository files by checking Git evidence, verification results, project-context updates, sensitive operations, precise staging, and a focused local commit. Do not use for read-only analysis or when no files changed.
---

# Project Task Finalization

Complete the quality, context, and Git steps for one finished development task.

## Trigger

Use after a task has produced repository file changes and the implementation is ready for completion review. The user may invoke `$project-task-finalize` explicitly. Do not use for planning, explanation, research, or read-only tasks.

## Procedure

1. Read the applicable global and project `AGENTS.md` instructions.
2. Restate the current task goal in one sentence.
3. Run `scripts/collect_change_evidence.sh` with the repository root.
4. Compare the current changes with the task goal and the pre-task worktree baseline available in the conversation.
5. Preserve unrelated pre-existing changes:
   - do not stash, clean, reset, restore, or overwrite them;
   - if current-task changes can be separated by path, continue with path-level staging;
   - if changes share a file and cannot be safely separated, stop and report the conflict.
6. Determine the task risk based on actual impact:
   - local and reversible;
   - feature or cross-module;
   - high-impact or hard to reverse.
7. Confirm that any high-impact change received user approval before implementation. If not, do not create a completion commit.
8. Verify the task using the real commands defined by project guidance and configuration:
   - run the smallest sufficient relevant checks;
   - include tests for changed behavior where practical;
   - do not hide, skip, delete, or weaken failing tests;
   - distinguish code failures from environment, dependency, external-service, and permission limitations.
9. Perform the knowledge-change check:

   a. Did the current project stage, objective, active work, known limitation, or next step materially change?
      - Update `.ai/current-state.md` by replacing stale state, not appending a log.

   b. Was a long-term decision confirmed by the user?
      - Create the next numbered file in `.ai/decisions/` using `assets/decision-template.md`.
      - Do not rewrite an accepted decision; create a superseding decision that links to it.

   c. Was non-obvious project knowledge added or changed that cannot be reliably recovered from code/config/Git and will be reused?
      - Update the smallest relevant file in `docs/`.

   d. Did a permanent project working rule change?
      - Propose an `AGENTS.md` diff and request confirmation. Do not apply it automatically.

10. Do not create or update documentation for routine fixes, temporary debugging, commit history, or information directly visible in code and configuration.
11. Check for sensitive or externally impactful changes:
    - secrets or credential files;
    - database migrations or real-data operations;
    - authentication/authorization;
    - production configuration;
    - public interfaces, core dependencies, deployment, network, remote resources, or paid actions.
12. Inspect the final unstaged and staged diff. Stage only paths that belong to the current task. Avoid `git add -A` unless every worktree change is confirmed to belong to this task.
13. Do not create a completion commit when:
    - relevant validation failed;
    - failure ownership is unclear;
    - high-impact approval is missing;
    - unrelated changes cannot be separated;
    - the implementation is incomplete.
14. When all conditions pass, create one local atomic commit using a clear Conventional Commit-style message.
15. Do not push, merge, rebase, deploy, force-push, or rewrite history.

## Output

Report concisely:

- implementation result;
- task risk classification and approvals used;
- verification commands and results;
- context files changed and why;
- files intentionally left uncommitted;
- commit hash and message;
- remaining limitations or unverified areas.

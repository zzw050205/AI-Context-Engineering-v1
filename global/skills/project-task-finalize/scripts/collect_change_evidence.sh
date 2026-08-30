#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: collect_change_evidence.sh [--project-root PATH]

Prints deterministic Git evidence for an agent. It does not modify the repository.
EOF
}

PROJECT_ROOT=""
while (($#)); do
  case "$1" in
    --project-root)
      [[ $# -ge 2 ]] || { echo "error: --project-root requires a path" >&2; exit 2; }
      PROJECT_ROOT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$PROJECT_ROOT" ]]; then
  PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
fi

if [[ -z "$PROJECT_ROOT" || ! -d "$PROJECT_ROOT" ]]; then
  echo "error: not inside a Git repository and no valid --project-root was provided" >&2
  exit 3
fi

PROJECT_ROOT="$(cd -- "$PROJECT_ROOT" && pwd)"
if ! git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: not a Git repository: $PROJECT_ROOT" >&2
  exit 3
fi

section() { printf '\n=== %s ===\n' "$1"; }

printf 'PROJECT_ROOT=%s\n' "$PROJECT_ROOT"
printf 'BRANCH=%s\n' "$(git -C "$PROJECT_ROOT" branch --show-current 2>/dev/null || true)"
printf 'HEAD=%s\n' "$(git -C "$PROJECT_ROOT" rev-parse --short HEAD 2>/dev/null || echo UNBORN)"

section "STATUS_SHORT"
git -C "$PROJECT_ROOT" status --short --untracked-files=all

section "UNSTAGED_NAME_STATUS"
git -C "$PROJECT_ROOT" diff --name-status

section "STAGED_NAME_STATUS"
git -C "$PROJECT_ROOT" diff --cached --name-status

section "UNTRACKED_FILES"
git -C "$PROJECT_ROOT" ls-files --others --exclude-standard

section "UNSTAGED_STAT"
git -C "$PROJECT_ROOT" diff --stat

section "STAGED_STAT"
git -C "$PROJECT_ROOT" diff --cached --stat

section "UNSTAGED_DIFF"
git -C "$PROJECT_ROOT" diff --no-ext-diff

section "STAGED_DIFF"
git -C "$PROJECT_ROOT" diff --cached --no-ext-diff

section "RECENT_COMMIT"
git -C "$PROJECT_ROOT" log -1 --oneline 2>/dev/null || echo "NO_COMMITS"

section "POTENTIALLY_SENSITIVE_PATHS"
{
  git -C "$PROJECT_ROOT" diff --name-only
  git -C "$PROJECT_ROOT" diff --cached --name-only
  git -C "$PROJECT_ROOT" ls-files --others --exclude-standard
} | sort -u | grep -Ei '(^|/)(\.env($|\.)|.*\.(pem|key|p12|pfx)$|id_rsa|credentials?|secrets?|prod(uction)?[._-]|migrations?/|auth(n|z)?/|permissions?/)' || true

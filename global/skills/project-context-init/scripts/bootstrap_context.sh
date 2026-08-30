#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bootstrap_context.sh [--project-root PATH]

Creates only missing files for the minimal project-context structure.
Existing non-empty files are preserved. Existing .gitignore content is preserved
and missing common rules are appended inside a marked block.
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

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
ASSETS_DIR="$SKILL_DIR/assets"

if [[ -z "$PROJECT_ROOT" ]]; then
  if git_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    PROJECT_ROOT="$git_root"
  else
    PROJECT_ROOT="$PWD"
  fi
fi

mkdir -p -- "$PROJECT_ROOT"
PROJECT_ROOT="$(cd -- "$PROJECT_ROOT" && pwd)"

if [[ "$PROJECT_ROOT" == "/" || "$PROJECT_ROOT" == "$HOME" ]]; then
  echo "error: refusing to initialize project context at unsafe root: $PROJECT_ROOT" >&2
  exit 3
fi

for required in project-AGENTS.md README.md current-state.md gitignore; do
  [[ -f "$ASSETS_DIR/$required" ]] || {
    echo "error: missing skill asset: $ASSETS_DIR/$required" >&2
    exit 4
  }
done

if ! git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C "$PROJECT_ROOT" init >/dev/null
  echo "INITIALIZED_GIT $PROJECT_ROOT"
else
  echo "EXISTING_GIT $PROJECT_ROOT"
fi

mkdir -p -- "$PROJECT_ROOT/.ai/decisions" "$PROJECT_ROOT/docs"

create_keep_if_missing() {
  local dest="$1"
  if [[ ! -e "$dest" ]]; then
    : > "$dest"
    echo "CREATED ${dest#$PROJECT_ROOT/}"
  else
    echo "PRESERVED ${dest#$PROJECT_ROOT/}"
  fi
}

create_keep_if_missing "$PROJECT_ROOT/.ai/decisions/.gitkeep"
create_keep_if_missing "$PROJECT_ROOT/docs/.gitkeep"

copy_if_missing() {
  local src="$1" dest="$2"
  if [[ ! -e "$dest" ]]; then
    cp -- "$src" "$dest"
    echo "CREATED ${dest#$PROJECT_ROOT/}"
  elif [[ ! -s "$dest" ]]; then
    cp -- "$src" "$dest"
    echo "FILLED_EMPTY ${dest#$PROJECT_ROOT/}"
  else
    echo "SKIPPED_NONEMPTY ${dest#$PROJECT_ROOT/}"
  fi
}

copy_if_missing "$ASSETS_DIR/project-AGENTS.md" "$PROJECT_ROOT/AGENTS.md"
copy_if_missing "$ASSETS_DIR/README.md" "$PROJECT_ROOT/README.md"
copy_if_missing "$ASSETS_DIR/current-state.md" "$PROJECT_ROOT/.ai/current-state.md"

GITIGNORE="$PROJECT_ROOT/.gitignore"
BLOCK_START="# BEGIN project-context common ignores"
BLOCK_END="# END project-context common ignores"

if [[ ! -e "$GITIGNORE" || ! -s "$GITIGNORE" ]]; then
  cp -- "$ASSETS_DIR/gitignore" "$GITIGNORE"
  echo "CREATED .gitignore"
elif grep -Fqx "$BLOCK_START" "$GITIGNORE"; then
  echo "SKIPPED_EXISTING_BLOCK .gitignore"
else
  {
    printf '\n%s\n' "$BLOCK_START"
    cat "$ASSETS_DIR/gitignore"
    printf '%s\n' "$BLOCK_END"
  } >> "$GITIGNORE"
  echo "APPENDED_COMMON_IGNORES .gitignore"
fi

echo "PROJECT_ROOT $PROJECT_ROOT"

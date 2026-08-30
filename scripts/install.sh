#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install.sh [--dry-run] [--apply]

Safely installs this package's global Codex AGENTS fragment and user-level skills.
Default behavior is --dry-run. Existing files are never overwritten without a
backup. For an existing ~/.codex/AGENTS.md, the script appends a marked block;
review the dry-run and resulting diff before applying.
EOF
}

MODE="dry-run"
while (($#)); do
  case "$1" in
    --dry-run) MODE="dry-run"; shift ;;
    --apply) MODE="apply"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
SOURCE_AGENTS="$PACKAGE_ROOT/global/AGENTS.md"
SOURCE_SKILLS="$PACKAGE_ROOT/global/skills"
TARGET_CODEX="$HOME/.codex"
TARGET_AGENTS="$TARGET_CODEX/AGENTS.md"
TARGET_SKILLS="$HOME/.agents/skills"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BLOCK_START="# BEGIN AI-Context-Engineering-v1"
BLOCK_END="# END AI-Context-Engineering-v1"

[[ -f "$SOURCE_AGENTS" ]] || { echo "error: missing $SOURCE_AGENTS" >&2; exit 3; }
for skill in project-context-init project-task-finalize; do
  [[ -f "$SOURCE_SKILLS/$skill/SKILL.md" ]] || { echo "error: missing skill $skill" >&2; exit 3; }
done

say() { printf '%s\n' "$*"; }
do_cmd() {
  if [[ "$MODE" == "dry-run" ]]; then
    printf 'DRY_RUN:'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

say "MODE=$MODE"
say "PACKAGE_ROOT=$PACKAGE_ROOT"
say "TARGET_AGENTS=$TARGET_AGENTS"
say "TARGET_SKILLS=$TARGET_SKILLS"

do_cmd mkdir -p -- "$TARGET_CODEX" "$TARGET_SKILLS"

if [[ -f "$TARGET_AGENTS" ]]; then
  if grep -Fqx "$BLOCK_START" "$TARGET_AGENTS"; then
    say "SKIP: managed AGENTS block already exists; review and update manually."
  else
    backup="$TARGET_AGENTS.backup-$TIMESTAMP"
    say "BACKUP: $TARGET_AGENTS -> $backup"
    do_cmd cp -p -- "$TARGET_AGENTS" "$backup"
    if [[ "$MODE" == "dry-run" ]]; then
      say "APPEND: managed AGENTS block to $TARGET_AGENTS"
    else
      {
        [[ ! -s "$TARGET_AGENTS" ]] || printf '\n'
        printf '%s\n' "$BLOCK_START"
        cat "$SOURCE_AGENTS"
        printf '%s\n' "$BLOCK_END"
      } >> "$TARGET_AGENTS"
    fi
  fi
else
  say "CREATE: $TARGET_AGENTS"
  if [[ "$MODE" == "apply" ]]; then
    {
      printf '%s\n' "$BLOCK_START"
      cat "$SOURCE_AGENTS"
      printf '%s\n' "$BLOCK_END"
    } > "$TARGET_AGENTS"
  fi
fi

for skill in project-context-init project-task-finalize; do
  src="$SOURCE_SKILLS/$skill"
  dest="$TARGET_SKILLS/$skill"
  if [[ -e "$dest" ]]; then
    backup="$dest.backup-$TIMESTAMP"
    say "BACKUP: $dest -> $backup"
    [[ ! -e "$backup" ]] || { echo "error: backup already exists: $backup" >&2; exit 4; }
    do_cmd mv -- "$dest" "$backup"
    say "REPLACE: $dest"
    if [[ "$MODE" == "apply" ]]; then
      cp -R -p -- "$src" "$dest"
    fi
  else
    say "CREATE: $dest"
    do_cmd cp -R -p -- "$src" "$dest"
  fi
  if [[ "$MODE" == "apply" ]]; then
    find "$dest/scripts" -type f -name '*.sh' -exec chmod +x {} + 2>/dev/null || true
  fi
done

say "DONE: restart Codex if the skills or global instructions do not appear immediately."

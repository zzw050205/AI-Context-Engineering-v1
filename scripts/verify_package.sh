#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

required=(
  "README.md"
  "IMPLEMENTATION.md"
  "USER_GUIDE.md"
  "CODEX_INSTALL_PROMPT.md"
  "global/AGENTS.md"
  "global/skills/project-context-init/SKILL.md"
  "global/skills/project-context-init/agents/openai.yaml"
  "global/skills/project-context-init/scripts/bootstrap_context.sh"
  "global/skills/project-task-finalize/SKILL.md"
  "global/skills/project-task-finalize/agents/openai.yaml"
  "global/skills/project-task-finalize/scripts/collect_change_evidence.sh"
  "project-template/AGENTS.md"
  "project-template/.ai/current-state.md"
)

for path in "${required[@]}"; do
  [[ -f "$ROOT/$path" ]] || { echo "MISSING $path" >&2; exit 1; }
done

while IFS= read -r -d '' script; do
  bash -n "$script"
  echo "BASH_OK ${script#$ROOT/}"
done < <(find "$ROOT" -type f -name '*.sh' -print0)

python3 - "$ROOT" <<'PY'
from pathlib import Path
import re
import sys
root = Path(sys.argv[1])
skills = {
    'project-context-init': False,
    'project-task-finalize': True,
}
for skill, implicit in skills.items():
    rel = f'global/skills/{skill}/SKILL.md'
    text = (root / rel).read_text(encoding='utf-8')
    assert text.startswith('---\n'), f'{rel}: missing frontmatter'
    end = text.find('\n---\n', 4)
    assert end != -1, f'{rel}: unterminated frontmatter'
    fm = text[4:end]
    name = re.search(r'^name:\s*(\S+)\s*$', fm, re.MULTILINE)
    description = re.search(r'^description:\s*(.+)\s*$', fm, re.MULTILINE)
    assert name and name.group(1) == skill, f'{rel}: invalid name'
    assert description and description.group(1).strip(), f'{rel}: missing description'
    print(f'SKILL_OK {rel}')

    yaml_rel = f'global/skills/{skill}/agents/openai.yaml'
    yaml_text = (root / yaml_rel).read_text(encoding='utf-8')
    assert re.search(r'^interface:\s*$', yaml_text, re.MULTILINE), f'{yaml_rel}: missing interface'
    for key in ('display_name', 'short_description', 'default_prompt'):
        assert re.search(rf'^  {key}:\s*"[^"]+"\s*$', yaml_text, re.MULTILINE), f'{yaml_rel}: invalid {key}'
    expected = str(implicit).lower()
    assert re.search(r'^policy:\s*$', yaml_text, re.MULTILINE), f'{yaml_rel}: missing policy'
    assert re.search(rf'^  allow_implicit_invocation:\s*{expected}\s*$', yaml_text, re.MULTILINE), f'{yaml_rel}: invalid invocation policy'
    print(f'AGENT_YAML_OK {yaml_rel}')
PY

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/repo"

git -C "$TMP/repo" init -q
printf 'existing-line\n' > "$TMP/repo/.gitignore"
printf '# Existing README\n' > "$TMP/repo/README.md"

mkdir -p "$TMP/repo/.ai/decisions" "$TMP/repo/docs"
printf 'preserve-decisions\n' > "$TMP/repo/.ai/decisions/.gitkeep"
printf 'preserve-docs\n' > "$TMP/repo/docs/.gitkeep"

"$ROOT/global/skills/project-context-init/scripts/bootstrap_context.sh" --project-root "$TMP/repo" > "$TMP/first.txt"
"$ROOT/global/skills/project-context-init/scripts/bootstrap_context.sh" --project-root "$TMP/repo" > "$TMP/second.txt"

grep -Fq 'existing-line' "$TMP/repo/.gitignore"
grep -Fq '# Existing README' "$TMP/repo/README.md"
[[ -s "$TMP/repo/AGENTS.md" ]]
[[ -s "$TMP/repo/.ai/current-state.md" ]]
[[ -d "$TMP/repo/.ai/decisions" ]]
[[ -d "$TMP/repo/docs" ]]
grep -Fqx 'preserve-decisions' "$TMP/repo/.ai/decisions/.gitkeep"
grep -Fqx 'preserve-docs' "$TMP/repo/docs/.gitkeep"
[[ "$(grep -Fxc '# BEGIN project-context common ignores' "$TMP/repo/.gitignore")" -eq 1 ]]

git -C "$TMP/repo" add -- AGENTS.md README.md .gitignore .ai docs
git -C "$TMP/repo" -c user.name='Package Test' -c user.email='package-test@example.invalid' commit -qm 'chore: baseline'

printf 'changed\n' >> "$TMP/repo/README.md"
printf 'staged\n' > "$TMP/repo/staged.txt"
git -C "$TMP/repo" add -- staged.txt
printf 'untracked\n' > "$TMP/repo/untracked.txt"
"$ROOT/global/skills/project-task-finalize/scripts/collect_change_evidence.sh" --project-root "$TMP/repo" > "$TMP/evidence.txt"
grep -Fq 'BRANCH=' "$TMP/evidence.txt"
grep -Fq 'STATUS_SHORT' "$TMP/evidence.txt"
grep -Fq 'UNSTAGED_DIFF' "$TMP/evidence.txt"
grep -Fq '+changed' "$TMP/evidence.txt"
grep -Fq 'STAGED_DIFF' "$TMP/evidence.txt"
grep -Fq '+staged' "$TMP/evidence.txt"
grep -Fq 'UNTRACKED_FILES' "$TMP/evidence.txt"
grep -Fq 'untracked.txt' "$TMP/evidence.txt"
grep -Fq 'RECENT_COMMIT' "$TMP/evidence.txt"
grep -Fq 'chore: baseline' "$TMP/evidence.txt"

echo "INTEGRATION_OK temporary repository"
echo "PACKAGE_OK $ROOT"

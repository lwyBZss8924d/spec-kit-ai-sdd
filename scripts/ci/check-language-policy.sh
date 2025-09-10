#!/usr/bin/env bash
# Enforce English-only policy for normative artifacts

set -euo pipefail

echo "[LANG] Reminder: All normative artifacts (PRDs, specifications, implementation plans, issues, task plans) must be written in English."

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

# Files to check: normative artifacts in specs/ and key templates
mapfile -t FILES < <({ \
  find specs -type f \( -name 'spec.md' -o -name 'plan.md' -o -name 'tasks.md' \) -print 2>/dev/null || true; \
  find templates -maxdepth 1 -type f -name '*-template.md' -print 2>/dev/null || true; \
} )

violations=0

check_file() {
  local file="$1"
  # Python-based detection to reliably catch non-ASCII while ignoring code blocks
  python3 - "$file" <<'PY'
import sys, re
path = sys.argv[1]
text = open(path, 'r', encoding='utf-8', errors='ignore').read()
# Remove fenced code blocks crudely to reduce false positives
clean = re.sub(r"```[\s\S]*?```", "", text)
violations = []
import unicodedata as ud
for i, line in enumerate(clean.splitlines(), 1):
# Violation if line contains non-ASCII letters (ignore symbols/emoji/marks)
    if any(ord(ch) > 127 and ud.category(ch)[0] in {'L'} for ch in line):
        violations.append((i, line.strip()))
if violations:
    print(path)
    for ln, content in violations[:10]:
        # Print first 10 offending lines for brevity
        print(f"  L{ln}: {content[:120]}")
    sys.exit(1)
PY
}

for f in "${FILES[@]}"; do
  if ! check_file "$f"; then
    violations=1
  fi
done

if [[ $violations -ne 0 ]]; then
  echo "[LANG] Policy violations found (non-English letters detected)." >&2
  echo "[LANG] How to fix: ensure specs/plan/tasks/docs are authored in English; replace non-English text or move translations outside normative artifacts." >&2
  exit 1
fi

echo "[LANG] Language policy check passed"

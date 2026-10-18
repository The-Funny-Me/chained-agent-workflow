#!/usr/bin/env bash
# Copy contents/ into Cursor's user skill directory.
# Usage: ./unpack.sh
# Override the destination root with CURSOR_SKILLS_DIR.

set -euo pipefail

readonly SKILL_NAME="chained-agent-workflow"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONTENTS_DIR="${SCRIPT_DIR}/contents"
readonly CURSOR_SKILLS_DIR="${CURSOR_SKILLS_DIR:-${HOME}/.cursor/skills}"
readonly TARGET_DIR="${CURSOR_SKILLS_DIR}/${SKILL_NAME}"

if [[ ! -d "${CONTENTS_DIR}" ]]; then
  echo "error: contents directory not found at ${CONTENTS_DIR}" >&2
  exit 1
fi

if [[ ! -f "${CONTENTS_DIR}/SKILL.md" ]]; then
  echo "error: ${CONTENTS_DIR}/SKILL.md is missing, so there is nothing to install" >&2
  exit 1
fi

mkdir -p "${CURSOR_SKILLS_DIR}"

if [[ -e "${TARGET_DIR}" ]]; then
  rm -rf "${TARGET_DIR}"
fi

mkdir -p "${TARGET_DIR}"
cp -a "${CONTENTS_DIR}/." "${TARGET_DIR}/"

if [[ ! -f "${TARGET_DIR}/SKILL.md" ]]; then
  echo "error: install did not produce ${TARGET_DIR}/SKILL.md" >&2
  exit 1
fi

echo "Installed /${SKILL_NAME}"
echo "  ${TARGET_DIR}"
echo "Open a new Agent chat and invoke /${SKILL_NAME}."

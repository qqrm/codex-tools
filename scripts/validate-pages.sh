#!/usr/bin/env bash
# Validate that the generated GitHub Pages artifact contains the required files.

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR%/scripts}"
OUTPUT_DIR="${1:-${REPO_ROOT}/public}"
OUTPUT_DIR="${OUTPUT_DIR%/}"

if [[ ! -d "${OUTPUT_DIR}" ]]; then
  echo "Error: output directory ${OUTPUT_DIR} does not exist." >&2
  exit 1
fi

missing=0
check_path() {
  local relative_path="$1"
  local path="${OUTPUT_DIR}/${relative_path}"
  if [[ ! -s "${path}" ]]; then
    echo "Missing or empty artifact: ${relative_path}" >&2
    missing=1
  fi
}

# Files and JSON artifacts that must remain present and non-empty
required_paths=(
  static.json
  index.md
  index.json
  entrypoint.json
  skills.json
  ENTRYPOINT.md
  personas/catalog.json
  personas.json
  skills/catalog.json
  skills/index.json
  scenarios/catalog.json
  scenarios/index.json
  scenarios.json
  docs/index.json
  scripts/index.json
  workflows/index.json
)

shopt -s nullglob
for root_markdown in "${REPO_ROOT}"/*.md; do
  required_paths+=("$(basename "${root_markdown}")")
done

for doc_path in "${REPO_ROOT}"/docs/*.md; do
  required_paths+=("docs/$(basename "${doc_path}")")
done

for persona_path in "${REPO_ROOT}"/personas/*.md; do
  required_paths+=("personas/$(basename "${persona_path}")")
done

for skill_path in "${REPO_ROOT}"/skills/*.md; do
  required_paths+=("skills/$(basename "${skill_path}")")
done

for scenario_path in "${REPO_ROOT}"/scenarios/*.md; do
  required_paths+=("scenarios/$(basename "${scenario_path}")")
done

for script_path in "${REPO_ROOT}"/scripts/*.sh; do
  required_paths+=("scripts/$(basename "${script_path}")")
done

for workflow_path in "${REPO_ROOT}"/.github/workflows/*.yml; do
  required_paths+=("workflows/$(basename "${workflow_path}")")
done

for relative_path in "${required_paths[@]}"; do
  check_path "${relative_path}"
done

if command -v jq >/dev/null 2>&1; then
  if ! jq -e '
    (.capabilities | has("scripts") | not) and
    (.catalogs | has("scripts") | not) and
    (has("bootstrap") | not) and
    (.published | has("scripts") | not) and
    (.baseline | has("readme") | not)
  ' "${OUTPUT_DIR}/index.json" > /dev/null; then
    echo "Root discovery manifest must not expose scripts or README as part of the cold-start API." >&2
    missing=1
  fi
fi

legacy_paths=(
  scripts/split-initialization-cached-base.sh
  scripts/full-initialization.sh
  scripts/split-initialization-pretask.sh
  scripts/init-container.sh
  scripts/init-ephemeral-container.sh
  scripts/pre-task.sh
  scripts/lib/container-bootstrap-common.sh
  scripts/agent-sync.sh
  scripts/repo-setup.sh
)

for relative_path in "${legacy_paths[@]}"; do
  if [[ -e "${OUTPUT_DIR}/${relative_path}" ]]; then
    echo "Legacy artifact should not be published: ${relative_path}" >&2
    missing=1
  fi
done

if [[ ${missing} -ne 0 ]]; then
  echo "Pages artifact validation failed." >&2
  exit 1
fi

echo "Pages artifact validation passed." >&2

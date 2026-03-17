#!/usr/bin/env bash
# Build the GitHub Pages artifact into the provided output directory.
# Mirrors the packaging performed during CI deployments so local builds
# and validation remain consistent.

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR%/scripts}"
if [[ ! -d "${REPO_ROOT}/.git" ]]; then
  echo "Error: build-pages.sh must run from within the repository." >&2
  exit 1
fi

OUTPUT_DIR="${1:-${REPO_ROOT}/public}"
OUTPUT_DIR="${OUTPUT_DIR%/}"
if [[ -z "${OUTPUT_DIR}" || "${OUTPUT_DIR}" == "/" ]]; then
  echo "Error: refusing to operate on empty or root output directory." >&2
  exit 1
fi

rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"

copy_file() {
  local src="$1"
  local dest="$2"
  if [[ ! -f "${src}" ]]; then
    echo "Error: expected file ${src} missing." >&2
    exit 1
  fi
  install -m 0644 "${src}" "${dest}"
}

copy_executable() {
  local src="$1"
  local dest="$2"
  if [[ ! -f "${src}" ]]; then
    echo "Error: expected executable ${src} missing." >&2
    exit 1
  fi
  install -m 0755 "${src}" "${dest}"
}

emit_json_array() {
  local item_indent="$1"
  local closing_indent="$2"
  shift 2
  local items=("$@")
  local first=1
  local item
  printf '['
  for item in "${items[@]}"; do
    if [[ ${first} -eq 1 ]]; then
      printf '\n%s"%s"' "${item_indent}" "${item}"
      first=0
    else
      printf ',\n%s"%s"' "${item_indent}" "${item}"
    fi
  done
  if [[ ${first} -eq 0 ]]; then
    printf '\n%s' "${closing_indent}"
  fi
  printf ']'
}

slugify_name() {
  local value="$1"
  value="${value,,}"
  value="${value// /_}"
  value="${value//-/_}"
  printf '%s' "${value}"
}

humanize_name() {
  local value="$1"
  value="${value//_/ }"
  value="${value//-/ }"
  printf '%s' "${value}"
}

emit_path_object_array() {
  local item_indent="$1"
  local closing_indent="$2"
  local kind="$3"
  shift 3
  local items=("$@")
  local first=1
  local item
  printf '['
  for item in "${items[@]}"; do
    local file_name="${item##*/}"
    local stem="${file_name%.*}"
    local id
    local title
    id="$(slugify_name "${stem}")"
    title="$(humanize_name "${stem}")"
    if [[ ${first} -eq 1 ]]; then
      printf '\n%s{' "${item_indent}"
      first=0
    else
      printf ',\n%s{' "${item_indent}"
    fi
    printf '\n%s  "id": "%s",' "${item_indent}" "${id}"
    printf '\n%s  "title": "%s",' "${item_indent}" "${title}"
    printf '\n%s  "kind": "%s",' "${item_indent}" "${kind}"
    printf '\n%s  "uri": "%s"' "${item_indent}" "${item}"
    printf '\n%s}' "${item_indent}"
  done
  if [[ ${first} -eq 0 ]]; then
    printf '\n%s' "${closing_indent}"
  fi
  printf ']'
}

refresh_personas_catalog() {
  local catalog_target="${REPO_ROOT}/personas/catalog.json"
  if [[ -n "${PERSONAS_CATALOG_SOURCE:-}" ]]; then
    if [[ ! -f "${PERSONAS_CATALOG_SOURCE}" ]]; then
      echo "Error: PERSONAS_CATALOG_SOURCE (${PERSONAS_CATALOG_SOURCE}) not found." >&2
      exit 1
    fi
    if [[ "$(cd "$(dirname "${PERSONAS_CATALOG_SOURCE}")" && pwd)/$(basename "${PERSONAS_CATALOG_SOURCE}")" == "${catalog_target}" ]]; then
      return
    fi
    install -m 0644 "${PERSONAS_CATALOG_SOURCE}" "${catalog_target}"
    return
  fi

  if ! command -v cargo >/dev/null 2>&1; then
    echo "Error: cargo is required to regenerate personas/catalog.json." >&2
    exit 1
  fi

  (cd "${REPO_ROOT}" && cargo run --release -p personas-core)
}

# Personas and catalogs
refresh_personas_catalog
mkdir -p "${OUTPUT_DIR}/personas"
cp -a "${REPO_ROOT}/personas/." "${OUTPUT_DIR}/personas/"

# Scenarios
mkdir -p "${OUTPUT_DIR}/scenarios"
cp -a "${REPO_ROOT}/scenarios/." "${OUTPUT_DIR}/scenarios/"

# Shared markdown artifacts
shopt -s nullglob
root_markdown_paths=()
for root_markdown in "${REPO_ROOT}"/*.md; do
  root_markdown_name="$(basename "${root_markdown}")"
  root_markdown_paths+=("/${root_markdown_name}")
  copy_file "${root_markdown}" "${OUTPUT_DIR}/${root_markdown_name}"
done

mkdir -p "${OUTPUT_DIR}/docs"
cp -a "${REPO_ROOT}/docs/." "${OUTPUT_DIR}/docs/"
copy_file "${REPO_ROOT}/docs/AGENT_ENTRYPOINT.md" "${OUTPUT_DIR}/ENTRYPOINT.md"

docs_paths=()
for doc_path in "${REPO_ROOT}"/docs/*.md; do
  docs_paths+=("/docs/$(basename "${doc_path}")")
done

# Pages configuration
copy_file "${REPO_ROOT}/static.json" "${OUTPUT_DIR}/static.json"

# Published shell scripts
mkdir -p "${OUTPUT_DIR}/scripts"
scripts_paths=()
for script_path in "${REPO_ROOT}"/scripts/*.sh; do
  script_name="$(basename "${script_path}")"
  scripts_paths+=("/scripts/${script_name}")
  copy_executable "${script_path}" "${OUTPUT_DIR}/scripts/${script_name}"
done

# Workflows
mkdir -p "${OUTPUT_DIR}/workflows"
cp -a "${REPO_ROOT}/.github/workflows/." "${OUTPUT_DIR}/workflows/"
workflow_paths=()
for workflow_path in "${REPO_ROOT}"/.github/workflows/*.yml; do
  workflow_paths+=("/workflows/$(basename "${workflow_path}")")
done

persona_paths=()
for persona_path in "${REPO_ROOT}"/personas/*.md; do
  persona_paths+=("/personas/$(basename "${persona_path}")")
done

scenario_paths=()
for scenario_path in "${REPO_ROOT}"/scenarios/*.md; do
  scenario_paths+=("/scenarios/$(basename "${scenario_path}")")
done

# Catalog copies
copy_file "${OUTPUT_DIR}/personas/catalog.json" "${OUTPUT_DIR}/personas.json"
copy_file "${OUTPUT_DIR}/scenarios/catalog.json" "${OUTPUT_DIR}/scenarios/index.json"
copy_file "${OUTPUT_DIR}/scenarios/catalog.json" "${OUTPUT_DIR}/scenarios.json"

# Machine-readable subcatalogs
{
  printf '{\n'
  printf '  "version": 1,\n'
  printf '  "kind": "docs_catalog",\n'
  printf '  "items": '
  emit_path_object_array '      ' '    ' 'guide' "${docs_paths[@]}"
  printf '\n'
  printf '}\n'
} > "${OUTPUT_DIR}/docs/index.json"

{
  printf '{\n'
  printf '  "version": 1,\n'
  printf '  "kind": "scripts_catalog",\n'
  printf '  "items": '
  emit_path_object_array '      ' '    ' 'script' "${scripts_paths[@]}"
  printf '\n'
  printf '}\n'
} > "${OUTPUT_DIR}/scripts/index.json"

{
  printf '{\n'
  printf '  "version": 1,\n'
  printf '  "kind": "workflows_catalog",\n'
  printf '  "items": '
  emit_path_object_array '      ' '    ' 'workflow' "${workflow_paths[@]}"
  printf '\n'
  printf '}\n'
} > "${OUTPUT_DIR}/workflows/index.json"

{
  printf '{\n'
  printf '  "version": 1,\n'
  printf '  "base_uri": "/AGENTS.md",\n'
  printf '  "description": "Reusable prompt assets, guides, and playbooks exposed by this bundle.",\n'
  printf '  "catalogs": {\n'
  printf '    "docs": "/docs/index.json",\n'
  printf '    "scenarios": "/scenarios.json",\n'
  printf '    "personas": "/personas.json"\n'
  printf '  },\n'
  printf '  "baseline_guides": '
  emit_path_object_array '      ' '    ' 'baseline' "${root_markdown_paths[@]}"
  printf ',\n'
  printf '  "shared_guides": '
  emit_path_object_array '      ' '    ' 'guide' "${docs_paths[@]}"
  printf ',\n'
  printf '  "scenario_playbooks": '
  emit_path_object_array '      ' '    ' 'scenario' "${scenario_paths[@]}"
  printf '\n'
  printf '}\n'
} > "${OUTPUT_DIR}/skills.json"

# Discovery manifest
{
  printf '{\n'
  printf '  "version": 3,\n'
  printf '  "base_request": "/",\n'
  printf '  "root_manifest": "/index.json",\n'
  printf '  "entrypoint": "/entrypoint.json",\n'
  printf '  "description": "Cold-start discovery manifest for the published Codex Tools bundle.",\n'
  printf '  "baseline": {\n'
  printf '    "shared": "/AGENTS.md",\n'
  printf '    "bootstrap": "/ENTRYPOINT.md",\n'
  printf '    "repo": "/REPO_AGENTS.md",\n'
  printf '    "readme": "/README.md",\n'
  printf '    "prompt_generation": "/docs/PROMPT_GENERATION.md"\n'
  printf '  },\n'
  printf '  "capabilities": {\n'
  printf '    "personas": "Specialized working modes for different delivery roles.",\n'
  printf '    "scenarios": "Task playbooks for repeatable execution flows.",\n'
  printf '    "skills": "Combined guides and playbooks that agents can load on demand.",\n'
  printf '    "docs": "Shared public instructions, tool references, and specifications.",\n'
  printf '    "scripts": "Bootstrap and validation entry points.",\n'
  printf '    "workflows": "Published CI/CD definitions for inspection and reuse."\n'
  printf '  },\n'
  printf '  "catalogs": {\n'
  printf '    "personas": "/personas.json",\n'
  printf '    "scenarios": "/scenarios.json",\n'
  printf '    "skills": "/skills.json",\n'
  printf '    "docs": "/docs/index.json",\n'
  printf '    "scripts": "/scripts/index.json",\n'
  printf '    "workflows": "/workflows/index.json"\n'
  printf '  },\n'
  printf '  "bootstrap": {\n'
  printf '    "base": "/scripts/BaseInitialization.sh",\n'
  printf '    "full": "/scripts/FullInitialization.sh",\n'
  printf '    "pretask": "/scripts/PretaskInitialization.sh"\n'
  printf '  },\n'
  printf '  "discovery_order": [\n'
  printf '    "/",\n'
  printf '    "/AGENTS.md",\n'
  printf '    "/skills.json",\n'
  printf '    "/personas.json",\n'
  printf '    "/scenarios.json"\n'
  printf '  ],\n'
  printf '  "published": {\n'
  printf '    "root_markdown": '
  emit_json_array '      ' '    ' "${root_markdown_paths[@]}"
  printf ',\n'
  printf '    "docs": '
  emit_json_array '      ' '    ' "${docs_paths[@]}"
  printf ',\n'
  printf '    "personas": '
  emit_json_array '      ' '    ' "${persona_paths[@]}"
  printf ',\n'
  printf '    "scenarios": '
  emit_json_array '      ' '    ' "${scenario_paths[@]}"
  printf ',\n'
  printf '    "scripts": '
  emit_json_array '      ' '    ' "${scripts_paths[@]}"
  printf ',\n'
  printf '    "workflows": '
  emit_json_array '      ' '    ' "${workflow_paths[@]}"
  printf '\n'
  printf '  },\n'
  printf '  "resolution_order": [\n'
  printf '    "repo_local_agents",\n'
  printf '    "repo_current_state",\n'
  printf '    "repo_done_criteria",\n'
  printf '    "shared_baseline",\n'
  printf '    "selected_persona",\n'
  printf '    "selected_scenarios"\n'
  printf '  ],\n'
  printf '  "mcp_policy": {\n'
  printf '    "preferred_order": [\n'
  printf '      "repo_search",\n'
  printf '      "task_memory",\n'
  printf '      "browser",\n'
  printf '      "shared_docs"\n'
  printf '    ]\n'
  printf '  },\n'
  printf '  "final_report": [\n'
  printf '    "what changed",\n'
  printf '    "what was validated",\n'
  printf '    "what remains uncertain"\n'
  printf '  ]\n'
  printf '}\n'
} > "${OUTPUT_DIR}/entrypoint.json"
copy_file "${OUTPUT_DIR}/entrypoint.json" "${OUTPUT_DIR}/index.json"

# Landing page markdown
{
  echo "# Codex Tools"
  echo
  echo "Published bundle: https://qqrm.github.io/codex-tools/"
  echo
  echo "## Base discovery"
  echo "- [index.json](index.json)"
  echo "- [entrypoint.json](entrypoint.json)"
  echo "- [skills.json](skills.json)"
  echo "- [ENTRYPOINT](ENTRYPOINT.md)"
  echo "- [AGENTS](AGENTS.md)"
  echo
  echo "## Root Markdown"
  for root_path in "${root_markdown_paths[@]}"; do
    root_name="${root_path#/}"
    echo "- [${root_name}](${root_name})"
  done
  echo
  echo "## Shared Docs"
  echo "- [catalog](docs/index.json)"
  for doc_path in "${docs_paths[@]}"; do
    doc_name="${doc_path#/docs/}"
    echo "- [${doc_name}](docs/${doc_name})"
  done
  echo
  echo "## Personas"
  echo "- [catalog](personas.json)"
  for persona_path in "${REPO_ROOT}"/personas/*.md; do
    persona_name="$(basename "${persona_path}")"
    echo "- [${persona_name%.*}](personas/${persona_name})"
  done
  echo
  echo "## Scenarios"
  echo "- [catalog](scenarios.json)"
  for scenario_path in "${REPO_ROOT}"/scenarios/*.md; do
    scenario_name="$(basename "${scenario_path}")"
    echo "- [${scenario_name%.*}](scenarios/${scenario_name})"
  done
  echo
  echo "## Scripts"
  echo "- [catalog](scripts/index.json)"
  for script_path in "${REPO_ROOT}"/scripts/*.sh; do
    script_name="$(basename "${script_path}")"
    echo "- [${script_name}](scripts/${script_name})"
  done
  echo
  echo "## Workflows"
  echo "- [catalog](workflows/index.json)"
  for workflow_path in "${REPO_ROOT}"/.github/workflows/*.yml; do
    workflow_name="$(basename "${workflow_path}")"
    echo "- [${workflow_name}](workflows/${workflow_name})"
  done
} > "${OUTPUT_DIR}/index.md"

# Disable Jekyll processing
: > "${OUTPUT_DIR}/.nojekyll"

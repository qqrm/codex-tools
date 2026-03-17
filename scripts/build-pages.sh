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

refresh_skills_catalog() {
  local skills_dir="${REPO_ROOT}/skills"
  local scenarios_dir="${REPO_ROOT}/scenarios"
  local catalog_target="${skills_dir}/catalog.json"

  if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 is required to regenerate skills/catalog.json." >&2
    exit 1
  fi

  REPO_ROOT="${REPO_ROOT}" \
  SKILLS_DIR="${skills_dir}" \
  SCENARIOS_DIR="${scenarios_dir}" \
  CATALOG_TARGET="${catalog_target}" \
  python3 <<'PY_SKILLS'
import json
import os
import pathlib
import sys

repo_root = pathlib.Path(os.environ["REPO_ROOT"])
skills_dir = pathlib.Path(os.environ["SKILLS_DIR"])
scenarios_dir = pathlib.Path(os.environ["SCENARIOS_DIR"])
catalog_target = pathlib.Path(os.environ["CATALOG_TARGET"])
base_url = os.environ.get("PAGES_BASE_URL", "https://qqrm.github.io/codex-tools").rstrip("/")


def fail(message: str) -> None:
    print(f"Error: {message}", file=sys.stderr)
    raise SystemExit(1)


def parse_scalar(value: str) -> str:
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {'"', "'"}:
        return value[1:-1]
    return value


def parse_inline_list(value: str, source: pathlib.Path, line_number: int) -> list[str]:
    value = value.strip()
    if value == "[]":
        return []
    if not (value.startswith("[") and value.endswith("]")):
        fail(f"expected inline list in {source}:{line_number}: {value}")
    inner = value[1:-1].strip()
    if not inner:
        return []
    items = []
    for raw_item in inner.split(","):
        item = parse_scalar(raw_item.strip())
        if not item:
            fail(f"empty list item in {source}:{line_number}")
        items.append(item)
    return items


def parse_front_matter(content: str, source: pathlib.Path) -> dict[str, object]:
    normalized = content.replace("\r\n", "\n")
    if normalized.startswith("\ufeff"):
        normalized = normalized[1:]
    if not normalized.startswith("---\n"):
        fail(f"skill front matter missing in {source}")
    remainder = normalized[4:]
    marker = remainder.find("\n---")
    if marker < 0:
        fail(f"skill front matter malformed in {source}")
    yaml_block = remainder[:marker].strip()
    metadata: dict[str, object] = {}
    for line_number, raw_line in enumerate(yaml_block.splitlines(), start=1):
        line = raw_line.strip()
        if not line:
            continue
        if ":" not in line:
            fail(f"unsupported YAML line in {source}:{line_number}: {raw_line}")
        key, value = line.split(":", 1)
        key = key.strip()
        value = value.strip()
        if key in {"tags", "recommended_personas"}:
            metadata[key] = parse_inline_list(value, source, line_number)
        else:
            metadata[key] = parse_scalar(value)
    return metadata


if not skills_dir.is_dir():
    fail(f"skills directory missing: {skills_dir}")
if not scenarios_dir.is_dir():
    fail(f"scenarios directory missing: {scenarios_dir}")
if not (repo_root / "AGENTS.md").is_file():
    fail(f"AGENTS.md missing: {repo_root / 'AGENTS.md'}")

entries: list[dict[str, object]] = []
seen_ids: dict[str, pathlib.Path] = {}
required_fields = [
    "id",
    "name",
    "description",
    "tags",
    "author",
    "created_at",
    "version",
    "recommended_personas",
    "playbook_uri",
]

for skill_path in sorted(skills_dir.glob("*.md")):
    metadata = parse_front_matter(skill_path.read_text(encoding="utf-8"), skill_path)
    missing = [field for field in required_fields if field not in metadata]
    if missing:
        fail(f"missing required fields in {skill_path}: {', '.join(missing)}")

    skill_id = str(metadata["id"])
    if skill_id in seen_ids:
        fail(
            f"duplicate skill id `{skill_id}` found in {skill_path} "
            f"(already defined in {seen_ids[skill_id]})"
        )
    seen_ids[skill_id] = skill_path

    playbook_uri = str(metadata["playbook_uri"])
    if playbook_uri.startswith("/"):
        scenario_path = repo_root / playbook_uri.lstrip("/")
        if not scenario_path.is_file():
            fail(f"playbook_uri target missing for {skill_path}: {playbook_uri}")
        published_playbook_uri = f"{base_url}{playbook_uri}"
    elif playbook_uri.startswith("http://") or playbook_uri.startswith("https://"):
        published_playbook_uri = playbook_uri
    else:
        fail(
            f"playbook_uri must be absolute URL or root-relative path in {skill_path}: "
            f"{playbook_uri}"
        )

    relative_uri = "/" + skill_path.relative_to(repo_root).as_posix()
    entries.append(
        {
            "id": skill_id,
            "name": str(metadata["name"]),
            "description": str(metadata["description"]),
            "tags": list(metadata["tags"]),
            "author": str(metadata["author"]),
            "created_at": str(metadata["created_at"]),
            "version": str(metadata["version"]),
            "recommended_personas": list(metadata["recommended_personas"]),
            "playbook_uri": published_playbook_uri,
            "uri": f"{base_url}{relative_uri}",
        }
    )

entries.sort(key=lambda item: item["id"])
output = {
    "base_uri": "AGENTS.md",
    "skills": entries,
}
catalog_target.write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY_SKILLS
}

# Personas and catalogs
refresh_personas_catalog
refresh_skills_catalog
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

# Skills
mkdir -p "${OUTPUT_DIR}/skills"
cp -a "${REPO_ROOT}/skills/." "${OUTPUT_DIR}/skills/"

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

skills_paths=()
for skill_path in "${REPO_ROOT}"/skills/*.md; do
  skills_paths+=("/skills/$(basename "${skill_path}")")
done

scenario_paths=()
for scenario_path in "${REPO_ROOT}"/scenarios/*.md; do
  scenario_paths+=("/scenarios/$(basename "${scenario_path}")")
done

# Catalog copies
copy_file "${OUTPUT_DIR}/personas/catalog.json" "${OUTPUT_DIR}/personas.json"
copy_file "${OUTPUT_DIR}/skills/catalog.json" "${OUTPUT_DIR}/skills/index.json"
copy_file "${OUTPUT_DIR}/skills/catalog.json" "${OUTPUT_DIR}/skills.json"
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

# Discovery manifest
{
  printf '{\n'
  printf '  "version": 4,\n'
  printf '  "base_request": "/",\n'
  printf '  "root_manifest": "/index.json",\n'
  printf '  "entrypoint": "/entrypoint.json",\n'
  printf '  "description": "Cold-start discovery manifest for the published Codex Tools bundle.",\n'
  printf '  "baseline": {\n'
  printf '    "shared": "/AGENTS.md",\n'
  printf '    "bootstrap": "/ENTRYPOINT.md",\n'
  printf '    "repo": "/REPO_AGENTS.md",\n'
  printf '    "howto": "/docs/HOWTO.md",\n'
  printf '    "prompt_generation": "/docs/PROMPT_GENERATION.md"\n'
  printf '  },\n'
  printf '  "capabilities": {\n'
  printf '    "personas": "Specialized working modes for different delivery roles.",\n'
  printf '    "skills": "Short previews describing reusable methods, when to use them, and which playbooks to load next.",\n'
  printf '    "scenarios": "Full execution playbooks for repeatable review and delivery flows.",\n'
  printf '    "docs": "Shared public instructions, tool references, and specifications.",\n'
  printf '    "workflows": "Published CI/CD definitions for inspection and reuse."\n'
  printf '  },\n'
  printf '  "catalogs": {\n'
  printf '    "personas": "/personas.json",\n'
  printf '    "scenarios": "/scenarios.json",\n'
  printf '    "skills": "/skills.json",\n'
  printf '    "docs": "/docs/index.json",\n'
  printf '    "workflows": "/workflows/index.json"\n'
  printf '  },\n'
  printf '  "discovery_order": [\n'
  printf '    "/",\n'
  printf '    "/AGENTS.md",\n'
  printf '    "/docs/HOWTO.md",\n'
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
  printf '    "skills": '
  emit_json_array '      ' '    ' "${skills_paths[@]}"
  printf ',\n'
  printf '    "scenarios": '
  emit_json_array '      ' '    ' "${scenario_paths[@]}"
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
  printf '    "selected_skills",\n'
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
  echo "- [HOWTO](docs/HOWTO.md)"
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
  echo "## Skills"
  echo "- [catalog](skills.json)"
  for skill_path in "${REPO_ROOT}"/skills/*.md; do
    skill_name="$(basename "${skill_path}")"
    echo "- [${skill_name%.*}](skills/${skill_name})"
  done
  echo
  echo "## Scenarios"
  echo "- [catalog](scenarios.json)"
  for scenario_path in "${REPO_ROOT}"/scenarios/*.md; do
    scenario_name="$(basename "${scenario_path}")"
    echo "- [${scenario_name%.*}](scenarios/${scenario_name})"
  done
  echo
  echo "## Supplemental Scripts (Codex Web only; outside cold-start API)"
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

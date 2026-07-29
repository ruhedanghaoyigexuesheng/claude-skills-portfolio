#!/usr/bin/env bash
# validate_toolbox.sh — validate ai-test-workflow-toolbox-skill package integrity
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

MISSING=()
WARNINGS=()
DUPLICATE_REPORT=()
EXIT_CODE=0

ALLOWED_PREFIX='^(\.\./)?(workflows|assets|prompts|system|outputs|templates|examples|references|records)/'

log() { printf '%s\n' "$*"; }
fail() { EXIT_CODE=1; }

is_optional_ref() {
  local ref="$1"
  [[ "$ref" =~ 待测Prompt-v2\.md$ ]] && return 0
  [[ "$ref" =~ 待测Prompt\.md$ ]] && return 0
  [[ "$ref" =~ ^records/.*运行 ]] && return 0
  [[ "$ref" =~ ^skills/ ]] && return 0
  return 1
}

normalize_ref() {
  local ref="$1"
  ref="${ref#@}"
  ref="${ref%%#*}"
  ref="${ref%\`}"
  ref="${ref%/}"
  ref="${ref#ai-test-workflow-toolbox-skill/}"
  if [[ "$ref" == samples/* ]]; then
    ref="assets/${ref}"
  fi
  printf '%s' "$ref"
}

is_skippable_ref() {
  local ref="$1"
  ref="$(normalize_ref "$ref")"
  [[ -z "$ref" ]] && return 0
  [[ "$ref" =~ ^https?:// ]] && return 0
  [[ "$ref" == *"<"* ]] && return 0
  [[ "$ref" == *"域"* ]] && return 0
  is_optional_ref "$ref" && return 0
  [[ "$ref" != */* ]] && return 0
  return 1
}

is_trackable_path() {
  local ref="$1"
  [[ "$ref" =~ $ALLOWED_PREFIX ]] && return 0
  [[ "$ref" == samples/* ]] && return 0
  return 1
}

resolve_to_root() {
  local source_rel="$1"
  local ref="$2"
  ref="$(normalize_ref "$ref")"
  local resolved="$ref"
  if [[ "$ref" == ../* ]]; then
    local base_dir resolved_dir
    base_dir="$(dirname "$ROOT/$source_rel")"
    resolved_dir="$(cd "$base_dir" && cd "$(dirname "$ref")" && pwd)"
    resolved="${resolved_dir#"$ROOT"/}/$(basename "$ref")"
  fi
  printf '%s' "$resolved"
}

check_one_ref() {
  local raw="$1"
  local source_rel="$2"
  local ref resolved full
  ref="$(normalize_ref "$raw")"
  is_skippable_ref "$ref" && return 0
  is_trackable_path "$ref" || return 0

  resolved="$(resolve_to_root "$source_rel" "$ref")"

  local -a targets=()
  if [[ "$resolved" == *"*"* || "$resolved" == *"?"* ]]; then
    shopt -s nullglob
    targets=( "$ROOT/$resolved" )
    shopt -u nullglob
    if ((${#targets[@]} == 0)); then
      MISSING+=("$resolved (from $source_rel, glob matched 0 files)")
      fail
    fi
    return 0
  fi

  full="$ROOT/$resolved"
  if [[ -e "$full" ]]; then
    return 0
  fi
  MISSING+=("$resolved (from $source_rel)")
  fail
}

extract_refs_from_file() {
  local file="$1"
  local rel="${file#"$ROOT"/}"
  local line
  while IFS= read -r line; do
    line="$(normalize_ref "$line")"
    [[ "$line" =~ ^https?:// ]] && continue
    is_trackable_path "$line" || [[ "$line" == ../* ]] || continue
    check_one_ref "$line" "$rel"
  done < <(grep -oE '\]\([^)]+\)' "$file" 2>/dev/null | sed -E 's/^\]\((.+)\)$/\1/' || true)
  while IFS= read -r line; do
    check_one_ref "$line" "$rel"
  done < <(grep -oE '`[^`]+`' "$file" 2>/dev/null | tr -d '`' || true)
  while IFS= read -r line; do
    check_one_ref "$line" "$rel"
  done < <(grep -oE '@(workflows|assets|prompts|system|outputs|templates|examples|references|records)/[^[:space:]@]+' "$file" 2>/dev/null | sed 's/^@//' || true)
}

scan_referenced_files() {
  log "== Referenced path scan =="
  extract_refs_from_file "$ROOT/SKILL.md"
  local wf
  for wf in "$ROOT"/workflows/*.md; do
    [[ -f "$wf" ]] || continue
    extract_refs_from_file "$wf"
  done
  local pr
  for pr in "$ROOT"/prompts/*助手Prompt.md; do
    [[ -f "$pr" ]] || continue
    extract_refs_from_file "$pr"
  done
}

require_file() {
  local path="$1"
  local label="$2"
  if [[ ! -e "$ROOT/$path" ]]; then
    MISSING+=("$path ($label)")
    fail
  fi
}

require_count_glob() {
  local pattern="$1"
  local min="$2"
  local label="$3"
  shopt -s nullglob
  local arr=( $ROOT/$pattern )
  shopt -u nullglob
  if ((${#arr[@]} < min)); then
    MISSING+=("$pattern ($label: expected >=$min, found ${#arr[@]})")
    fail
  fi
}

check_acceptance_checklist() {
  log ""
  log "== Acceptance checklist (SKILL.md) =="

  local workflows=(
    "workflows/Bug分析工作流.md"
    "workflows/日志排查工作流.md"
    "workflows/SQL分析工作流.md"
    "workflows/回归测试工作流.md"
    "workflows/Prompt测试工作流.md"
  )
  local w
  for w in "${workflows[@]}"; do
    require_file "$w" "checklist: 5 workflows"
  done
  log "  [OK] 5 core workflow files"

  require_count_glob "prompts/*助手Prompt.md" 5 "checklist: 5 assistant prompts"
  log "  [OK] prompts/*助手Prompt.md (>=5)"

  local outputs=(
    "outputs/Bug分析输出格式.md"
    "outputs/日志排查输出格式.md"
    "outputs/SQL分析输出格式.md"
    "outputs/回归测试清单输出格式.md"
    "outputs/Prompt测试报告输出格式.md"
  )
  local o
  for o in "${outputs[@]}"; do
    require_file "$o" "checklist: 5 outputs"
  done
  log "  [OK] 5 output format files"

  local systems=(
    "system/AI测试工作台总规则.md"
    "system/风险等级规则.md"
    "system/人工复核规则.md"
  )
  local s
  for s in "${systems[@]}"; do
    require_file "$s" "checklist: 3 system rules"
  done
  log "  [OK] 3 system rule files"

  local assets=(
    "assets/历史Bug库.md"
    "assets/日志规律库.md"
    "assets/SQL风险库.md"
    "assets/回归规则库.md"
    "assets/Prompt测试案例库.md"
  )
  local a
  for a in "${assets[@]}"; do
    require_file "$a" "checklist: 5 asset libs"
  done
  log "  [OK] 5 asset summary libraries"

  shopt -s nullglob
  local linkage=( "$ROOT"/examples/联动案例-*.md )
  shopt -u nullglob
  if ((${#linkage[@]} < 1)); then
    MISSING+=("examples/联动案例-*.md (checklist: linkage example)")
    fail
  else
    log "  [OK] linkage example(s): ${#linkage[@]}"
  fi

  if [[ ! -f "$ROOT/SKILL.md" ]]; then
    MISSING+=("SKILL.md (checklist: entry router)")
    fail
  else
    log "  [OK] SKILL.md entry"
  fi
}

check_sample_duplicates() {
  log ""
  log "== Duplicate content: assets/samples vs examples/regression-test =="
  local samples_dir="$ROOT/assets/samples"
  local examples_dir="$ROOT/examples/regression-test"
  if [[ ! -d "$samples_dir" ]]; then
    log "  (assets/samples/ removed — regression cases live in examples/regression-test/)"
    return 0
  fi
  if [[ ! -d "$examples_dir" ]]; then
    WARNINGS+=("examples/regression-test/ does not exist — skip duplicate scan")
    log "  (examples/regression-test/ missing — skipped)"
    return 0
  fi

  local f base other
  for f in "$samples_dir"/*; do
    [[ -f "$f" ]] || continue
    base="$(basename "$f")"
    other="$examples_dir/$base"
    if [[ -f "$other" ]]; then
      if cmp -s "$f" "$other"; then
        DUPLICATE_REPORT+=("IDENTICAL: assets/samples/$base == examples/regression-test/$base")
        log "  IDENTICAL: $base"
      else
        DUPLICATE_REPORT+=("DIFFERENT same name: assets/samples/$base vs examples/regression-test/$base")
        log "  DIFFER (same name): $base"
      fi
    fi
  done
  if ((${#DUPLICATE_REPORT[@]} == 0)); then
    log "  (no overlapping filenames)"
  fi
}

dedupe_missing() {
  ((${#MISSING[@]} == 0)) && return 0
  local -a uniq=()
  local m seen=0 u
  for m in "${MISSING[@]}"; do
    seen=0
    for u in "${uniq[@]:-}"; do
      [[ "$u" == "$m" ]] && { seen=1; break; }
    done
    ((seen)) || uniq+=("$m")
  done
  MISSING=("${uniq[@]}")
}

print_summary() {
  dedupe_missing
  log ""
  log "== Summary =="
  log "Exit code will be: $EXIT_CODE"
  if ((${#MISSING[@]} > 0)); then
    log ""
    log "Missing required files (${#MISSING[@]}):"
    local m
    for m in "${MISSING[@]}"; do
      log "  - $m"
    done
  else
    log "Missing required files: (none)"
  fi
  if ((${#DUPLICATE_REPORT[@]} > 0)); then
    log ""
    log "Duplicates / overlaps (${#DUPLICATE_REPORT[@]}):"
    local d
    for d in "${DUPLICATE_REPORT[@]}"; do
      log "  - $d"
    done
  fi
  if ((${#WARNINGS[@]} > 0)); then
    log ""
    log "Warnings:"
    local w
    for w in "${WARNINGS[@]}"; do
      log "  - $w"
    done
  fi
}

main() {
  log "Validating toolbox at: $ROOT"
  log ""
  scan_referenced_files
  check_acceptance_checklist
  check_sample_duplicates
  print_summary
  exit "$EXIT_CODE"
}

main "$@"

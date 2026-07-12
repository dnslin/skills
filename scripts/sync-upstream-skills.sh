#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILLS_DIR="$ROOT"
MANIFEST_FILE="$ROOT/.upstream-managed-skills"
VERSIONS_FILE="$ROOT/UPSTREAM_VERSIONS.md"

TMP_DIR="$(mktemp -d)"
REPOS_DIR="$TMP_DIR/repos"
STAGING_DIR="$TMP_DIR/staging"
NEW_MANIFEST_FILE="$TMP_DIR/new-manifest"
VERSIONS_TEMP_FILE="$TMP_DIR/UPSTREAM_VERSIONS.md"

trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$SKILLS_DIR"
mkdir -p "$REPOS_DIR"
mkdir -p "$STAGING_DIR"

: > "$NEW_MANIFEST_FILE"

declare -A SKILL_SOURCES


# ============================================================
# 基础工具
# ============================================================

log() {
  printf '%s\n' "$*" >&2
}

die() {
  log
  log "错误：$*"
  exit 1
}

validate_skill_name() {
  local skill_name="$1"
  if [[ -z "$skill_name" ]]; then
    die "技能名称不能为空"
  fi
  case "$skill_name" in
    "."|".."|*/*|*\\*)
      die "不安全的技能目录名称：$skill_name"
      ;;
  esac
}

copy_directory() {
  local source_dir="$1"
  local destination_dir="$2"

  if [[ ! -d "$source_dir" ]]; then
    die "复制来源目录不存在：$source_dir"
  fi

  rm -rf "$destination_dir"
  mkdir -p "$destination_dir"

  # 复制普通文件及隐藏文件。
  cp -a "$source_dir/." "$destination_dir/"
}

record_skill() {
  local skill_name="$1"
  local source_description="$2"

  validate_skill_name "$skill_name"

  if [[ -n "${SKILL_SOURCES[$skill_name]:-}" ]]; then
    log
    log "错误：检测到平铺目录名称冲突：$skill_name"
    log "来源一：${SKILL_SOURCES[$skill_name]}"
    log "来源二：$source_description"
    exit 1
  fi

  SKILL_SOURCES["$skill_name"]="$source_description"
  printf '%s\n' "$skill_name" >> "$NEW_MANIFEST_FILE"
}


# ============================================================
# Git sparse checkout
# ============================================================

clone_sparse() {
  local clone_name="$1"
  local repository="$2"
  local source_path="$3"
  local branch="${4:-main}"
  local clone_dir="$REPOS_DIR/$clone_name"

  log
  log "------------------------------------------------------------"
  log "仓库：$repository"
  log "目录：$source_path"
  log "分支：$branch"
  log "------------------------------------------------------------"

  rm -rf "$clone_dir"

  git clone \
    --quiet \
    --depth=1 \
    --branch="$branch" \
    --filter=blob:none \
    --sparse \
    "https://github.com/${repository}.git" \
    "$clone_dir"

  git -C "$clone_dir" sparse-checkout set "$source_path"

  if [[ ! -d "$clone_dir/$source_path" ]]; then
    die "上游目录不存在：https://github.com/$repository/tree/$branch/$source_path"
  fi

  # stdout 只输出 clone 目录。
  printf '%s\n' "$clone_dir"
}


# ============================================================
# 版本记录
# ============================================================

record_version() {
  local name="$1"
  local repository="$2"
  local source_path="$3"
  local branch="$4"
  local clone_dir="$5"
  local commit_sha

  commit_sha="$(git -C "$clone_dir" rev-parse HEAD)"

  printf '| `%s` | `%s` | `%s` | `%s` | [`%s`](https://github.com/%s/commit/%s) |\n' \
    "$name" \
    "$repository" \
    "$source_path" \
    "$branch" \
    "${commit_sha:0:12}" \
    "$repository" \
    "$commit_sha" \
    >> "$VERSIONS_TEMP_FILE"
}


# ============================================================
# 单个技能
# ============================================================

stage_single_skill() {
  local clone_name="$1"
  local repository="$2"
  local source_path="$3"
  local skill_name="$4"
  local branch="${5:-main}"
  local clone_dir

  clone_dir="$(
    clone_sparse \
      "$clone_name" \
      "$repository" \
      "$source_path" \
      "$branch"
  )"

  record_skill \
    "$skill_name" \
    "$repository/$source_path"

  copy_directory \
    "$clone_dir/$source_path" \
    "$STAGING_DIR/$skill_name"

  record_version \
    "$skill_name" \
    "$repository" \
    "$source_path" \
    "$branch" \
    "$clone_dir"
}


# ============================================================
# 技能集合平铺
# ============================================================

stage_skill_collection() {
  local clone_name="$1"
  local repository="$2"
  local source_path="$3"
  local branch="${4:-main}"
  local clone_dir
  local source_dir
  local child_dir
  local skill_name
  local skill_count=0

  clone_dir="$(
    clone_sparse \
      "$clone_name" \
      "$repository" \
      "$source_path" \
      "$branch"
  )"

  source_dir="$clone_dir/$source_path"

  while IFS= read -r -d '' child_dir; do
    skill_name="$(basename "$child_dir")"

    # 忽略隐藏目录。
    if [[ "$skill_name" == .* ]]; then
      continue
    fi

    record_skill \
      "$skill_name" \
      "$repository/$source_path/$skill_name"

    copy_directory \
      "$child_dir" \
      "$STAGING_DIR/$skill_name"

    skill_count=$((skill_count + 1))
  done < <(
    find "$source_dir" \
      -mindepth 1 \
      -maxdepth 1 \
      -type d \
      -print0
  )

  if [[ "$skill_count" -eq 0 ]]; then
    die "集合目录中没有找到一级子目录：$repository/$source_path"
  fi

  record_version \
    "$clone_name" \
    "$repository" \
    "$source_path" \
    "$branch" \
    "$clone_dir"

  log "发现 $skill_count 个一级技能目录。"
}


# ============================================================
# 初始化版本记录
# ============================================================

cat > "$VERSIONS_TEMP_FILE" <<'EOF'
# Upstream versions

该文件由 `scripts/sync-upstream-skills.sh` 自动生成，请勿手动修改。

| 名称 | 上游仓库 | 上游目录 | 分支 | Commit |
|---|---|---|---|---|
EOF


# ============================================================
# 配置上游
# ============================================================

log "准备上游技能……"

# 1. Agent Browser
stage_single_skill \
  "agent-browser" \
  "vercel-labs/agent-browser" \
  "skills" \
  "agent-browser"

# 2. Engineering 集合，平铺一级目录
stage_skill_collection \
  "engineering" \
  "mattpocock/skills" \
  "skills/engineering"


  # Matt Pocock - Productivity 集合
stage_skill_collection \
  "mattpocock-productivity" \
  "mattpocock/skills" \
  "skills/productivity" \
  "main"

# 3. Anthropic Frontend Design
stage_single_skill \
  "frontend-design" \
  "anthropics/skills" \
  "skills/frontend-design" \
  "frontend-design"

# 4. GSAP 集合，平铺一级目录
stage_skill_collection \
  "gsap-skills" \
  "greensock/gsap-skills" \
  "skills"

# 5、6. Vercel Agent Skills
#
# 同一个仓库只克隆一次，并同步两个指定目录。
VERCEL_AGENT_SKILLS_CLONE="$(
  clone_sparse \
    "vercel-agent-skills" \
    "vercel-labs/agent-skills" \
    "skills" \
    "main"
)"

record_skill \
  "react-best-practices" \
  "vercel-labs/agent-skills/skills/react-best-practices"

copy_directory \
  "$VERCEL_AGENT_SKILLS_CLONE/skills/react-best-practices" \
  "$STAGING_DIR/react-best-practices"

record_skill \
  "web-design-guidelines" \
  "vercel-labs/agent-skills/skills/web-design-guidelines"

copy_directory \
  "$VERCEL_AGENT_SKILLS_CLONE/skills/web-design-guidelines" \
  "$STAGING_DIR/web-design-guidelines"

record_version \
  "vercel-agent-skills" \
  "vercel-labs/agent-skills" \
  "skills" \
  "main" \
  "$VERCEL_AGENT_SKILLS_CLONE"


# ============================================================
# 整理 manifest
# ============================================================

sort -u "$NEW_MANIFEST_FILE" -o "$NEW_MANIFEST_FILE"

if [[ ! -s "$NEW_MANIFEST_FILE" ]]; then
  die "没有发现任何可同步的技能"
fi


# ============================================================
# 检查非托管目录冲突
# ============================================================

log
log "检查本地目录冲突……"

while IFS= read -r skill_name; do
  if [[ -z "$skill_name" ]]; then
    continue
  fi

  validate_skill_name "$skill_name"

  target_path="$SKILLS_DIR/$skill_name"

  if [[ ! -e "$target_path" ]]; then
    continue
  fi

  # 旧 manifest 中存在，说明目标是脚本上次生成的。
  if [[ -f "$MANIFEST_FILE" ]]; then
    if grep -Fxq "$skill_name" "$MANIFEST_FILE"; then
      continue
    fi
  fi

  log
  log "错误：上游技能与本地非托管目录冲突："
  log "  $target_path"
  log
  log "上游来源：${SKILL_SOURCES[$skill_name]}"
  log
  log "为了避免覆盖本地内容，脚本已经停止。"
  log
  log "请备份并删除冲突目录后重新执行。"
  exit 1
done < "$NEW_MANIFEST_FILE"


# ============================================================
# 清理旧的托管目录
# ============================================================

log
log "清理上一次同步管理的目录……"

if [[ -f "$MANIFEST_FILE" ]]; then
  while IFS= read -r skill_name; do
    if [[ -z "$skill_name" ]]; then
      continue
    fi

    validate_skill_name "$skill_name"
    rm -rf "$SKILLS_DIR/$skill_name"
  done < "$MANIFEST_FILE"
fi


# ============================================================
# 写入新的平铺目录
# ============================================================

log "写入新的平铺技能目录……"

while IFS= read -r skill_name; do
  if [[ -z "$skill_name" ]]; then
    continue
  fi

  validate_skill_name "$skill_name"

  copy_directory \
    "$STAGING_DIR/$skill_name" \
    "$SKILLS_DIR/$skill_name"
done < "$NEW_MANIFEST_FILE"


# ============================================================
# 保存 manifest 和版本记录
# ============================================================

cp "$NEW_MANIFEST_FILE" "$MANIFEST_FILE"
cp "$VERSIONS_TEMP_FILE" "$VERSIONS_FILE"


# ============================================================
# 输出结果
# ============================================================

skill_total="$(
  grep -cve '^[[:space:]]*$' "$MANIFEST_FILE" || true
)"

log
log "============================================================"
log "同步完成"
log "============================================================"
log
log "共同步 $skill_total 个技能："

while IFS= read -r skill_name; do
  if [[ -n "$skill_name" ]]; then
    log "  - $skill_name"
  fi
done < "$MANIFEST_FILE"

log
log "技能目录：$SKILLS_DIR"
log "托管清单：$MANIFEST_FILE"
log "版本记录：$VERSIONS_FILE"
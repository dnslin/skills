#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILLS_DIR="$ROOT/skills"
MANIFEST="$ROOT/.upstream-managed-skills"
VERSIONS_FILE="$ROOT/UPSTREAM_VERSIONS.md"

TMP_DIR="$(mktemp -d)"
STAGING_DIR="$TMP_DIR/staging"
NEW_MANIFEST="$TMP_DIR/new-manifest"

trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$SKILLS_DIR"
mkdir -p "$STAGING_DIR"
touch "$NEW_MANIFEST"

declare -A SKILL_SOURCES

record_skill() {
  local skill_name="$1"
  local source="$2"

  if [[ -n "${SKILL_SOURCES[$skill_name]:-}" ]]; then
    echo "错误：检测到平铺目录名称冲突：$skill_name"
    echo "来源一：${SKILL_SOURCES[$skill_name]}"
    echo "来源二：$source"
    exit 1
  fi

  SKILL_SOURCES["$skill_name"]="$source"
  printf '%s\n' "$skill_name" >> "$NEW_MANIFEST"
}

clone_sparse() {
  local name="$1"
  local repository="$2"
  local source_path="$3"
  local branch="${4:-main}"
  local clone_dir="$TMP_DIR/repos/$name"

  echo
  echo "同步 $repository/$source_path"

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
    echo "错误：上游目录不存在："
    echo "https://github.com/$repository/tree/$branch/$source_path"
    exit 1
  fi

  printf '%s\n' "$clone_dir"
}

# 将一个上游目录作为单个技能，复制到 skills/<skill_name>
stage_single_skill() {
  local clone_name="$1"
  local repository="$2"
  local source_path="$3"
  local skill_name="$4"
  local branch="${5:-main}"

  local clone_dir
  clone_dir="$(clone_sparse "$clone_name" "$repository" "$source_path" "$branch")"

  record_skill \
    "$skill_name" \
    "$repository/$source_path"

  mkdir -p "$STAGING_DIR/$skill_name"

  rsync \
    --archive \
    --delete \
    --exclude='.git/' \
    "$clone_dir/$source_path/" \
    "$STAGING_DIR/$skill_name/"

  record_version \
    "$skill_name" \
    "$repository" \
    "$source_path" \
    "$branch" \
    "$clone_dir"
}

# 将上游目录中的每个一级子目录平铺到 skills/
stage_skill_collection() {
  local clone_name="$1"
  local repository="$2"
  local source_path="$3"
  local branch="${4:-main}"

  local clone_dir
  clone_dir="$(clone_sparse "$clone_name" "$repository" "$source_path" "$branch")"

  local source_dir="$clone_dir/$source_path"
  local found=false

  while IFS= read -r -d '' child_dir; do
    found=true

    local skill_name
    skill_name="$(basename "$child_dir")"

    # 忽略隐藏目录
    if [[ "$skill_name" == .* ]]; then
      continue
    fi

    record_skill \
      "$skill_name" \
      "$repository/$source_path/$skill_name"

    mkdir -p "$STAGING_DIR/$skill_name"

    rsync \
      --archive \
      --delete \
      --exclude='.git/' \
      "$child_dir/" \
      "$STAGING_DIR/$skill_name/"

  done < <(
    find "$source_dir" \
      -mindepth 1 \
      -maxdepth 1 \
      -type d \
      -print0 |
      sort -z
  )

  if [[ "$found" == false ]]; then
    echo "错误：集合目录中没有找到一级子目录："
    echo "$repository/$source_path"
    exit 1
  fi

  record_version \
    "$clone_name" \
    "$repository" \
    "$source_path" \
    "$branch" \
    "$clone_dir"
}

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
    >> "$VERSIONS_TEMP"
}

VERSIONS_TEMP="$TMP_DIR/UPSTREAM_VERSIONS.md"

cat > "$VERSIONS_TEMP" <<'EOF'
# Upstream versions

该文件由 `scripts/sync-upstream-skills.sh` 自动生成，请勿手动修改。

| 名称 | 上游仓库 | 上游目录 | 分支 | Commit |
|---|---|---|---|---|
EOF

echo "准备上游技能……"

# 1. Agent Browser：整个 skills 目录作为 agent-browser 技能
stage_single_skill \
  "agent-browser" \
  "vercel-labs/agent-browser" \
  "skills" \
  "agent-browser"

# 2. Engineering：其一级子目录全部平铺
stage_skill_collection \
  "engineering" \
  "mattpocock/skills" \
  "skills/engineering"

# 3. Anthropic frontend-design：单个技能
stage_single_skill \
  "frontend-design" \
  "anthropics/skills" \
  "skills/frontend-design" \
  "frontend-design"

# 4. GSAP：skills 下的一级子目录全部平铺
stage_skill_collection \
  "gsap-skills" \
  "greensock/gsap-skills" \
  "skills"

# 5. React best practices：单个技能
stage_single_skill \
  "react-best-practices" \
  "vercel-labs/agent-skills" \
  "skills/react-best-practices" \
  "react-best-practices"

# 6. Web design guidelines：单个技能
stage_single_skill \
  "web-design-guidelines" \
  "vercel-labs/agent-skills" \
  "skills/web-design-guidelines" \
  "web-design-guidelines"

sort -u "$NEW_MANIFEST" -o "$NEW_MANIFEST"

echo
echo "检查目录冲突……"

# 检查新增的上游技能是否会覆盖主仓库中的非托管目录。
while IFS= read -r skill_name; do
  [[ -n "$skill_name" ]] || continue

  target="$SKILLS_DIR/$skill_name"

  if [[ -e "$target" ]]; then
    previously_managed=false

    if [[ -f "$MANIFEST" ]] && grep -Fxq "$skill_name" "$MANIFEST"; then
      previously_managed=true
    fi

    if [[ "$previously_managed" == false ]]; then
      echo "错误：上游技能与主仓库已有目录冲突："
      echo "  $target"
      echo
      echo "该目录不在 $MANIFEST 中，因此脚本不会覆盖它。"
      exit 1
    fi
  fi
done < "$NEW_MANIFEST"

echo "删除上一次同步管理的目录……"

if [[ -f "$MANIFEST" ]]; then
  while IFS= read -r skill_name; do
    [[ -n "$skill_name" ]] || continue

    # 安全检查：只允许删除 skills/ 下的一级相对目录。
    if [[ "$skill_name" == */* || "$skill_name" == "." || "$skill_name" == ".." ]]; then
      echo "错误：manifest 中存在不安全的路径：$skill_name"
      exit 1
    fi

    rm -rf "$SKILLS_DIR/$skill_name"
  done < "$MANIFEST"
fi

echo "写入新的平铺目录……"

while IFS= read -r skill_name; do
  [[ -n "$skill_name" ]] || continue

  mkdir -p "$SKILLS_DIR/$skill_name"

  rsync \
    --archive \
    "$STAGING_DIR/$skill_name/" \
    "$SKILLS_DIR/$skill_name/"
done < "$NEW_MANIFEST"

cp "$NEW_MANIFEST" "$MANIFEST"
mv "$VERSIONS_TEMP" "$VERSIONS_FILE"

echo
echo "同步完成。当前托管技能："
sed 's/^/  - /' "$MANIFEST"
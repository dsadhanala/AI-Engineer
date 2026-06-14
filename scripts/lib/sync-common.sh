#!/usr/bin/env bash
# shellcheck shell=bash
#
# Shared helpers for syncing canonical ~/.agents assets (skills, commands)
# into the per-tool directories via relative symlinks.
#
# Source this from a sync script, then call:
#   parse_sync_flags "$@"        # sets DRY_RUN / ASSUME_YES / SYNC_SHOW_HELP
#   sync_source <src_dir> <dirs|files> "$DRY_RUN" "$ASSUME_YES" "${TARGETS[@]}"
#   sync_summary
#
# A single relative-symlink strategy is used everywhere so links survive a
# $HOME move and stay consistent across tools. The relative target is computed
# from the link's own directory, so it works for any depth of target dir.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters (assignment form so they never return non-zero under `set -e`).
SYNC_CREATED=0
SYNC_OK=0
SYNC_FIXED=0
SYNC_ATTENTION=0
SYNC_PRUNED=0

# parse_sync_flags <args...> — recognizes --dry-run/-n, --yes/-y, --prune, --help/-h.
# DRY_RUN/ASSUME_YES/PRUNE/SYNC_SHOW_HELP are read by the sourcing script.
# shellcheck disable=SC2034
parse_sync_flags() {
  DRY_RUN=false
  ASSUME_YES=false
  PRUNE=false
  SYNC_SHOW_HELP=false
  local arg
  for arg in "$@"; do
    case "$arg" in
      --dry-run|-n) DRY_RUN=true ;;
      --yes|-y)     ASSUME_YES=true ;;
      --prune)      PRUNE=true ;;
      -h|--help)    SYNC_SHOW_HELP=true ;;
      *) echo -e "${YELLOW}warning: ignoring unknown flag '$arg'${NC}" >&2 ;;
    esac
  done
}

# _relpath <source_abs> <link_dir> — relative path from link_dir to source.
_relpath() {
  python3 -c 'import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' "$1" "$2"
}

# sync_one <source_item_abs> <link_path> <dry_run> <assume_yes>
# Ensures <link_path> is a relative symlink to <source_item_abs>, handling:
#   - already correct (no-op)
#   - wrong/dangling/broken symlink (repoint)
#   - standalone file or directory copy (prompt unless --yes)
#   - missing (create)
sync_one() {
  local src="$1" link="$2" dry="$3" yes="$4"
  local name link_dir want cur ans
  name=$(basename "$link")
  link_dir=$(dirname "$link")
  want=$(_relpath "$src" "$link_dir")

  if [[ -L "$link" ]]; then
    cur=$(readlink "$link")
    if [[ "$cur" == "$want" && -e "$link" ]]; then
      echo -e "  ${GREEN}\xE2\x9C\x93${NC} $name"
      SYNC_OK=$((SYNC_OK + 1))
      return
    fi
    if [[ ! -e "$link" ]]; then
      echo -e "  ${RED}\xE2\x9F\xB3${NC} $name (broken link: $cur \xE2\x86\x92 $want)"
    else
      echo -e "  ${YELLOW}\xE2\x9F\xB3${NC} $name (wrong target: $cur \xE2\x86\x92 $want)"
    fi
    [[ "$dry" == false ]] && { rm -f "$link"; ln -s "$want" "$link"; }
    SYNC_FIXED=$((SYNC_FIXED + 1))
    return
  fi

  if [[ -e "$link" ]]; then
    echo -e "  ${RED}!${NC} $name (standalone copy exists)"
    ans="n"
    if [[ "$yes" == true ]]; then
      ans="y"
    elif [[ "$dry" == false ]]; then
      read -r -p "    replace with symlink? [y/N] " ans
    fi
    if [[ "$ans" =~ ^[Yy]$ && "$dry" == false ]]; then
      rm -rf "$link"
      ln -s "$want" "$link"
      echo -e "    ${GREEN}\xE2\x86\x92 replaced with symlink${NC}"
      SYNC_FIXED=$((SYNC_FIXED + 1))
    else
      echo -e "    ${YELLOW}\xE2\x86\x92 left in place${NC}"
      SYNC_ATTENTION=$((SYNC_ATTENTION + 1))
    fi
    return
  fi

  echo -e "  ${GREEN}+${NC} $name (creating symlink)"
  [[ "$dry" == false ]] && ln -s "$want" "$link"
  SYNC_CREATED=$((SYNC_CREATED + 1))
}

# sync_source <source_dir> <dirs|files> <dry_run> <assume_yes> <targets...>
sync_source() {
  local source_dir="$1" mode="$2" dry="$3" yes="$4"
  shift 4
  local targets=("$@")

  if [[ ! -d "$source_dir" ]]; then
    echo -e "${RED}Error: source $source_dir does not exist${NC}" >&2
    return 1
  fi

  # Collect canonical items once.
  local items=() p
  if [[ "$mode" == "dirs" ]]; then
    # A skill is a directory containing a SKILL.md; this skips backup/ and
    # other non-skill folders automatically.
    for p in "$source_dir"/*/; do
      [[ -f "${p}SKILL.md" ]] && items+=("${p%/}")
    done
  else
    # README.md is documentation for the source dir, not a command — skip it.
    for p in "$source_dir"/*.md; do
      [[ -f "$p" ]] || continue
      [[ "$(basename "$p")" == "README.md" ]] && continue
      items+=("$p")
    done
  fi

  if [[ ${#items[@]} -eq 0 ]]; then
    echo -e "${YELLOW}Nothing to sync in $source_dir${NC}"
    return 0
  fi

  local target item base
  for target in "${targets[@]}"; do
    # Skip tools that aren't installed (parent dir absent), so an inclusive
    # TARGETS list never creates config dirs for tools you don't use.
    if [[ ! -d "$(dirname "$target")" ]]; then
      echo -e "\n${YELLOW}=== ${target/#$HOME/~} (tool not installed — skipped) ===${NC}"
      continue
    fi
    echo -e "\n${BLUE}=== ${target/#$HOME/~} ===${NC}"
    [[ "$dry" == false ]] && mkdir -p "$target"
    for item in "${items[@]}"; do
      base=$(basename "$item")
      [[ "$base" == ".DS_Store" ]] && continue
      sync_one "$item" "$target/$base" "$dry" "$yes"
    done
    if [[ "${PRUNE:-false}" == true ]]; then
      prune_dangling "$target" "$dry"
    fi
  done
}

# prune_dangling <target_dir> <dry_run>
# Removes symlinks in <target_dir> that we manage (they point into ~/.agents/)
# but no longer resolve (dangling). Leaves real files and valid links untouched.
prune_dangling() {
  local target="$1" dry="$2" link tgt
  for link in "$target"/*; do
    [[ -L "$link" ]] || continue          # only symlinks
    [[ -e "$link" ]] && continue          # skip ones that resolve
    tgt=$(readlink "$link")
    [[ "$tgt" == *"/.agents/"* ]] || continue  # only our managed links
    echo -e "  ${RED}\xE2\x9C\x97${NC} $(basename "$link") (dangling \xE2\x86\x92 $tgt) — pruning"
    [[ "$dry" == false ]] && rm -f "$link"
    SYNC_PRUNED=$((SYNC_PRUNED + 1))
  done
}

sync_summary() {
  echo -e "\n${GREEN}Done.${NC} Created: ${SYNC_CREATED} | OK: ${SYNC_OK} | Fixed: ${SYNC_FIXED} | Pruned: ${SYNC_PRUNED} | Needs attention: ${SYNC_ATTENTION}"
  [[ "${DRY_RUN:-false}" == true ]] && echo -e "${YELLOW}(dry run \xE2\x80\x94 no changes made)${NC}"
  return 0
}

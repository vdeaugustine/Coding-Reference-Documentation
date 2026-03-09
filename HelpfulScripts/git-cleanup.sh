#!/usr/bin/env bash
# If default bash is 3.x (e.g. macOS), re-exec with Bash 4+ when available
if [[ ${BASH_VERSINFO[0]:-0} -lt 4 ]]; then
    for bash4 in /opt/homebrew/bin/bash /usr/local/bin/bash; do
        if [[ -x "$bash4" ]]; then
            v=$("$bash4" -c 'echo ${BASH_VERSINFO[0]:-0}' 2>/dev/null)
            if [[ "${v:-0}" -ge 4 ]]; then
                exec "$bash4" "$0" "$@"
            fi
        fi
    done
    echo "Error: This script requires Bash 4 or newer. Current: ${BASH_VERSION:-unknown}" >&2
    echo "Install with: brew install bash" >&2
    exit 1
fi

set -euo pipefail

# ==============================================================================
# GIT WORKTREE & BRANCH CLEANUP TOOL (Unified)
# ==============================================================================

# 1. Setup Colors
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
RED=$'\033[0;31m'
YELLOW=$'\033[1;33m'
MAGENTA=$'\033[0;35m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
NC=$'\033[0m'

if [[ -n "${NO_COLOR:-}" ]] || [[ ! -t 1 ]]; then
    GREEN=''; BLUE=''; RED=''; YELLOW=''; MAGENTA=''; CYAN=''; BOLD=''; NC=''
fi

# 2. Defaults & Arguments
BASE_REF="HEAD"
DRY_RUN=false
AUTO_YES=false
AUTO_MODE=false
FETCH=false
IGNORE_UNTRACKED=false
FORCE=false
PROOF=false
LOG_FILE="${HOME}/.git-cleanup.log"
PROTECTED_BRANCHES=("main" "master" "develop" "dev" "release" "production" "prod" "staging")

usage() {
    cat <<'EOF'
Usage: git-cleanup [BASE_REF] [OPTIONS]

Options:
  --dry-run          Show what would happen; do not delete anything
  -y, --yes          Non-interactive: select all and confirm deletions
  --auto             Dangerously delete all merged worktrees and merged branches with no prompts
  --force            Offer to force delete branches/worktrees that fail safe delete
  --fetch            Run `git fetch --prune` before scanning
  --ignore-untracked Ignore untracked files when checking if worktrees are dirty
  --proof            For each branch candidate, show evidence it is safe to delete
  -h, --help         Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --base) BASE_REF="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        -y|--yes) AUTO_YES=true; shift ;;
        --auto) AUTO_MODE=true; AUTO_YES=true; FORCE=true; shift ;;
        --fetch) FETCH=true; shift ;;
        --ignore-untracked) IGNORE_UNTRACKED=true; shift ;;
        --force) FORCE=true; shift ;;
        --proof) PROOF=true; shift ;;
        -h|--help) usage; exit 0 ;;
        -*) echo -e "${RED}Unknown option: $1${NC}"; exit 1 ;;
        *) BASE_REF="$1"; shift ;;
    esac
done

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "${RED}Error: Not inside a Git repository.${NC}" >&2
    exit 1
fi

# Load extra protected branches from `git config cleanup.protected` (comma-separated)
# and from a `.gitcleanup` file in the repo root (one branch per line, # = comment).
_load_extra_protected() {
    local _extra _b _root _line
    _extra="$(git config --get cleanup.protected 2>/dev/null || true)"
    if [[ -n "$_extra" ]]; then
        IFS=',' read -ra _cfg <<< "$_extra"
        for _b in "${_cfg[@]}"; do
            _b="${_b//[[:space:]]/}"
            [[ -n "$_b" ]] && PROTECTED_BRANCHES+=("$_b")
        done
    fi
    _root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
    local _cfg_file="${_root}/.gitcleanup"
    if [[ -f "$_cfg_file" ]]; then
        while IFS= read -r _line; do
            [[ -z "$_line" || "$_line" == \#* ]] && continue
            PROTECTED_BRANCHES+=("$_line")
        done < "$_cfg_file"
    fi
}
_load_extra_protected

if [[ "$FETCH" == "true" ]]; then
    echo -e "${BLUE}Fetching and pruning remotes...${NC}"
    git fetch --prune --all
fi

if ! git rev-parse --verify "${BASE_REF}^{commit}" >/dev/null 2>&1; then
    echo -e "${RED}Error: BASE_REF '${BASE_REF}' is not a valid commit-ish.${NC}" >&2
    exit 1
fi

drain_stdin() {
    while read -t 0 2>/dev/null; do
        read -rsn1 -t 0.1 _ 2>/dev/null || break
    done
}

is_protected_branch_name() {
    local name="$1"
    local p
    for p in "${PROTECTED_BRANCHES[@]}"; do
        [[ "$name" == "$p" ]] && return 0
    done
    return 1
}

dedupe_sorted_array() {
    local -n input_ref=$1
    local -n output_ref=$2
    output_ref=()
    if [[ ${#input_ref[@]} -eq 0 ]]; then
        return 0
    fi
    mapfile -t output_ref < <(printf '%s\n' "${input_ref[@]}" | sort -u)
}

dedupe_sorted_numeric_array() {
    local -n input_ref=$1
    local -n output_ref=$2
    output_ref=()
    if [[ ${#input_ref[@]} -eq 0 ]]; then
        return 0
    fi
    mapfile -t output_ref < <(printf '%s\n' "${input_ref[@]}" | sort -un)
}

# Append one deletion record to LOG_FILE for recovery reference.
# Usage: log_deletion <type> <name> [last-commit-hash]
log_deletion() {
    local _type="$1" _name="$2" _hash="${3:-}"
    local _repo; _repo="$(git rev-parse --show-toplevel 2>/dev/null || echo unknown)"
    printf '[%s] %-9s %-50s %s  repo=%s\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" "$_type" "$_name" "${_hash:-(no hash)}" "$_repo" \
        >> "$LOG_FILE"
}

# Returns human-readable disk size of a directory path.
get_dir_size() {
    [[ -d "${1:-}" ]] || { echo "0B"; return; }
    du -sh "$1" 2>/dev/null | awk '{print $1}'
}

# Offers to run git gc after a significant cleanup session.
_offer_gc() {
    [[ "$AUTO_MODE" == "true" || "$AUTO_YES" == "true" ]] && return 0
    echo ""
    read -r -p "Run 'git gc --prune=now' to compact the repository? (y/N): " _gc_ans
    if [[ "$_gc_ans" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Running git gc...${NC}"
        git gc --prune=now 2>&1 | grep -v '^$' || true
        echo -e "${GREEN}✓ Repository compacted.${NC}"
    fi
}

# ==============================================================================
# WORKTREE CLEANUP LOGIC
# ==============================================================================
cleanup_worktrees() {
    local mode="${1:-merged}"
    local MAIN_ROOT
    MAIN_ROOT=$(git rev-parse --show-toplevel)
    local candidate_paths=()
    local candidate_branches=()
    local candidate_dirty=()
    local candidate_dates=()
    local candidate_statuses=()
    local candidate_empty=()
    local candidate_sizes=()

    local mode_label
    case "$mode" in
        merged)
            mode_label="merged into"
            ;;
        unmerged)
            mode_label="NOT merged into"
            ;;
        all)
            mode_label="relative to"
            ;;
        *)
            echo -e "${RED}Invalid worktree mode: $mode${NC}"
            return 1
            ;;
    esac

    echo -e "\n${BLUE}Scanning worktrees ${mode_label} ${YELLOW}$BASE_REF${NC}..."

    # Parse git worktree list --porcelain block by block
    local current_wt=""
    local current_branch=""
    local current_bare="false"

    _flush_worktree_block() {
        [[ -z "$current_wt" ]] && return
        [[ "$current_wt" == "$MAIN_ROOT" ]] && return

        local status_cmd=("git" "-C" "$current_wt" "status" "--porcelain")
        [[ "$IGNORE_UNTRACKED" == "true" ]] && status_cmd+=("-uno")
        local wt_dirty_output
        wt_dirty_output="$("${status_cmd[@]}" 2>/dev/null || true)"
        local is_dirty=false
        [[ -d "$current_wt" && -n "$wt_dirty_output" ]] && is_dirty=true

        # Count commits unique to this worktree branch vs BASE_REF
        local ahead_count=0
        local is_empty_wt=false

        if [[ -z "$current_branch" ]]; then
            # Detached HEAD or no branch: treat as empty/pristine if clean
            is_empty_wt=true
        else
            # Check how many commits this branch has that BASE_REF doesn't
            ahead_count="$(git rev-list --count "${BASE_REF}..${current_branch}" 2>/dev/null || echo 0)"
            if [[ "$ahead_count" -eq 0 && "$is_dirty" == "false" ]]; then
                is_empty_wt=true
            fi
        fi

        local is_merged=false
        if [[ -n "$current_branch" ]]; then
            if git merge-base --is-ancestor "$current_branch" "$BASE_REF" 2>/dev/null; then
                is_merged=true
            fi
        else
            # No branch means nothing was ever committed on it; treat as merged (nothing to lose)
            is_merged=true
        fi

        local include=false
        case "$mode" in
            merged)   [[ "$is_merged" == "true" || "$is_empty_wt" == "true" ]] && include=true ;;
            unmerged) [[ "$is_merged" == "false" && "$is_empty_wt" == "false" ]] && include=true ;;
            all)      include=true ;;
        esac

        if [[ "$include" == "true" && -n "$current_branch" ]]; then
            if is_protected_branch_name "${current_branch#refs/heads/}"; then
                include=false
            fi
        fi

        if [[ "$include" == "true" ]]; then
            candidate_paths+=("$current_wt")
            local display_branch="${current_branch:-[no branch]}"
            candidate_branches+=("${display_branch#refs/heads/}")
            local log_ref="${current_branch:-HEAD}"
            candidate_dates+=("$(git -C "$current_wt" log -1 --pretty="%cr" "$log_ref" 2>/dev/null || echo "unknown age")")
            if [[ "$is_empty_wt" == "true" ]]; then
                candidate_statuses+=("empty")
            elif [[ "$is_merged" == "true" ]]; then
                candidate_statuses+=("merged")
            else
                candidate_statuses+=("unmerged")
            fi
            if [[ "$is_dirty" == "true" ]]; then
                candidate_dirty+=("true")
            else
                candidate_dirty+=("false")
            fi
            candidate_empty+=("$is_empty_wt")
            candidate_sizes+=("$(get_dir_size "$current_wt")")
        fi
    }

    while IFS= read -r line; do
        if [[ -z "$line" ]]; then
            _flush_worktree_block
            current_wt=""
            current_branch=""
            current_bare="false"
        elif [[ $line == worktree\ * ]]; then
            current_wt="${line#worktree }"
        elif [[ $line == branch\ * ]]; then
            current_branch="${line#branch }"
        elif [[ $line == "bare" ]]; then
            current_bare="true"
        fi
    done < <(git worktree list --porcelain; echo "")
    unset -f _flush_worktree_block

    if [[ ${#candidate_paths[@]} -eq 0 ]]; then
        case "$mode" in
            merged)   echo -e "\n${GREEN}No merged or empty worktrees found.${NC}" ;;
            unmerged) echo -e "\n${GREEN}No unmerged worktrees found.${NC}" ;;
            all)      echo -e "\n${GREEN}No worktrees found.${NC}" ;;
        esac
        echo -e "${BLUE}Press Enter to return to the main menu...${NC}"
        read -r _dummy_pause
        return 0
    fi

    local menu_options=()
    local i
    for i in "${!candidate_paths[@]}"; do
        local dirty_tag=""
        local status_tag=""
        [[ "${candidate_dirty[$i]}" == "true" ]] && dirty_tag=" ${RED}[DIRTY]${NC}"
        [[ ! -d "${candidate_paths[$i]}" ]] && dirty_tag=" ${RED}[MISSING DIR]${NC}"

        case "${candidate_statuses[$i]}" in
            merged)   status_tag=" ${GREEN}[MERGED]${NC}" ;;
            unmerged) status_tag=" ${RED}[UNMERGED]${NC}" ;;
            empty)    status_tag=" ${CYAN}[EMPTY/PRISTINE]${NC}" ;;
        esac

        menu_options+=("${GREEN}${candidate_paths[$i]}${NC}  Branch: ${YELLOW}${candidate_branches[$i]}${NC} (${candidate_dates[$i]}) ~${MAGENTA}${candidate_sizes[$i]}${NC}${status_tag}${dirty_tag}")
    done

    local SELECTED_INDICES_RESULT=()

    run_interactive_worktree_menu() {
        local n=${#menu_options[@]}
        local cursor=0
        local selected=()
        local key rest
        local stty_orig=""
        [[ -t 0 ]] || return 1

        stty_orig=$(stty -g 2>/dev/null) || true
        stty -echo -icanon min 1 time 0 2>/dev/null || true
        tput civis 2>/dev/null || true

        cleanup_terminal() {
            [[ -n "${stty_orig:-}" ]] && stty "${stty_orig}" 2>/dev/null || true
            tput cnorm 2>/dev/null || true
            drain_stdin
        }
        trap cleanup_terminal RETURN

        redraw() {
            local i j mark
            tput cup 0 0 2>/dev/null || true
            tput ed 2>/dev/null || true
            echo -e "${BLUE}Select worktrees to remove:${NC}"
            echo -e "${BLUE}↑/↓ move  Space toggle  a all  s safe  e empty  p preview  Enter confirm  q quit${NC}\n"
            for i in $(seq 0 $((n-1))); do
                mark=" "
                for j in "${selected[@]:-}"; do
                    [[ -z "$j" ]] && continue
                    [[ "$j" == "$i" ]] && mark="x"
                done
                
                local cb="[ ]"
                local item_text="${menu_options[$i]}"
                if [[ "$mark" == "x" ]]; then
                    cb="${BOLD}${GREEN}[x]${NC}"
                    item_text="\033[7m${item_text}\033[27m"
                fi

                if [[ $i -eq $cursor ]]; then
                    echo -e "  > ${cb} ${item_text}"
                else
                    echo -e "    ${cb} ${item_text}"
                fi
            done
        }

        redraw
        while true; do
            key=""
            IFS= read -rsn1 key 2>/dev/null || true
            if [[ "$key" == $'\e' ]]; then
                read -rsn2 -t 0.1 rest 2>/dev/null || true
                case "$rest" in
                    "[A")
                        ((cursor > 0)) && cursor=$((cursor-1))
                        redraw
                        ;;
                    "[B")
                        ((cursor < n-1)) && cursor=$((cursor+1))
                        redraw
                        ;;
                esac
                continue
            fi

            case "$key" in
                " ")
                    local found=0
                    local new_selected=()
                    local j
                    for j in "${selected[@]:-}"; do
                        [[ -z "$j" ]] && continue
                        if [[ "$j" == "$cursor" ]]; then
                            found=1
                        else
                            new_selected+=("$j")
                        fi
                    done
                    if [[ $found -eq 0 ]]; then
                        new_selected+=("$cursor")
                    fi
                    selected=()
                    [[ ${#new_selected[@]} -gt 0 ]] && selected=("${new_selected[@]}")
                    redraw
                    ;;
                "a"|"A")
                    selected=()
                    for j in $(seq 0 $((n-1))); do
                        selected+=("$j")
                    done
                    redraw
                    ;;
                "e"|"E")
                    selected=()
                    for j in $(seq 0 $((n-1))); do
                        if [[ "${candidate_statuses[$j]}" == "empty" ]]; then
                            selected+=("$j")
                        fi
                    done
                    redraw
                    ;;
                "s"|"S")
                    selected=()
                    for j in $(seq 0 $((n-1))); do
                        # Safe = not dirty
                        if [[ "${candidate_dirty[$j]}" == "false" ]]; then
                            selected+=("$j")
                        fi
                    done
                    redraw
                    ;;
                "p"|"P")
                    [[ -n "${stty_orig:-}" ]] && stty "${stty_orig}" 2>/dev/null || true
                    tput cnorm 2>/dev/null || true
                    clear
                    local _pi="$cursor"
                    echo -e "${BOLD}${CYAN}Worktree Preview${NC}: ${candidate_paths[$_pi]}"
                    echo -e "${YELLOW}Branch: ${candidate_branches[$_pi]}${NC}  |  Size: ${candidate_sizes[$_pi]}  |  Status: ${candidate_statuses[$_pi]}"
                    echo -e "${BLUE}--- Last 5 commits ---${NC}"
                    git -C "${candidate_paths[$_pi]}" log -5 --oneline --decorate 2>/dev/null || echo "(no commits)"
                    echo -e "${BLUE}--- Working tree status ---${NC}"
                    git -C "${candidate_paths[$_pi]}" status --short 2>/dev/null | head -20 || true
                    echo -e "\n${BLUE}Press any key to return...${NC}"
                    read -rsn1 2>/dev/null || true
                    stty -echo -icanon min 1 time 0 2>/dev/null || true
                    tput civis 2>/dev/null || true
                    redraw
                    ;;
                ""|$'\r'|$'\n')
                    SELECTED_INDICES_RESULT=()
                    [[ ${#selected[@]} -gt 0 ]] && SELECTED_INDICES_RESULT=("${selected[@]}")
                    return 0
                    ;;
                "q"|"Q")
                    SELECTED_INDICES_RESULT=()
                    return 2
                    ;;
            esac
        done

        # Fallback (should not be reached)
        SELECTED_INDICES_RESULT=()
        [[ ${#selected[@]} -gt 0 ]] && SELECTED_INDICES_RESULT=("${selected[@]}")
        return 0
    }

    local selected_indices=()
    if [[ "$AUTO_YES" == "true" && "$mode" == "merged" ]]; then
        selected_indices=("${!candidate_paths[@]}")
    elif [[ -t 0 ]]; then
        local menu_exit_code=0
        run_interactive_worktree_menu || menu_exit_code=$?
        if [[ $menu_exit_code -eq 2 ]]; then
            # User pressed 'q' to quit
            drain_stdin
            return 0
        fi
        selected_indices=("${SELECTED_INDICES_RESULT[@]:-}")
    else
        echo -e "\nWorktrees:\n"
        for i in "${!candidate_paths[@]}"; do
            echo -e "$((i+1)). ${menu_options[$i]}"
        done
        read -r -p "> Enter numbers, 'all', or 'q': " input
        [[ "$input" =~ ^[Qq]$ ]] && return 0
        if [[ "$input" == "all" ]]; then
            for i in "${!candidate_paths[@]}"; do
                selected_indices+=("$i")
            done
        else
            local item idx
            for item in $input; do
                if [[ "$item" =~ ^[0-9]+$ ]]; then
                    idx=$((item-1))
                    [[ $idx -ge 0 && $idx -lt ${#candidate_paths[@]} ]] && selected_indices+=("$idx")
                fi
            done
        fi
    fi

    [[ ${#selected_indices[@]} -eq 0 ]] && { echo "No selection."; return 0; }

    local deduped=()
    dedupe_sorted_numeric_array selected_indices deduped
    selected_indices=("${deduped[@]}")

    local dirty_count=0
    local unmerged_count=0
    local dirty_list=()
    local unmerged_list=()
    local idx
    for idx in "${selected_indices[@]}"; do
        [[ -z "$idx" ]] && continue
        if [[ "${candidate_dirty[$idx]}" == "true" ]]; then
            dirty_count=$((dirty_count + 1))
            dirty_list+=("${candidate_paths[$idx]}")
        fi
        if [[ "${candidate_statuses[$idx]}" == "unmerged" ]]; then
            unmerged_count=$((unmerged_count + 1))
            unmerged_list+=("${candidate_paths[$idx]}")
        fi
    done

    if [[ "$DRY_RUN" == "false" && "$AUTO_MODE" != "true" ]]; then
        if [[ $unmerged_count -gt 0 ]]; then
            echo -e "\n${RED}⚠️  You selected $unmerged_count UNMERGED worktree(s):${NC}"
            for _dl in "${unmerged_list[@]}"; do echo -e "  - ${_dl}"; done
            read -r -p "Type 'DELETE UNMERGED' to proceed: " confirm_unmerged
            [[ "$confirm_unmerged" != "DELETE UNMERGED" ]] && { echo "Aborted."; return 0; }
        fi

        if [[ $dirty_count -gt 0 ]]; then
            echo -e "\n${RED}⚠️  $dirty_count selection(s) are DIRTY. Changes will be lost forever:${NC}"
            for _dl in "${dirty_list[@]}"; do echo -e "  - ${_dl}"; done
            read -r -p "Type 'DELETE DIRTY' to proceed: " confirm_dirty
            [[ "$confirm_dirty" != "DELETE DIRTY" ]] && { echo "Aborted."; return 0; }
        fi
    fi

    echo -e "\n${BLUE}--- EXECUTION ---${NC}"

    local remote_delete_options=()
    local remote_delete_remotes=()
    local remote_delete_branches=()

    for idx in "${selected_indices[@]}"; do
        local path="${candidate_paths[$idx]}"
        local branch="${candidate_branches[$idx]}"
        local status="${candidate_statuses[$idx]}"

        local upstream
        upstream="$(git for-each-ref --format='%(upstream:short)' "refs/heads/$branch" 2>/dev/null || true)"

        if [[ -n "$upstream" ]]; then
            remote_delete_options+=("$upstream")
            remote_delete_remotes+=("${upstream%%/*}")
            remote_delete_branches+=("${upstream#*/}")
        else
            local remote_ref short_ref rmt rbr
            while IFS= read -r remote_ref; do
                short_ref="${remote_ref#refs/remotes/}"
                rmt="${short_ref%%/*}"
                rbr="${short_ref#*/}"
                [[ "$rbr" == "HEAD" ]] && continue
                [[ "$rbr" == "$branch" ]] || continue
                remote_delete_options+=("${rmt}/${rbr}")
                remote_delete_remotes+=("$rmt")
                remote_delete_branches+=("$rbr")
            done < <(git for-each-ref --format='%(refname)' "refs/remotes/*/$branch" 2>/dev/null || true)
        fi

        if [[ "$DRY_RUN" == "true" ]]; then
            echo -e "${MAGENTA}[DRY RUN] Would remove $path and delete local branch $branch [$status]${NC}"
        else
            local need_force=false
            [[ "${candidate_dirty[$idx]}" == "true" || ! -d "$path" || "$AUTO_MODE" == "true" || "$status" == "unmerged" ]] && need_force=true

            local _last_hash; _last_hash="$(git rev-parse "refs/heads/${branch}" 2>/dev/null || echo '')"
            local _wt_size="${candidate_sizes[$idx]}"

            if [[ "$need_force" == "true" ]]; then
                if git worktree remove --force "$path" 2>/dev/null; then
                    echo -e "${GREEN}✓ Removed worktree: $path${NC} (freed ~${_wt_size})"
                    log_deletion "worktree" "$path" "$_last_hash"
                else
                    echo -e "${RED}✗ Failed to remove $path. Check if files are in use.${NC}"
                    continue
                fi
            else
                if git worktree remove "$path" 2>/dev/null; then
                    echo -e "${GREEN}✓ Removed worktree: $path${NC} (freed ~${_wt_size})"
                    log_deletion "worktree" "$path" "$_last_hash"
                else
                    echo -e "${RED}✗ Failed to remove $path. Check if files are in use.${NC}"
                    continue
                fi
            fi

            if git show-ref --verify --quiet "refs/heads/$branch"; then
                if git branch -d "$branch" >/dev/null 2>&1; then
                    echo "  ✓ Deleted local branch: $branch"
                    log_deletion "branch" "$branch" "$_last_hash"
                else
                    if [[ "$AUTO_MODE" == "true" || "$status" == "unmerged" || "$FORCE" == "true" ]]; then
                        if git branch -D "$branch" >/dev/null 2>&1; then
                            echo "  ✓ Force deleted local branch: $branch"
                            log_deletion "branch" "$branch" "$_last_hash"
                        else
                            echo "  ✗ Failed to delete local branch: $branch"
                        fi
                    else
                        echo "  - Local branch could not be safely deleted."
                    fi
                fi
            else
                echo "  - Local branch already gone."
            fi
        fi
    done

    if [[ ${#remote_delete_options[@]} -gt 0 ]]; then
        local dedup_remote_lines=()
        dedupe_sorted_array remote_delete_options dedup_remote_lines

        local dedup_remote_rmt=()
        local dedup_remote_br=()
        local entry
        for entry in "${dedup_remote_lines[@]}"; do
            dedup_remote_rmt+=("${entry%%/*}")
            dedup_remote_br+=("${entry#*/}")
        done

        if [[ "$DRY_RUN" == "true" ]]; then
            echo -e "\n${MAGENTA}[DRY RUN] Would offer remote deletions:${NC}"
            for entry in "${dedup_remote_lines[@]}"; do
                echo "  $entry"
            done
        else
            echo -e "\n${MAGENTA}Detected remote branches related to these worktrees:${NC}"
            for entry in "${dedup_remote_lines[@]}"; do
                echo "  ${entry}"
            done

            local r_input r_confirm="n"
            if [[ "$AUTO_MODE" == "true" || "$AUTO_YES" == "true" ]]; then
                r_confirm="y"
            else
                read -r -p "Delete these remote branches too? (Y/n): " r_input
                r_confirm="${r_input:-y}"
            fi

            if [[ "$r_confirm" =~ ^[Yy]$ ]]; then
                local k
                for k in "${!dedup_remote_lines[@]}"; do
                    if git push "${dedup_remote_rmt[$k]}" --delete "${dedup_remote_br[$k]}"; then
                        echo -e "✓ Deleted remote ${MAGENTA}${dedup_remote_lines[$k]}${NC}"
                        log_deletion "remote" "${dedup_remote_lines[$k]}" ""
                    else
                        echo -e "✗ Failed to delete ${dedup_remote_lines[$k]}"
                    fi
                done
            fi
        fi
    fi

    git worktree prune
    echo -e "\n${GREEN}Worktree cleanup complete.${NC}"
    echo -e "${CYAN}Recovery log: ${LOG_FILE}${NC}"
    _offer_gc
    return 0
}

# ==============================================================================
# BRANCH CLEANUP LOGIC
# ==============================================================================
cleanup_branches() {
    local current_branch
    current_branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || echo "")"

    echo -e "\n${BLUE}Scanning for branches merged into ${YELLOW}${BASE_REF}${NC}...${NC}"

    local base_is_local_branch=false
    if git show-ref --verify --quiet "refs/heads/${BASE_REF}"; then
        base_is_local_branch=true
    fi

    local local_candidates=()
    local local_candidate_age=()
    local local_candidate_upstream=()

    local b
    while IFS= read -r b; do
        [[ -z "$b" ]] && continue
        [[ -n "$current_branch" && "$b" == "$current_branch" ]] && continue
        is_protected_branch_name "$b" && continue
        [[ "$base_is_local_branch" == "true" && "$b" == "$BASE_REF" ]] && continue

        if git merge-base --is-ancestor "refs/heads/$b" "$BASE_REF" 2>/dev/null; then
            local_candidates+=("$b")
            local_candidate_age+=("$(git log -1 --pretty=%cr "refs/heads/$b" 2>/dev/null || echo "unknown age")")
            local_candidate_upstream+=("$(git for-each-ref --format='%(upstream:short)' "refs/heads/$b")")
        fi
    done < <(git for-each-ref --sort=committerdate --format='%(refname:short)' refs/heads)

    local remote_candidates=()
    local remote_candidate_age=()

    local full_remote_ref short_ref remote_name remote_branch
    while IFS= read -r full_remote_ref; do
        [[ -z "$full_remote_ref" ]] && continue

        short_ref="${full_remote_ref#refs/remotes/}"
        remote_name="${short_ref%%/*}"
        remote_branch="${short_ref#*/}"

        [[ "$remote_branch" == "HEAD" ]] && continue
        is_protected_branch_name "$remote_branch" && continue

        if git merge-base --is-ancestor "$full_remote_ref" "$BASE_REF" 2>/dev/null; then
            remote_candidates+=("${remote_name}/${remote_branch}")
            remote_candidate_age+=("$(git log -1 --pretty=%cr "$full_remote_ref" 2>/dev/null || echo "unknown age")")
        fi
    done < <(git for-each-ref --sort=committerdate --format='%(refname)' refs/remotes)

    declare -A local_exists=()
    declare -A local_age_by_name=()
    declare -A local_upstream_by_name=()
    declare -A remote_exists=()
    declare -A remote_age_by_name=()

    local i
    for i in "${!local_candidates[@]}"; do
        local_exists["${local_candidates[$i]}"]=1
        local_age_by_name["${local_candidates[$i]}"]="${local_candidate_age[$i]}"
        local_upstream_by_name["${local_candidates[$i]}"]="${local_candidate_upstream[$i]}"
    done

    for i in "${!remote_candidates[@]}"; do
        remote_exists["${remote_candidates[$i]}"]=1
        remote_age_by_name["${remote_candidates[$i]}"]="${remote_candidate_age[$i]}"
    done

    local item_keys=()
    declare -A item_local_branch=()
    declare -A item_remote_ref=()
    declare -A item_kind=()

    for b in "${local_candidates[@]}"; do
        local upstream="${local_upstream_by_name[$b]}"
        local key="local:$b"
        local kind="local-only"

        if [[ -n "$upstream" && -n "${remote_exists[$upstream]:-}" ]]; then
            key="paired:$b|$upstream"
            kind="local+remote"
        fi

        item_local_branch["$key"]="$b"
        item_remote_ref["$key"]="$upstream"
        item_kind["$key"]="$kind"
    done

    local rr
    for rr in "${remote_candidates[@]}"; do
        local already_paired=false
        for b in "${local_candidates[@]}"; do
            if [[ "${local_upstream_by_name[$b]}" == "$rr" ]]; then
                already_paired=true
                break
            fi
        done
        [[ "$already_paired" == "true" ]] && continue

        local key="remote:$rr"
        item_local_branch["$key"]=""
        item_remote_ref["$key"]="$rr"
        item_kind["$key"]="remote-only"
    done

    while IFS= read -r line; do
        [[ -n "$line" ]] && item_keys+=("$line")
    done < <(printf '%s\n' "${!item_kind[@]}" | sort)

    if [[ ${#item_keys[@]} -eq 0 ]]; then
        echo -e "\n${GREEN}No merged local or remote branches found to delete against ${BASE_REF}.${NC}"
        echo -e "${BLUE}Press Enter to return to the main menu...${NC}"
        read -r _dummy_pause
        return 0
    fi

    local menu_options=()
    for i in "${!item_keys[@]}"; do
        local key="${item_keys[$i]}"
        local lb="${item_local_branch[$key]}"
        local rr="${item_remote_ref[$key]}"
        local kind="${item_kind[$key]}"

        case "$kind" in
            "local+remote")
                menu_options+=("${YELLOW}${lb}${NC} ${CYAN}[local+remote]${NC}  ${MAGENTA}${rr}${NC}  (${local_age_by_name[$lb]})")
                ;;
            "local-only")
                menu_options+=("${YELLOW}${lb}${NC} ${CYAN}[local-only]${NC}  (${local_age_by_name[$lb]})")
                ;;
            "remote-only")
                menu_options+=("${MAGENTA}${rr}${NC} ${CYAN}[remote-only]${NC}  (${remote_age_by_name[$rr]})")
                ;;
        esac
    done

    local SELECTED_INDICES_RESULT=()

    run_interactive_branch_menu() {
        local n=${#menu_options[@]}
        local cursor=0
        local selected=()
        local key rest
        local stty_orig=""
        [[ -t 0 ]] || return 1

        stty_orig=$(stty -g 2>/dev/null) || true
        stty -echo -icanon min 1 time 0 2>/dev/null || true
        tput civis 2>/dev/null || true

        cleanup_terminal() {
            [[ -n "${stty_orig:-}" ]] && stty "${stty_orig}" 2>/dev/null || true
            tput cnorm 2>/dev/null || true
            drain_stdin
        }
        trap cleanup_terminal RETURN

        redraw() {
            local i j mark
            tput cup 0 0 2>/dev/null || true
            tput ed 2>/dev/null || true
            echo -e "${BLUE}Select branches to delete:${NC}"
            echo -e "${BLUE}↑/↓ move  Space toggle  a all  s safe  p preview  Enter confirm  q quit${NC}\n"
            for i in $(seq 0 $((n-1))); do
                mark=" "
                for j in "${selected[@]:-}"; do
                    [[ -z "$j" ]] && continue
                    [[ "$j" == "$i" ]] && mark="x"
                done
                
                local cb="[ ]"
                local item_text="${menu_options[$i]}"
                if [[ "$mark" == "x" ]]; then
                    cb="${BOLD}${GREEN}[x]${NC}"
                    item_text="\033[7m${item_text}\033[27m"
                fi

                if [[ $i -eq $cursor ]]; then
                    echo -e "  > ${cb} ${item_text}"
                else
                    echo -e "    ${cb} ${item_text}"
                fi
            done
        }

        redraw
        while true; do
            key=""
            IFS= read -rsn1 key 2>/dev/null || true
            if [[ "$key" == $'\e' ]]; then
                read -rsn2 -t 0.1 rest 2>/dev/null || true
                case "$rest" in
                    "[A")
                        ((cursor > 0)) && cursor=$((cursor-1))
                        redraw
                        ;;
                    "[B")
                        ((cursor < n-1)) && cursor=$((cursor+1))
                        redraw
                        ;;
                esac
                continue
            fi

            case "$key" in
                " ")
                    local found=0
                    local new_selected=()
                    local j
                    for j in "${selected[@]:-}"; do
                        [[ -z "$j" ]] && continue
                        if [[ "$j" == "$cursor" ]]; then
                            found=1
                        else
                            new_selected+=("$j")
                        fi
                    done
                    if [[ $found -eq 0 ]]; then
                        new_selected+=("$cursor")
                    fi
                    selected=()
                    [[ ${#new_selected[@]} -gt 0 ]] && selected=("${new_selected[@]}")
                    redraw
                    ;;
                "a"|"A"|"s"|"S")
                    selected=()
                    for j in $(seq 0 $((n-1))); do
                        selected+=("$j")
                    done
                    redraw
                    ;;
                "p"|"P")
                    local _pi="$cursor"
                    local _key_pi="${item_keys[$_pi]}"
                    local _lb_pi="${item_local_branch[$_key_pi]}"
                    local _rr_pi="${item_remote_ref[$_key_pi]}"
                    local _ref_pi="${_lb_pi:-$_rr_pi}"
                    [[ -n "${stty_orig:-}" ]] && stty "${stty_orig}" 2>/dev/null || true
                    tput cnorm 2>/dev/null || true
                    clear
                    echo -e "${BOLD}${CYAN}Branch Preview${NC}: ${_ref_pi}  (${item_kind[$_key_pi]})"
                    echo -e "${BLUE}--- Last 5 commits ---${NC}"
                    git log -5 --oneline --decorate "${_ref_pi}" 2>/dev/null || echo "(no commits)"
                    echo -e "${BLUE}--- Diff stat vs ${BASE_REF} ---${NC}"
                    git diff --stat "${BASE_REF}...${_ref_pi}" 2>/dev/null | tail -10 || echo "(clean)"
                    echo -e "\n${BLUE}Press any key to return...${NC}"
                    read -rsn1 2>/dev/null || true
                    stty -echo -icanon min 1 time 0 2>/dev/null || true
                    tput civis 2>/dev/null || true
                    redraw
                    ;;
                ""|$'\r'|$'\n')
                    SELECTED_INDICES_RESULT=()
                    [[ ${#selected[@]} -gt 0 ]] && SELECTED_INDICES_RESULT=("${selected[@]}")
                    return 0
                    ;;
                "q"|"Q")
                    SELECTED_INDICES_RESULT=()
                    return 2
                    ;;
            esac
        done

        # Fallback (should not be reached)
        SELECTED_INDICES_RESULT=()
        [[ ${#selected[@]} -gt 0 ]] && SELECTED_INDICES_RESULT=("${selected[@]}")
        return 0
    }

    local selected_indices=()
    if [[ "$AUTO_YES" == "true" ]]; then
        selected_indices=("${!item_keys[@]}")
    elif [[ -t 0 ]]; then
        local menu_exit_code=0
        run_interactive_branch_menu || menu_exit_code=$?
        if [[ $menu_exit_code -eq 2 ]]; then
            # User pressed 'q' to quit
            drain_stdin
            return 0
        fi
        selected_indices=("${SELECTED_INDICES_RESULT[@]:-}")
    else
        for i in "${!menu_options[@]}"; do
            echo -e "$((i+1)). ${menu_options[$i]}"
        done
        read -r -p "Enter numbers, 'all', or 'q': " choices
        [[ "$choices" =~ ^[Qq]$ ]] && return 0
        if [[ "$choices" == "all" ]]; then
            selected_indices=("${!item_keys[@]}")
        else
            local c idx
            for c in $choices; do
                if [[ "$c" =~ ^[0-9]+$ ]]; then
                    idx=$((c-1))
                    [[ $idx -ge 0 && $idx -lt ${#item_keys[@]} ]] && selected_indices+=("$idx")
                fi
            done
        fi
    fi

    [[ ${#selected_indices[@]} -eq 0 ]] && { echo "No selection."; return 0; }

    local deduped=()
    dedupe_sorted_numeric_array selected_indices deduped
    selected_indices=("${deduped[@]}")

    local plan_local=()
    local plan_remote=()
    local plan_remote_rmt=()
    local plan_remote_br=()

    for idx in "${selected_indices[@]}"; do
        local key="${item_keys[$idx]}"
        local lb="${item_local_branch[$key]}"
        local rr="${item_remote_ref[$key]}"

        if [[ -n "$lb" ]]; then
            plan_local+=("$lb")
        fi

        if [[ -n "$rr" ]]; then
            plan_remote+=("$rr")
        fi
    done

    local dedup_local=()
    if [[ ${#plan_local[@]} -gt 0 ]]; then
        dedupe_sorted_array plan_local dedup_local
    fi

    local dedup_remote=()
    local dedup_remote_rmt=()
    local dedup_remote_br=()
    if [[ ${#plan_remote[@]} -gt 0 ]]; then
        dedupe_sorted_array plan_remote dedup_remote
        local entry
        for entry in "${dedup_remote[@]}"; do
            dedup_remote_rmt+=("${entry%%/*}")
            dedup_remote_br+=("${entry#*/}")
        done
    fi

    echo -e "\n${BLUE}--- EXECUTION PLAN ---${NC}"
    for b in "${dedup_local[@]}"; do
        echo -e "  Local:  ${YELLOW}${b}${NC}"
    done
    for rr in "${dedup_remote[@]}"; do
        echo -e "  Remote: ${MAGENTA}${rr}${NC}"
    done

    if [[ "$PROOF" == "true" ]]; then
        echo -e "\n${BLUE}--- PROOF ---${NC}"
        for b in "${dedup_local[@]}"; do
            echo -e "${YELLOW}${b}${NC} is merged because:"
            echo "  git merge-base --is-ancestor refs/heads/$b $BASE_REF"
        done
        for rr in "${dedup_remote[@]}"; do
            echo -e "${MAGENTA}${rr}${NC} is merged because:"
            echo "  git merge-base --is-ancestor refs/remotes/$rr $BASE_REF"
        done
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "\n${MAGENTA}[DRY RUN] No changes made.${NC}"
        return 0
    fi

    if [[ "$AUTO_YES" != "true" ]]; then
        read -r -p "Proceed with deleting selected branches? (y/N): " confirm
        [[ ! "$confirm" =~ ^[Yy]$ ]] && { echo "Aborted."; return 0; }
    fi

    local failed_local=()
    for b in "${dedup_local[@]}"; do
        local _bh; _bh="$(git rev-parse "refs/heads/$b" 2>/dev/null || echo '')"
        if git branch -d "$b" >/dev/null 2>&1; then
            echo -e "✓ Deleted local ${YELLOW}${b}${NC}"
            log_deletion "branch" "$b" "$_bh"
        else
            failed_local+=("$b")
        fi
    done

    if [[ ${#failed_local[@]} -gt 0 ]]; then
        echo -e "\n${YELLOW}Could not safely delete these local branches:${NC}"
        for b in "${failed_local[@]}"; do
            echo -e "  ${b}"
        done

        local do_force="n"
        if [[ "$AUTO_MODE" == "true" || "$FORCE" == "true" ]]; then
            do_force="y"
        elif [[ "$FORCE" != "true" ]]; then
            read -r -p "Force delete these local branches with -D? (y/N): " do_force
        fi

        if [[ "$do_force" =~ ^[Yy]$ ]]; then
            for b in "${failed_local[@]}"; do
                local _bh; _bh="$(git rev-parse "refs/heads/$b" 2>/dev/null || echo '')"
                if git branch -D "$b" >/dev/null 2>&1; then
                    echo -e "✓ Force deleted local ${YELLOW}${b}${NC}"
                    log_deletion "branch" "$b" "$_bh"
                else
                    echo -e "✗ Failed to delete local ${YELLOW}${b}${NC}"
                fi
            done
        fi
    fi

    if [[ ${#dedup_remote[@]} -gt 0 ]]; then
        local remote_input remote_confirm="y"
        if [[ "$AUTO_MODE" != "true" && "$AUTO_YES" != "true" ]]; then
            read -r -p "Delete selected remote branches too? (Y/n): " remote_input
            remote_confirm="${remote_input:-y}"
        fi

        if [[ "$remote_confirm" =~ ^[Yy]$ ]]; then
            local i
            for i in "${!dedup_remote[@]}"; do
                if git push "${dedup_remote_rmt[$i]}" --delete "${dedup_remote_br[$i]}" >/dev/null 2>&1; then
                    echo -e "✓ Deleted remote ${MAGENTA}${dedup_remote[$i]}${NC}"
                    log_deletion "remote" "${dedup_remote[$i]}" ""
                else
                    echo -e "✗ Failed to delete remote ${MAGENTA}${dedup_remote[$i]}${NC}"
                fi
            done
        fi
    fi

    echo -e "\n${GREEN}Branch cleanup complete.${NC}"
    echo -e "${CYAN}Recovery log: ${LOG_FILE}${NC}"
    _offer_gc
    return 0
}

# ==============================================================================
# GHOST BRANCH CLEANUP
# Finds local branches whose upstream remote tracking ref has been deleted
# (shown as ": gone]" in git branch -vv). Safe to delete -- no unmerged risk.
# ==============================================================================
cleanup_ghost_branches() {
    echo -e "\n${BLUE}Scanning for ghost branches (local branches tracking deleted remotes)...${NC}"
    local cur_branch; cur_branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || echo "")"
    local ghost_names=() ghost_ages=() ghost_hashes=() ghost_aheads=()
    local _line _b
    while IFS= read -r _line; do
        [[ "$_line" != *": gone]"* ]] && continue
        _b="$(awk '{print $1}' <<< "$_line" | tr -d '*')"
        _b="${_b//[[:space:]]/}"
        [[ -z "$_b" || "$_b" == "$cur_branch" ]] && continue
        is_protected_branch_name "$_b" && continue
        local _ahead; _ahead="$(git rev-list --count "HEAD..refs/heads/$_b" 2>/dev/null || echo '?')"
        local _age;   _age="$(git log -1 --pretty=%cr "refs/heads/$_b" 2>/dev/null || echo unknown)"
        local _hash;  _hash="$(git rev-parse "refs/heads/$_b" 2>/dev/null || echo '')"
        ghost_names+=("$_b"); ghost_ages+=("$_age")
        ghost_hashes+=("$_hash"); ghost_aheads+=("$_ahead")
    done < <(git branch -vv 2>/dev/null)

    if [[ ${#ghost_names[@]} -eq 0 ]]; then
        echo -e "\n${GREEN}No ghost branches found. Every local branch has a live upstream.${NC}"
        echo -e "${BLUE}Press Enter to return to the main menu...${NC}"
        read -r _dummy_pause
        return 0
    fi

    local menu_options=()
    local _gi
    for _gi in "${!ghost_names[@]}"; do
        menu_options+=("${YELLOW}${ghost_names[$_gi]}${NC} ${RED}[upstream: gone]${NC}  last commit: ${ghost_ages[$_gi]}  ahead of HEAD: ${ghost_aheads[$_gi]} commit(s)")
    done

    local SELECTED_INDICES_RESULT=()
    local selected_indices=()
    if [[ -t 0 ]]; then
        local _ghost_menu_fn
        run_interactive_ghost_menu() {
            local n=${#menu_options[@]} cursor=0 selected=() key rest stty_orig=""
            [[ -t 0 ]] || return 1
            stty_orig=$(stty -g 2>/dev/null) || true
            stty -echo -icanon min 1 time 0 2>/dev/null || true
            tput civis 2>/dev/null || true
            _cleanup_g() {
                [[ -n "${stty_orig:-}" ]] && stty "${stty_orig}" 2>/dev/null || true
                tput cnorm 2>/dev/null || true; drain_stdin
            }
            trap _cleanup_g RETURN
            _redraw_g() {
                local i j mark cb item_text
                tput cup 0 0 2>/dev/null; tput ed 2>/dev/null
                echo -e "${BLUE}Select ghost branches to delete:${NC}"
                echo -e "${BLUE}↑/↓ move  Space toggle  a all  s safe  p preview  Enter confirm  q quit${NC}\n"
                for i in $(seq 0 $((n-1))); do
                    mark=" "
                    for j in "${selected[@]:-}"; do
                        [[ -z "$j" ]] && continue
                        [[ "$j" == "$i" ]] && mark="x"
                    done
                    cb="[ ]"
                    item_text="${menu_options[$i]}"
                    if [[ "$mark" == "x" ]]; then
                        cb="${BOLD}${GREEN}[x]${NC}"
                        item_text="\033[7m${item_text}\033[27m"
                    fi
                    if [[ $i -eq $cursor ]]; then
                        echo -e "  > ${cb} ${item_text}"
                    else
                        echo -e "    ${cb} ${item_text}"
                    fi
                done
            }
            _redraw_g
            while true; do
                key=""; IFS= read -rsn1 key 2>/dev/null || true
                if [[ "$key" == $'\e' ]]; then
                    read -rsn2 -t 0.1 rest 2>/dev/null || true
                    [[ "$rest" == "[A" ]] && ((cursor > 0)) && cursor=$((cursor-1)) && _redraw_g
                    [[ "$rest" == "[B" ]] && ((cursor < n-1)) && cursor=$((cursor+1)) && _redraw_g
                    continue
                fi
                case "$key" in
                    " ") local found=0 ns=()
                         for j in "${selected[@]:-}"; do
                             [[ -z "$j" ]] && continue
                             [[ "$j" == "$cursor" ]] && found=1 || ns+=("$j")
                         done
                         [[ $found -eq 0 ]] && ns+=("$cursor")
                         selected=()
                         [[ ${#ns[@]} -gt 0 ]] && selected=("${ns[@]}")
                         _redraw_g ;;
                    "a"|"A"|"s"|"S") selected=(); for j in $(seq 0 $((n-1))); do selected+=("$j"); done; _redraw_g ;;
                    "p"|"P") [[ -n "${stty_orig:-}" ]] && stty "${stty_orig}" 2>/dev/null; tput cnorm 2>/dev/null; clear
                             echo -e "${BOLD}${CYAN}Ghost Branch Preview${NC}: ${ghost_names[$cursor]}"
                             echo -e "${YELLOW}Last commit hash: ${ghost_hashes[$cursor]:-unknown}${NC}"
                             echo -e "${BLUE}--- Last 5 commits ---${NC}"
                             git log -5 --oneline --decorate "refs/heads/${ghost_names[$cursor]}" 2>/dev/null || echo "(no commits)"
                             echo -e "\n${BLUE}Press any key to return...${NC}"; read -rsn1 2>/dev/null
                             stty -echo -icanon min 1 time 0 2>/dev/null; tput civis 2>/dev/null; _redraw_g ;;
                    ""|$'\r'|$'\n') SELECTED_INDICES_RESULT=(); [[ ${#selected[@]} -gt 0 ]] && SELECTED_INDICES_RESULT=("${selected[@]}"); return 0 ;;
                    "q"|"Q") SELECTED_INDICES_RESULT=(); return 2 ;;
                esac
            done
        }
        local menu_exit_code=0
        run_interactive_ghost_menu || menu_exit_code=$?
        unset -f run_interactive_ghost_menu
        [[ $menu_exit_code -eq 2 ]] && { drain_stdin; return 0; }
        selected_indices=("${SELECTED_INDICES_RESULT[@]:-}")
    fi

    [[ ${#selected_indices[@]} -eq 0 ]] && { echo "No selection."; return 0; }
    local deduped=()
    dedupe_sorted_numeric_array selected_indices deduped
    selected_indices=("${deduped[@]}")

    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "\n${MAGENTA}[DRY RUN] Would delete ghost branches:${NC}"
        for idx in "${selected_indices[@]}"; do echo "  ${ghost_names[$idx]}"; done
        return 0
    fi
    if [[ "$AUTO_YES" != "true" ]]; then
        echo -e "\n${YELLOW}Tip: To recover after deletion: git checkout -b <name> <hash>${NC}"
        read -r -p "Delete ${#selected_indices[@]} ghost branch(es)? (y/N): " _confirm
        [[ ! "$_confirm" =~ ^[Yy]$ ]] && { echo "Aborted."; return 0; }
    fi
    local _gdel=0
    for idx in "${selected_indices[@]}"; do
        local _gb="${ghost_names[$idx]}" _gh="${ghost_hashes[$idx]}"
        if git branch -D "$_gb" >/dev/null 2>&1; then
            echo -e "✓ Deleted ghost branch: ${YELLOW}${_gb}${NC}  (hash: ${_gh:0:8})"
            log_deletion "ghost" "$_gb" "$_gh"
            _gdel=$((_gdel + 1))
        else
            echo -e "✗ Failed to delete: ${_gb}"
        fi
    done
    if [[ $_gdel -gt 0 ]]; then
        echo -e "\n${CYAN}Recovery log: ${LOG_FILE}${NC}"
        echo -e "${YELLOW}Recover any branch via: git checkout -b <name> <hash-from-log>${NC}"
        _offer_gc
    fi
    echo -e "\n${GREEN}Ghost branch cleanup complete.${NC}"
    return 0
}

# ==============================================================================
# STASH CLEANUP
# Lists stashes with age and diff preview; allows selective dropping.
# ==============================================================================
cleanup_stashes() {
    echo -e "\n${BLUE}Scanning stashes...${NC}"
    local stash_refs=() stash_labels=()
    local _sl
    while IFS= read -r _sl; do
        [[ -z "$_sl" ]] && continue
        local _ref; _ref="$(cut -d: -f1 <<< "$_sl")"
        local _msg; _msg="$(cut -d: -f2- <<< "$_sl")"
        local _age; _age="$(git log -1 --pretty=%cr "$_ref" 2>/dev/null || echo unknown)"
        stash_refs+=("$_ref")
        stash_labels+=("${YELLOW}${_ref}${NC} ${CYAN}(${_age})${NC} —${_msg}")
    done < <(git stash list 2>/dev/null)

    if [[ ${#stash_refs[@]} -eq 0 ]]; then
        echo -e "\n${GREEN}No stashes found.${NC}"
        echo -e "${BLUE}Press Enter to return to the main menu...${NC}"
        read -r _dummy_pause
        return 0
    fi

    local SELECTED_INDICES_RESULT=()
    local selected_indices=()
    if [[ -t 0 ]]; then
        run_interactive_stash_menu() {
            local n=${#stash_labels[@]} cursor=0 selected=() key rest stty_orig=""
            [[ -t 0 ]] || return 1
            stty_orig=$(stty -g 2>/dev/null) || true
            stty -echo -icanon min 1 time 0 2>/dev/null || true
            tput civis 2>/dev/null || true
            _cleanup_s() {
                [[ -n "${stty_orig:-}" ]] && stty "${stty_orig}" 2>/dev/null; tput cnorm 2>/dev/null; drain_stdin
            }
            trap _cleanup_s RETURN
            _redraw_s() {
                local i j mark cb item_text
                tput cup 0 0 2>/dev/null; tput ed 2>/dev/null
                echo -e "${BLUE}Select stashes to drop:${NC}"
                echo -e "${BLUE}↑/↓ move  Space toggle  a all  p preview  Enter confirm  q quit${NC}\n"
                for i in $(seq 0 $((n-1))); do
                    mark=" "
                    for j in "${selected[@]:-}"; do
                        [[ -z "$j" ]] && continue
                        [[ "$j" == "$i" ]] && mark="x"
                    done
                    cb="[ ]"
                    item_text="${stash_labels[$i]}"
                    if [[ "$mark" == "x" ]]; then
                        cb="${BOLD}${GREEN}[x]${NC}"
                        item_text="\033[7m${item_text}\033[27m"
                    fi
                    if [[ $i -eq $cursor ]]; then
                        echo -e "  > ${cb} ${item_text}"
                    else
                        echo -e "    ${cb} ${item_text}"
                    fi
                done
            }
            _redraw_s
            while true; do
                key=""; IFS= read -rsn1 key 2>/dev/null || true
                if [[ "$key" == $'\e' ]]; then
                    read -rsn2 -t 0.1 rest 2>/dev/null || true
                    [[ "$rest" == "[A" ]] && ((cursor > 0)) && cursor=$((cursor-1)) && _redraw_s
                    [[ "$rest" == "[B" ]] && ((cursor < n-1)) && cursor=$((cursor+1)) && _redraw_s
                    continue
                fi
                case "$key" in
                    " ") local found=0 ns=()
                         for j in "${selected[@]:-}"; do
                             [[ -z "$j" ]] && continue
                             [[ "$j" == "$cursor" ]] && found=1 || ns+=("$j")
                         done
                         [[ $found -eq 0 ]] && ns+=("$cursor")
                         selected=()
                         [[ ${#ns[@]} -gt 0 ]] && selected=("${ns[@]}")
                         _redraw_s ;;
                    "a"|"A") selected=(); for j in $(seq 0 $((n-1))); do selected+=("$j"); done; _redraw_s ;;
                    "p"|"P") [[ -n "${stty_orig:-}" ]] && stty "${stty_orig}" 2>/dev/null; tput cnorm 2>/dev/null; clear
                             echo -e "${BOLD}${CYAN}Stash Preview${NC}: ${stash_refs[$cursor]}"
                             echo -e "${BLUE}--- Diff stat ---${NC}"
                             git stash show --stat "${stash_refs[$cursor]}" 2>/dev/null || echo "(no diff)"
                             echo -e "${BLUE}--- Stash message ---${NC}"
                             git log -1 --pretty='%B' "${stash_refs[$cursor]}" 2>/dev/null || echo "(no message)"
                             echo -e "\n${BLUE}Press any key to return...${NC}"; read -rsn1 2>/dev/null
                             stty -echo -icanon min 1 time 0 2>/dev/null; tput civis 2>/dev/null; _redraw_s ;;
                    ""|$'\r'|$'\n') SELECTED_INDICES_RESULT=(); [[ ${#selected[@]} -gt 0 ]] && SELECTED_INDICES_RESULT=("${selected[@]}"); return 0 ;;
                    "q"|"Q") SELECTED_INDICES_RESULT=(); return 2 ;;
                esac
            done
        }
        local menu_exit_code=0
        run_interactive_stash_menu || menu_exit_code=$?
        unset -f run_interactive_stash_menu
        [[ $menu_exit_code -eq 2 ]] && { drain_stdin; return 0; }
        selected_indices=("${SELECTED_INDICES_RESULT[@]:-}")
    fi

    [[ ${#selected_indices[@]} -eq 0 ]] && { echo "No selection."; return 0; }
    local deduped=()
    dedupe_sorted_numeric_array selected_indices deduped
    # Drop in reverse order so stash@{N} indices remain valid
    local _reversed=()
    for (( _ri=${#deduped[@]}-1; _ri>=0; _ri-- )); do _reversed+=("${deduped[$_ri]}"); done

    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "\n${MAGENTA}[DRY RUN] Would drop:${NC}"
        for idx in "${deduped[@]}"; do echo "  ${stash_refs[$idx]}"; done
        return 0
    fi
    if [[ "$AUTO_YES" != "true" ]]; then
        read -r -p "Drop ${#deduped[@]} stash(es)? This CANNOT be undone. (y/N): " _sc
        [[ ! "$_sc" =~ ^[Yy]$ ]] && { echo "Aborted."; return 0; }
    fi
    local _sdrop=0
    for idx in "${_reversed[@]}"; do
        local _sr="${stash_refs[$idx]}"
        if git stash drop "$_sr" >/dev/null 2>&1; then
            echo -e "✓ Dropped ${YELLOW}${_sr}${NC}"
            log_deletion "stash" "$_sr" ""
            _sdrop=$((_sdrop + 1))
        else
            echo -e "✗ Failed to drop ${_sr} (index may have shifted)"
        fi
    done
    echo -e "\n${GREEN}Dropped ${_sdrop} stash(es).${NC}"
    [[ $_sdrop -gt 0 ]] && echo -e "${CYAN}Deletion log: ${LOG_FILE}${NC}"
    return 0
}

run_auto_mode() {
    echo -e "${BOLD}${CYAN}Running in AUTO mode${NC}"
    echo -e "Base Ref: ${YELLOW}${BASE_REF}${NC}"
    echo ""

    cleanup_worktrees merged
    echo ""
    cleanup_branches
    echo ""
    echo -e "${GREEN}AUTO mode cleanup complete.${NC}"
}

show_help_reference() {
    clear || tput ed 2>/dev/null || true
    echo -e "${BOLD}${CYAN}GIT REPO CLEANUP HELP${NC}"
    echo -e "=========================\n"
    echo -e "${BOLD}MAIN MENU OPTIONS:${NC}"
    echo -e "  ${YELLOW}1) Clean Merged Worktrees${NC}"
    echo -e "     - Scans and shows disk size for each worktree."
    echo -e "     - Includes ${CYAN}[EMPTY/PRISTINE]${NC} worktrees (no commits, no changes)."
    echo -e "  ${YELLOW}2) Clean Unmerged Worktrees${NC}"
    echo -e "     - Scans for worktrees with work NOT merged into ${BASE_REF}."
    echo -e "     - ${RED}CAUTION:${NC} Deleting these will permanently lose uncommitted work."
    echo -e "  ${YELLOW}3) Clean Merged Branches${NC}"
    echo -e "     - Sorted oldest-first. Deletes local and/or remote merged branches."
    echo -e "  ${YELLOW}4) Clean Ghost Branches${NC}"
    echo -e "     - Local branches whose remote upstream has been deleted."
    echo -e "     - Safe to remove; logs hash for recovery."
    echo -e "  ${YELLOW}5) Clean Stashes${NC}"
    echo -e "     - Review and selectively drop stashes with diff previews.\n"

    echo -e "${BOLD}INTERACTIVE MENU CONTROLS:${NC}"
    echo -e "  ${BLUE}↑/↓${NC}    : Move cursor"
    echo -e "  ${BLUE}Space${NC}  : Toggle selection"
    echo -e "  ${BLUE}e / E${NC}  : Select Empty / Pristine Worktrees"
    echo -e "  ${BLUE}s / S${NC}  : Select Safe bounds (items with no uncommitted changes)"
    echo -e "  ${BLUE}a / A${NC}  : Select all items"
    echo -e "  ${BLUE}p / P${NC}  : Preview commits / diff for highlighted item"
    echo -e "  ${BLUE}Enter${NC}  : Confirm and execute deletion"
    echo -e "  ${BLUE}q / Q${NC}  : Abort and return to main menu\n"

    echo -e "${BOLD}STATUS TAGS:${NC}"
    echo -e "  ${GREEN}[MERGED]${NC}         : Safely merged into base ref."
    echo -e "  ${RED}[UNMERGED]${NC}       : Has unique commits not in base ref."
    echo -e "  ${RED}[DIRTY]${NC}          : Has unstaged or staged changes."
    echo -e "  ${CYAN}[EMPTY/PRISTINE]${NC} : No commits on branch, no local changes."
    echo -e "  ${RED}[upstream: gone]${NC} : Remote tracking branch was deleted.\n"

    echo -e "${BOLD}CONFIGURABLE PROTECTIONS:${NC}"
    echo -e "  git config cleanup.protected 'branch1,branch2'"
    echo -e "  or add branch names (one per line) to .gitcleanup in repo root.\n"

    echo -e "${BOLD}DELETION LOG:${NC}"
    echo -e "  All deletions are logged to: ${CYAN}${LOG_FILE}${NC}"
    echo -e "  Recover a deleted branch:  git checkout -b <name> <hash>\n"

    echo -e "${BLUE}Press Enter to return to the main menu...${NC}"
    read -r _
}

# ==============================================================================
# MAIN MENU LOOP
# ==============================================================================
if [[ "$AUTO_MODE" == "true" ]]; then
    run_auto_mode
    exit 0
fi

while true; do
    drain_stdin
    clear || tput ed 2>/dev/null || true
    echo -e "${BOLD}${CYAN}==========================================${NC}"
    echo -e "${BOLD}${CYAN}         GIT REPO CLEANUP SUITE           ${NC}"
    echo -e "${BOLD}${CYAN}==========================================${NC}"
    echo -e "Base Ref: ${YELLOW}${BASE_REF}${NC}"
    echo ""
    echo -e "  1) Clean Merged Worktrees"
    echo -e "  2) Clean Unmerged Worktrees"
    echo -e "  3) Clean Merged Branches"
    echo -e "  4) Clean Ghost Branches ${CYAN}(upstream deleted)${NC}"
    echo -e "  5) Clean Stashes"
    echo -e "  h) Help Reference"
    echo -e "  q) Quit"
    echo ""
    read -r -p "Select an option: " choice

    case "$choice" in
        1) cleanup_worktrees merged ;;
        2) cleanup_worktrees unmerged ;;
        3) cleanup_branches ;;
        4) cleanup_ghost_branches ;;
        5) cleanup_stashes ;;
        h|H) show_help_reference ;;
        q|Q)
            echo -e "\nExiting. Have a great day!"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            sleep 1
            ;;
    esac
done

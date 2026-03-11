#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     compare.sh
#    
#     Copyright (C) 2024-2026 Faisal Shahzad <info@serpwings.com>
#
# <LICENSE_BLOCK>
# The contents of this file are subject to the MIT License.
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# https://opensource.org/licenses/MIT
# https://github.com/serpwings/gut/blob/main/LICENSE
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
# specific language governing rights and limitations under the License.
# </LICENSE_BLOCK>

source "${LIB_DIR}/utils.sh"

gut_compare() {
    local target="${1:-}"

    if [[ -z "$target" ]]; then
        gut_error "Usage: gut compare <branch-or-commit>"
        exit 1
    fi

    local current
    current=$(git rev-parse --abbrev-ref HEAD)

    if ! git rev-parse --verify "$target" >/dev/null 2>&1; then
        gut_error "Unknown branch or commit: '${target}'"
        exit 1
    fi

    gut_header "Comparing ${current}  ${target}"
    echo ""

    # Commits ahead/behind
    local ahead behind
    ahead=$(git rev-list --count "${target}..HEAD" 2>/dev/null || echo 0)
    behind=$(git rev-list --count "HEAD..${target}" 2>/dev/null || echo 0)

    echo -e "  ${CLR_GREEN} ${ahead} commit(s) ahead${CLR_RESET} of ${CLR_CYAN}${target}${CLR_RESET}"
    echo -e "  ${CLR_YELLOW} ${behind} commit(s) behind${CLR_RESET} ${CLR_CYAN}${target}${CLR_RESET}"
    echo ""

    # File diff summary
    local diff_stat
    diff_stat=$(git diff --stat "${target}...HEAD" 2>/dev/null)
    if [[ -n "$diff_stat" ]]; then
        echo -e "${CLR_BWHITE}Changed Files:${CLR_RESET}"
        git diff --stat "${target}...HEAD" | while IFS= read -r line; do
            if echo "$line" | grep -q '|'; then
                local fname additions deletions
                fname=$(echo "$line" | awk '{print $1}')
                local plusminus
                plusminus=$(echo "$line" | awk '{print $3}')
                local changes
                changes=$(echo "$line" | awk '{print $2}')
                echo -e "  ${CLR_CYAN}${fname}${CLR_RESET} ${CLR_DIM}(${changes} change(s))${CLR_RESET}"
            else
                # summary line
                echo -e "  ${CLR_DIM}${line}${CLR_RESET}"
            fi
        done
    else
        echo "  (no file differences)"
    fi

    echo ""

    # Unique commits on current branch
    if [[ $ahead -gt 0 ]]; then
        echo -e "${CLR_BWHITE}Commits only in ${current}:${CLR_RESET}"
        git log --oneline "${target}..HEAD" | while IFS= read -r line; do
            echo -e "  ${CLR_GREEN}+${CLR_RESET} ${line}"
        done
        echo ""
    fi

    # Unique commits in target branch
    if [[ $behind -gt 0 ]]; then
        echo -e "${CLR_BWHITE}Commits only in ${target}:${CLR_RESET}"
        git log --oneline "HEAD..${target}" | while IFS= read -r line; do
            echo -e "  ${CLR_YELLOW}-${CLR_RESET} ${line}"
        done
    fi
}

gut_compare "$@"

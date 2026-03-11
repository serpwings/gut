#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     status.sh
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

gut_status() {
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "not on a branch")
    
    gut_header "Repository Status"
    echo -e "${CLR_BMAGENTA} Branch: ${CLR_RESET}${CLR_BOLD}${branch}${CLR_RESET}"
    
    # Check for detached HEAD
    if [[ "$branch" == "HEAD" ]]; then
        gut_warn "You are in a detached HEAD state!"
    fi

    # 1. Staged changes (The Index/Pre-commit)
    local staged
    staged=$(git diff --cached --name-status)
    echo -e "\n${CLR_BGREEN} Staged (Ready to save):${CLR_RESET}"
    if [[ -n "$staged" ]]; then
        while read -r line; do
            local status="${line:0:1}"
            local file="${line:2}"
            case "$status" in
                A) echo -e "  ${CLR_GREEN}[NEW]    ${file}${CLR_RESET}" ;;
                M) echo -e "  ${CLR_YELLOW}[MOD]    ${file}${CLR_RESET}" ;;
                D) echo -e "  ${CLR_RED}[DEL]    ${file}${CLR_RESET}" ;;
                *) echo -e "  ${CLR_DIM}[?]      ${file}${CLR_RESET}" ;;
            esac
        done <<< "$staged"
    else
        echo -e "  ${CLR_DIM}(nothing staged)${CLR_RESET}"
    fi

    # 2. Unstaged changes (The Working Tree)
    local unstaged
    unstaged=$(git diff --name-status)
    echo -e "\n${CLR_BYELLOW} Unstaged (Modified but not staged):${CLR_RESET}"
    if [[ -n "$unstaged" ]]; then
        while read -r line; do
            local status="${line:0:1}"
            local file="${line:2}"
            case "$status" in
                M) echo -e "  ${CLR_YELLOW}[MOD]    ${file}${CLR_RESET}" ;;
                D) echo -e "  ${CLR_RED}[DEL]    ${file}${CLR_RESET}" ;;
                *) echo -e "  ${CLR_DIM}[?]      ${file}${CLR_RESET}" ;;
            esac
        done <<< "$unstaged"
    else
        echo -e "  ${CLR_DIM}(nothing modified)${CLR_RESET}"
    fi

    # 3. Untracked files
    local untracked
    untracked=$(git ls-files --others --exclude-standard)
    echo -e "\n${CLR_BWHITE} Untracked (New files not yet managed):${CLR_RESET}"
    if [[ -n "$untracked" ]]; then
        while read -r file; do
            echo -e "  ${CLR_DIM}[NEW]    ${file}${CLR_RESET}"
        done <<< "$untracked"
    else
        echo -e "  ${CLR_DIM}(no untracked files)${CLR_RESET}"
    fi
    echo ""
}

gut_history() {
    local limit="${1:-10}"
    gut_header "Recent History (Last ${limit})"
    git log -n "$limit" --graph --pretty=format:'%C(auto)%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'
    echo -e "\n"
}

# Entry point for the sourced script
case "${cmd_context}" in
    status) gut_status "$@" ;;
    history) gut_history "$@" ;;
esac

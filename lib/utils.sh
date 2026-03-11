#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     utils.sh
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

# Load colors if available
LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"
if [[ -f "${LIB_DIR}/colors.sh" ]]; then
    source "${LIB_DIR}/colors.sh"
fi

# Logging functions
gut_log() {
    echo -e "${CLR_BLUE} $*${CLR_RESET}"
}

gut_success() {
    echo -e "${CLR_GREEN} $*${CLR_RESET}"
}

gut_warn() {
    echo -e "${CLR_YELLOW} $*${CLR_RESET}"
}

gut_error() {
    echo -e "${CLR_RED} $*${CLR_RESET}" >&2
}

# Confirmation prompt
gut_confirm() {
    local prompt="$1"
    local default="${2:-n}" # Default to 'n' for safety
    
    if [[ "${default}" == "y" ]]; then
        prompt="${prompt} [Y/n] "
    else
        prompt="${prompt} [y/N] "
    fi
    
    read -p "$(echo -e "${CLR_BCYAN} ${prompt}${CLR_RESET}")" choice
    choice="${choice:-${default}}"
    
    local choice_lower; choice_lower="$(echo "$choice" | tr '[:upper:]' '[:lower:]')"
    case "$choice_lower" in
        y|yes) return 0 ;;
        *) return 1 ;;
    esac
}

# Check if in a git repo
gut_is_repo() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        return 1
    fi
    return 0
}

# Translate cryptic git errors
gut_translate_error() {
    local error_msg="$1"
    
    if [[ "$error_msg" == *"detached HEAD"* ]]; then
        gut_error "You are in a 'detached HEAD' state."
        echo "This means you aren't on any branch. Changes you save won't belong to a branch."
        echo -e "Fix: ${CLR_CYAN}gut switch <branch-name>${CLR_RESET} to return to a branch,"
        echo -e "or ${CLR_CYAN}gut branch new <name>${CLR_RESET} to save your current state to a new branch."
    elif [[ "$error_msg" == *"diverged"* ]]; then
        gut_error "Your branch and the remote branch have diverged."
        echo "Both you and others have made different changes."
        echo -e "Fix: ${CLR_CYAN}gut sync --reconcile${CLR_RESET} to merge or rebase the changes."
    elif [[ "$error_msg" == *"non-fast-forward"* ]]; then
        gut_error "Cannot push: the remote has changes you don't have."
        echo "Someone else pushed updates while you were working."
        echo -e "Fix: ${CLR_CYAN}gut sync${CLR_RESET} to get the latest changes first."
    elif [[ "$error_msg" == *"no upstream branch"* ]]; then
        gut_error "This branch isn't connected to a remote branch yet."
        echo -e "Fix: ${CLR_CYAN}gut sync --publish${CLR_RESET} to push this branch for the first time."
    else
        gut_error "$error_msg"
    fi
}

# Header helper
gut_header() {
    local title="$1"
    echo -e "\n${CLR_BWHITE}${CLR_DIM}=== ${title} ===${CLR_RESET}"
}

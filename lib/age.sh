#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     age.sh
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

gut_age() {
    gut_header "Branch Ages"
    echo ""

    # Determine main branch
    local main_branch
    main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|.*/||')
    [[ -z "$main_branch" ]] && main_branch="main"
    git rev-parse --verify "$main_branch" >/dev/null 2>&1 || main_branch="master"

    echo -e "  ${CLR_DIM}Base branch: ${CLR_CYAN}${main_branch}${CLR_RESET}"
    echo ""

    local current
    current=$(git rev-parse --abbrev-ref HEAD)

    git branch --format='%(refname:short) %(creatordate:relative)' 2>/dev/null | \
        sort -t' ' -k2 | while IFS= read -r line; do
            local branch age ahead behind status_icon
            branch=$(echo "$line" | awk '{print $1}')
            age=$(echo "$line" | cut -d' ' -f2-)

            ahead=$(git rev-list --count "${main_branch}..${branch}" 2>/dev/null || echo 0)
            behind=$(git rev-list --count "${branch}..${main_branch}" 2>/dev/null || echo 0)

            local marker=""
            [[ "$branch" == "$current" ]] && marker=" ${CLR_GREEN} current${CLR_RESET}"

            echo -e "  ${CLR_CYAN}${branch}${CLR_RESET}${marker}"
            echo -e "    ${CLR_DIM}Created: ${age}${CLR_RESET}  ${CLR_GREEN}${ahead} ahead${CLR_RESET}  ${CLR_YELLOW}${behind} behind ${main_branch}${CLR_RESET}"
        done
}

gut_age "$@"

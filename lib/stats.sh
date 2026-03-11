#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     stats.sh
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

gut_stats() {
    gut_header "Contributor Statistics"
    echo ""

    local total_commits
    total_commits=$(git rev-list --count HEAD 2>/dev/null || echo 0)
    echo -e "  ${CLR_BWHITE}Total commits:${CLR_RESET} ${total_commits}"
    echo ""

    echo -e "  ${CLR_BWHITE}Commits per author:${CLR_RESET}"
    git shortlog -sn --no-merges HEAD 2>/dev/null | while IFS= read -r line; do
        local count name pct
        count=$(echo "$line" | awk '{print $1}')
        name=$(echo "$line" | cut -f2-)
        pct=$(( count * 100 / total_commits ))
        # Build a mini bar chart
        local bar=""
        local filled=$(( pct / 5 ))
        for ((i=0; i<filled; i++)); do bar+=""; done
        for ((i=filled; i<20; i++)); do bar+=""; done
        echo -e "  ${CLR_CYAN}${name}${CLR_RESET}"
        echo -e "    ${CLR_GREEN}${bar}${CLR_RESET} ${count} commits (${pct}%)"
    done
    echo ""

    echo -e "  ${CLR_BWHITE}Lines per author (approximate):${CLR_RESET}"
    git log --no-merges --numstat --format="AUTHOR:%an" HEAD 2>/dev/null | \
        awk '
            /^AUTHOR:/ { current=substr($0,8); next }
            /^[0-9]/ && current != "" { add[current]+=$1; del[current]+=$2 }
            END { for (a in add) printf "    %-30s +%d / -%d\n", a, add[a], del[a] }
        ' | sort -t+ -k2 -rn | head -10 | while IFS= read -r line; do
            echo -e "  ${CLR_CYAN}${line}${CLR_RESET}"
        done
}

gut_stats "$@"

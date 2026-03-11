#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     blame.sh
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

gut_blame() {
    local file="${1:-}"

    if [[ -z "$file" ]]; then
        gut_error "Usage: gut blame <file>"
        exit 1
    fi

    if [[ ! -f "$file" ]]; then
        gut_error "File not found: '${file}'"
        exit 1
    fi

    gut_header "Blame: ${file}"
    echo ""

    local prev_author=""
    git blame --date=short "$file" 2>/dev/null | while IFS= read -r line; do
        local hash author date lineno code
        hash=$(echo "$line" | awk '{print $1}')
        author=$(echo "$line" | awk '{print $2}' | tr -d '(')
        date=$(echo "$line" | awk '{print $3}')
        lineno=$(echo "$line" | awk '{print $4}' | tr -d ')')
        code=$(echo "$line" | cut -d')' -f2-)

        if [[ "${author}" != "${prev_author}" ]]; then
            echo -e "${CLR_DIM}${hash:0:7} ${CLR_CYAN}${author}${CLR_RESET} ${CLR_DIM}${date}${CLR_RESET}"
            prev_author="$author"
        fi
        echo -e "  ${CLR_DIM}${lineno}${CLR_RESET}${code}"
    done
}

gut_blame "$@"

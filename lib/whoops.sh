#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     whoops.sh
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

gut_whoops() {
    gut_header "Recent States (Reflog)"

    local entries=()
    local i=0
    while IFS= read -r line; do
        entries+=("$line")
        i=$((i + 1))
        if [[ $i -ge 15 ]]; then break; fi
    done < <(git reflog --format="%C(yellow)%gd%C(reset) %C(dim)%ar%C(reset)  %gs" 2>/dev/null \
            || git reflog | head -15)

    if [[ ${#entries[@]} -eq 0 ]]; then
        gut_warn "No reflog entries found."
        return
    fi

    echo ""
    local j=1
    for entry in "${entries[@]}"; do
        echo -e "  ${CLR_CYAN}${j})${CLR_RESET} ${entry}"
        j=$((j + 1))
    done

    echo ""
    echo -n -e "${CLR_BCYAN}Jump to which state? (number, or Enter to cancel): ${CLR_RESET}"
    read -r choice

    if [[ -z "$choice" ]]; then
        gut_log "Cancelled."
        return
    fi

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [[ "$choice" -lt 1 ]] || [[ "$choice" -gt ${#entries[@]} ]]; then
        gut_error "Invalid choice."
        exit 1
    fi

    local ref="HEAD@{$((choice - 1))}"
    gut_warn "This will move HEAD back to: ${entries[$((choice-1))]}"
    if gut_confirm "Continue? (Your current work will be stashed first as a snapshot)"; then
        # Save current work first
        if ! git diff --quiet || ! git diff --cached --quiet; then
            local ts
            ts=$(date '+%Y-%m-%d %H:%M:%S')
            git stash push --include-untracked --message "whoops-autosave: ${ts}"
            gut_log "Current work saved to stash (just in case)."
        fi
        git reset --hard "$ref"
        gut_success "Jumped to: ${ref}"
        echo "If this was wrong, you can run 'gut whoops' again to jump back."
    fi
}

gut_whoops "$@"

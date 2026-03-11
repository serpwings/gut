#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     integrate.sh
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

gut_integrate() {
    local from="$1"

    if [[ -z "$from" ]]; then
        gut_error "Source branch required."
        echo "Usage: gut integrate <branch>"
        exit 1
    fi

    local current
    current=$(git rev-parse --abbrev-ref HEAD)

    gut_log "Integrating '${from}' into '${current}'..."
    echo ""
    echo "What would you like to do?"
    echo "  1) Merge   Brings in changes with a merge commit (safe, preserves history)"
    echo "  2) Rebase  Replays your commits on top of '${from}' (cleaner, rewrites history)"
    echo "  3) Cancel"
    read -r -p "$(echo -e "${CLR_CYAN}Choice [1/2/3]: ${CLR_RESET}")" choice

    case "$choice" in
        1)
            gut_log "Merging '${from}' into '${current}'..."
            if git merge --no-ff "$from"; then
                gut_success "Successfully merged '${from}' into '${current}'."
            else
                gut_error "Merge conflict detected!"
                echo ""
                echo "Files with conflicts:"
                git diff --name-only --diff-filter=U | sed 's/^/  /'
                echo ""
                echo -e "1. Edit the conflicting files."
                echo -e "2. Run ${CLR_CYAN}gut save${CLR_RESET} to mark them resolved and commit."
                echo -e "   Or run ${CLR_CYAN}gut git merge --abort${CLR_RESET} to cancel the merge."
            fi
            ;;
        2)
            gut_warn "Rebase rewrites history. If this branch is shared with others, use Merge instead."
            if gut_confirm "Continue with rebase?"; then
                gut_log "Rebasing '${current}' onto '${from}'..."
                if git rebase "$from"; then
                    gut_success "Successfully rebased '${current}' onto '${from}'."
                else
                    gut_error "Rebase conflict detected!"
                    echo ""
                    echo -e "Resolve conflicts, then run:"
                    echo -e "  ${CLR_CYAN}gut git rebase --continue${CLR_RESET}  to proceed"
                    echo -e "  ${CLR_CYAN}gut git rebase --abort${CLR_RESET}     to cancel"
                fi
            fi
            ;;
        *) gut_log "Cancelled." ;;
    esac
}

gut_integrate "$@"

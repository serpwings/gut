#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     stash.sh
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

gut_stash() {
    local sub="${1:-}"
    shift 2>/dev/null || true

    case "$sub" in
        save|"")
            local msg="${1:-}"
            if [[ -z "$msg" ]]; then
                echo -n -e "${CLR_BCYAN}  Stash description (optional): ${CLR_RESET}"
                read -r msg
            fi
            local stash_args=()
            [[ -n "$msg" ]] && stash_args+=("--message" "$msg")
            git stash push "${stash_args[@]}"
            gut_success "Work stashed! Use 'gut stash pop' to restore it."
            ;;
        pop)
            gut_log "Restoring most recent stash..."
            git stash pop
            gut_success "Stash restored."
            ;;
        list)
            gut_header "Stashes"
            if git stash list | grep -q .; then
                git stash list --format="%C(yellow)%gd%C(reset)  %s  %C(dim)%C(reset)" 2>/dev/null \
                    || git stash list
            else
                echo "  (no stashes)"
            fi
            ;;
        drop)
            local index="${1:-0}"
            gut_warn "Dropping stash@{${index}}: $(git stash list | sed -n "$((index+1))p" | cut -d: -f3-)"
            if gut_confirm "This will permanently delete this stash. Continue?"; then
                git stash drop "stash@{${index}}"
                gut_success "Stash dropped."
            fi
            ;;
        show)
            local index="${1:-0}"
            gut_header "Stash@{${index}} Contents"
            git stash show -p "stash@{${index}}"
            ;;
        apply)
            local index="${1:-0}"
            gut_log "Applying stash@{${index}} (keeping it in stash list)..."
            git stash apply "stash@{${index}}"
            gut_success "Stash applied."
            ;;
        clear)
            gut_warn "This will delete ALL stashes permanently."
            if gut_confirm "Clear all stashes?"; then
                git stash clear
                gut_success "All stashes cleared."
            fi
            ;;
        *)
            gut_error "Unknown stash subcommand: '${sub}'"
            echo "Usage: gut stash [save|pop|list|drop|show|apply|clear]"
            exit 1
            ;;
    esac
}

gut_stash "$@"

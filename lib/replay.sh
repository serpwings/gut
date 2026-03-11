#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     replay.sh
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

gut_replay() {
    # Get number of commits to replay
    local n="${1:-}"

    if [[ -z "$n" ]]; then
        gut_header "Interactive Replay (Rebase)"
        echo "How many recent commits do you want to edit?"
        echo ""
        git log --oneline -10 | nl -ba | sed 's/^/  /'
        echo ""
        read -r -p "$(echo -e "${CLR_CYAN}Number of commits [2]: ${CLR_RESET}")" n
        n="${n:-2}"
    fi

    if ! [[ "$n" =~ ^[0-9]+$ ]] || [[ "$n" -lt 1 ]]; then
        gut_error "Please enter a valid number."
        exit 1
    fi

    gut_header "Replay: Last ${n} Commits"
    echo ""
    echo "Here are the commits you're about to edit:"
    echo ""
    git log --oneline -"$n" | nl -ba | sed 's/^/  /'
    echo ""
    echo "What would you like to do?"
    echo "  1) Squash   Combine all ${n} commits into one"
    echo "  2) Reword   Edit commit messages"
    echo "  3) Drop     Delete specific commits"
    echo "  4) Reorder  Full interactive editor"
    echo "  5) Cancel"
    read -r -p "$(echo -e "${CLR_CYAN}Choice [1-5]: ${CLR_RESET}")" choice

    case "$choice" in
        1)
            # Guided squash
            gut_log "Squashing last ${n} commits..."
            echo ""
            read -r -p "$(echo -e "${CLR_CYAN}New commit message for the squashed commit: ${CLR_RESET}")" msg
            if [[ -z "$msg" ]]; then
                gut_error "Commit message cannot be empty."
                exit 1
            fi
            git reset --soft "HEAD~${n}"
            git commit -m "$msg"
            gut_success "Squashed ${n} commits into one: '${msg}'"
            ;;
        2)
            # Reword the most recent commit or open editor
            if [[ "$n" -eq 1 ]]; then
                read -r -p "$(echo -e "${CLR_CYAN}New message for the last commit: ${CLR_RESET}")" msg
                if [[ -z "$msg" ]]; then
                    gut_error "Commit message cannot be empty."
                    exit 1
                fi
                git commit --amend -m "$msg"
                gut_success "Commit message updated."
            else
                gut_warn "Rewording multiple commits requires the interactive editor."
                if gut_confirm "Open interactive rebase editor?"; then
                    GIT_SEQUENCE_EDITOR="sed -i 's/^pick /reword /'" git rebase -i "HEAD~${n}"
                fi
            fi
            ;;
        3)
            # Drop commits interactively
            gut_warn "Drop mode: choose which commit(s) to permanently DELETE."
            echo ""
            local commits=()
            while IFS= read -r line; do
                commits+=("$line")
            done < <(git log --oneline -"$n")
            for i in "${!commits[@]}"; do
                echo "  $((i+1))) ${commits[$i]}"
            done
            echo ""
            read -r -p "$(echo -e "${CLR_CYAN}Enter number(s) to drop (space-separated): ${CLR_RESET}")" drop_nums
            if gut_confirm "This will PERMANENTLY delete the selected commit(s). Continue?"; then
                # Build a sed command to replace 'pick' with 'drop' for selected lines
                local sed_expr=""
                for num in $drop_nums; do
                    sed_expr="${sed_expr}${sed_expr:+; }${num}s/^pick/drop/"
                done
                GIT_SEQUENCE_EDITOR="sed -i '${sed_expr}'" git rebase -i "HEAD~${n}"
                gut_success "Dropped selected commit(s)."
            fi
            ;;
        4)
            gut_log "Opening full interactive rebase editor..."
            git rebase -i "HEAD~${n}"
            ;;
        *) gut_log "Cancelled." ;;
    esac
}

gut_replay "$@"

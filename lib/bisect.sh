#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     bisect.sh
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

gut_bisect() {
    local sub="${1:-}"
    shift 2>/dev/null || true

    case "$sub" in
        start|"")
            gut_header "Guided Bisect (Find a Bug)"
            echo ""
            echo "Git bisect helps you find the exact commit that introduced a bug."
            echo "You'll mark commits as 'good' (no bug) or 'bad' (has bug)."
            echo ""

            local bad_commit good_commit
            echo -n -e "${CLR_BCYAN}Bad commit (has the bug) [default: HEAD]: ${CLR_RESET}"
            read -r bad_commit
            bad_commit="${bad_commit:-HEAD}"

            echo -n -e "${CLR_BCYAN}Good commit (no bug  tag, hash, or 'HEAD~N'): ${CLR_RESET}"
            read -r good_commit
            if [[ -z "$good_commit" ]]; then
                gut_error "A good commit is required to start bisect."
                exit 1
            fi

            git bisect start
            git bisect bad "$bad_commit"
            git bisect good "$good_commit"

            echo ""
            gut_success "Bisect started! Git has checked out a midpoint commit."
            echo ""
            echo "Now test if the bug exists in the current commit, then run:"
            echo -e "  ${CLR_GREEN}gut bisect good${CLR_RESET}    if the bug is NOT present"
            echo -e "  ${CLR_RED}gut bisect bad${CLR_RESET}     if the bug IS present"
            echo -e "  ${CLR_YELLOW}gut bisect skip${CLR_RESET}    skip this commit (e.g. can't test it)"
            echo -e "  ${CLR_DIM}gut bisect abort${CLR_RESET}   give up and return to HEAD"
            ;;
        good)
            local bisect_out
            bisect_out=$(git bisect good 2>&1)
            local bisect_exit=$?
            echo "$bisect_out"
            echo ""
            if [[ $bisect_exit -ne 0 ]]; then
                gut_error "Bisect error. Check output above."
            elif echo "$bisect_out" | grep -q "is the first bad commit"; then
                echo ""
                gut_success "Found it! See the commit above."
                if gut_confirm "Done bisecting? This will run 'git bisect reset' to return to HEAD."; then
                    git bisect reset
                fi
            else
                gut_log "Marked as good. Testing next candidate..."
            fi
            ;;
        bad)
            git bisect bad
            gut_log "Marked as bad. Testing next candidate..."
            ;;
        skip)
            git bisect skip
            gut_log "Skipped. Testing next candidate..."
            ;;
        abort|stop|reset)
            git bisect reset
            gut_success "Bisect aborted. Returned to HEAD."
            ;;
        log)
            gut_header "Bisect Log"
            git bisect log
            ;;
        *)
            gut_error "Unknown bisect subcommand: '${sub}'"
            echo "Usage: gut bisect [start|good|bad|skip|abort|log]"
            exit 1
            ;;
    esac
}

gut_bisect "$@"

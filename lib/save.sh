#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     save.sh
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

gut_save() {
    local message=""
    local all=0
    local amend=0
    local files=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -m)
                message="$2"
                shift 2
                ;;
            --all|-all|-a)
                all=1
                shift
                ;;
            --amend|-amend)
                amend=1
                shift
                ;;
            *)
                files+=("$1")
                shift
                ;;
        esac
    done

    # 1. Staging
    if [[ ${all} -eq 1 ]]; then
        gut_log "Staging all changes..."
        git add -A
    elif [[ ${#files[@]} -gt 0 ]]; then
        gut_log "Staging specified files: ${files[*]}"
        git add "${files[@]}"
    fi

    # Check if anything is staged
    if ! git diff --cached --quiet; then
        # 2. Committing
        if [[ -z "$message" ]]; then
            echo -n -e "${CLR_BCYAN} Enter commit message: ${CLR_RESET}"
            read -r message
            if [[ -z "$message" ]]; then
                gut_error "Commit message cannot be empty."
                exit 1
            fi
        fi

        local git_args=()
        [[ ${amend} -eq 1 ]] && git_args+=("--amend")
        git_args+=("-m" "$message")

        gut_log "Saving changes..."
        if git commit "${git_args[@]}"; then
            gut_success "Changes saved!"
        else
            gut_error "Failed to save changes."
            exit 1
        fi
    else
        if [[ ${amend} -eq 1 ]]; then
             if [[ -z "$message" ]]; then
                gut_log "Amending last commit message (opening editor)..."
                git commit --amend
            else
                git commit --amend -m "$message"
            fi
            gut_success "Last commit updated!"
        else
            gut_warn "Nothing to save. Did you forget to add files or use --all?"
        fi
    fi
}

gut_save "$@"

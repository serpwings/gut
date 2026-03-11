#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     undo.sh
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

gut_undo() {
    local hard=0
    local n=1
    local files=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --hard|-hard)
                hard=1
                shift
                ;;
            -n)
                n="$2"
                shift 2
                ;;
            *)
                files+=("$1")
                shift
                ;;
        esac
    done

    # 1. Undo specific files
    if [[ ${#files[@]} -gt 0 ]]; then
        gut_log "Restoring files to last saved state: ${files[*]}"
        if [[ ${hard} -eq 1 ]]; then
            if ! gut_confirm "This will DISCARD all unsaved changes in these files. Continue?"; then
                return
            fi
            git checkout HEAD -- "${files[@]}"
        else
            git restore --staged "${files[@]}"
            gut_success "Unstaged changes in: ${files[*]}"
            echo "To discard changes in the working tree, use: gut undo --hard [file]"
        fi
        return
    fi

    # 2. Undo last N commits (no files specified)
    local last_commit
    last_commit=$(git log -1 --pretty=format:%s 2>/dev/null || echo "No commits yet")
    
    if [[ "$last_commit" == "No commits yet" ]]; then
        gut_error "No commits to undo."
        return
    fi

    # 3. Check if we're trying to undo past the root commit
    local target_ref="HEAD~${n}"
    local has_parent=1
    if ! git rev-parse --verify "${target_ref}" >/dev/null 2>&1; then
        # We're undoing the root commit (or past it)
        has_parent=0
    fi

    if [[ ${hard} -eq 1 ]]; then
        gut_warn "DANGER: You are about to UNDO and DISCARD the last ${n} commit(s)."
        echo -e "Last commit was: ${CLR_BOLD}${last_commit}${CLR_RESET}"
        if gut_confirm "This operation is DESTRUCTIVE and cannot be easily undone. Proceed?"; then
            if [[ ${has_parent} -eq 1 ]]; then
                git reset --hard "${target_ref}"
            else
                # Delete root commit, delete working tree files
                git update-ref -d HEAD
                git rm -rf . >/dev/null 2>&1 || true
                git clean -fdx
            fi
            gut_success "Discarded last ${n} commit(s) and all local changes."
        fi
    else
        gut_log "Undoing last ${n} commit(s) but KEEPING your changes in the working tree."
        echo -e "Last commit was: ${CLR_BOLD}${last_commit}${CLR_RESET}"
        if [[ ${has_parent} -eq 1 ]]; then
            git reset --soft "${target_ref}"
        else
            # Delete root commit gently, keeping staging/working tree
            git update-ref -d HEAD
        fi
        gut_success "Last ${n} commit(s) undone. Your work is still in the staging area."
        echo "Tip: use 'gut status' to see what changed."
    fi
}

gut_undo "$@"

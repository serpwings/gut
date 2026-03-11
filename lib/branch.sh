#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     branch.sh
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

gut_branch_list() {
    gut_header "Local Branches"
    git branch --color=always | sed 's/^\*/'""' /' | sed 's/^ /  /'
}

gut_branch_new() {
    local name="$1"
    if [[ -z "$name" ]]; then
        gut_error "Branch name required."
        echo "Usage: gut branch new <name>"
        return 1
    fi
    gut_log "Creating new branch: ${name}"
    if git checkout -b "$name"; then
        gut_success "Now on branch '${name}'."
    fi
}

gut_branch_delete() {
    local name="$1"
    if [[ -z "$name" ]]; then
        gut_error "Branch name required."
        echo "Usage: gut branch delete <name>"
        return 1
    fi
    if gut_confirm "Are you sure you want to DELETE branch '${name}'?"; then
        if git branch -d "$name"; then
             gut_success "Deleted branch '${name}'."
        else
             gut_warn "Could not delete branch normally (it may have unsaved work)."
             if gut_confirm "FORCE delete branch '${name}'? (This will LOSE changes)"; then
                 git branch -D "$name"
                 gut_success "Force deleted branch '${name}'."
             fi
        fi
    fi
}

gut_branch_rename() {
    local old="$1"
    local new="$2"
    if [[ -z "$new" ]]; then
        # Rename current branch if only one arg
        new="$old"
        git branch -m "$new"
        gut_success "Renamed current branch to '${new}'."
    else
        git branch -m "$old" "$new"
        gut_success "Renamed branch '${old}' to '${new}'."
    fi
}

gut_switch() {
    local target="$1"
    if [[ -z "$target" ]]; then
        gut_error "Target branch required."
        echo "Usage: gut switch <branch>"
        return 1
    fi
    gut_log "Switching to branch: ${target}..."
    local output
    output=$(git checkout "$target" 2>&1)
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        echo "$output" >&2
        gut_error "Could not switch to branch '${target}'."
        return $exit_code
    fi
    gut_success "Now on branch '${target}'."
}

# Entry point
case "${cmd_context}" in
    branch)
        sub="$1"
        shift || true
        case "$sub" in
            list|"") gut_branch_list ;;
            new) gut_branch_new "$@" ;;
            delete) gut_branch_delete "$@" ;;
            rename) gut_branch_rename "$@" ;;
            *) gut_error "Unknown branch subcommand: $sub"; exit 1 ;;
        esac
        ;;
    switch)
        gut_switch "$@"
        ;;
esac

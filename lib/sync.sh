#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     sync.sh
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

gut_sync() {
    local publish=0
    local force=0
    local reconcile=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --publish|-publish)   publish=1; shift ;;
            --force|-force)       force=1;   shift ;;
            --reconcile|-reconcile) reconcile=1; shift ;;
            *) gut_error "Unknown option: $1"; exit 1 ;;
        esac
    done

    local branch
    branch=$(git rev-parse --abbrev-ref HEAD)

    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        gut_warn "You have unsaved local changes. These will not be synced."
        echo "Tip: run 'gut save --all' first if you want to include them."
    fi

    # --publish: first-time push of a branch
    if [[ $publish -eq 1 ]]; then
        gut_log "Publishing branch '${branch}' to remote for the first time..."
        local remote="${GIT_REMOTE:-origin}"
        if git push --set-upstream "${remote}" "${branch}"; then
            gut_success "Branch '${branch}' is now published to '${remote}'."
        else
            gut_error "Could not publish branch."
            exit 1
        fi
        return
    fi

    # Fetch remote state first
    gut_log "Fetching latest from remote..."
    local fetch_out
    fetch_out=$(git fetch --prune 2>&1)
    local fetch_exit=$?
    echo "$fetch_out" | grep -v "^$" || true
    if [[ $fetch_exit -ne 0 ]]; then
        gut_error "Could not fetch from remote. Check your connection and credentials."
        exit 1
    fi

    # Check if we have an upstream
    if ! git rev-parse --abbrev-ref --symbolic-full-name "@{u}" >/dev/null 2>&1; then
        gut_error "This branch has no remote counterpart yet."
        echo ""
        echo -e "Fix: ${CLR_CYAN}gut sync --publish${CLR_RESET}  to push this branch for the first time."
        exit 1
    fi

    local local_hash remote_hash base_hash
    local_hash=$(git rev-parse HEAD)
    remote_hash=$(git rev-parse "@{u}" 2>/dev/null)
    base_hash=$(git merge-base HEAD "@{u}" 2>/dev/null)

    if [[ "$local_hash" == "$remote_hash" ]]; then
        gut_success "Already up to date. Nothing to sync."
        return
    elif [[ "$base_hash" == "$remote_hash" ]]; then
        # We're ahead  just push
        gut_log "You have new commits to push..."
        if [[ $force -eq 1 ]]; then
            if gut_confirm "Force push? This can overwrite remote history!"; then
                git push --force-with-lease
                gut_success "Force pushed to remote."
            fi
        else
            git push
            gut_success "Changes pushed successfully."
        fi
    elif [[ "$base_hash" == "$local_hash" ]]; then
        # Remote is ahead  pull
        gut_log "Remote has new commits. Pulling..."
        git pull --ff-only 2>/dev/null || {
            gut_warn "Fast-forward not possible (your history diverged)."
            echo ""
            echo -e "Run: ${CLR_CYAN}gut sync --reconcile${CLR_RESET}  to merge or rebase remotes into your branch."
            exit 1
        }
        gut_success "Pulled latest changes."
    else
        # Diverged
        gut_warn "Your branch has diverged from the remote."
        if [[ $reconcile -eq 1 ]]; then
            echo ""
            echo "How would you like to reconcile?"
            echo "  1) Merge (safe, creates a merge commit)"
            echo "  2) Rebase (cleaner history, rewrites commits)"
            echo "  3) Cancel"
            read -r -p "$(echo -e "${CLR_CYAN}Choice [1/2/3]: ${CLR_RESET}")" choice
            case "$choice" in
                1)
                    gut_log "Merging remote changes..."
                    if git merge "@{u}"; then
                        gut_success "Merged. Now push with: gut sync"
                    else
                        gut_error "Merge conflict. Resolve them and run: gut save"
                    fi
                    ;;
                2)
                    gut_log "Rebasing onto remote..."
                    if git rebase "@{u}"; then
                        gut_success "Rebased. Now push with: gut sync --force"
                    else
                        gut_error "Rebase conflict. Resolve and run: git rebase --continue"
                    fi
                    ;;
                *) gut_log "Cancelled." ;;
            esac
        else
            echo ""
            echo -e "Your branch and the remote branch have diverged (each has commits the other doesn't)."
            echo -e "Fix: ${CLR_CYAN}gut sync --reconcile${CLR_RESET}  to choose merge or rebase."
        fi
    fi
}

gut_sync "$@"

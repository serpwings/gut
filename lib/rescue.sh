#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     rescue.sh
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

gut_rescue_detached() {
    gut_header "Rescue: Detached HEAD"
    local current_hash
    current_hash=$(git rev-parse HEAD)
    gut_warn "You are not on any branch. Your HEAD is at: ${current_hash:0:8}"
    echo ""
    echo "What would you like to do?"
    echo "  1) Create a new branch here (saves your work)"
    echo "  2) Switch to an existing branch (you may lose uncommitted work)"
    echo "  3) Cancel"
    read -r -p "$(echo -e "${CLR_CYAN}Choice [1/2/3]: ${CLR_RESET}")" choice
    case "$choice" in
        1)
            read -r -p "$(echo -e "${CLR_CYAN}New branch name: ${CLR_RESET}")" name
            git checkout -b "$name"
            gut_success "Created branch '${name}' at current position. You're safe!"
            ;;
        2)
            echo ""
            echo "Available branches:"
            git branch | sed 's/^/  /'
            read -r -p "$(echo -e "${CLR_CYAN}Branch to return to: ${CLR_RESET}")" name
            if git checkout "$name"; then
                gut_success "Back on branch '${name}'."
            fi
            ;;
        *) gut_log "Cancelled." ;;
    esac
}

gut_rescue_conflicts() {
    gut_header "Rescue: Merge Conflicts"
    local conflicted
    conflicted=$(git diff --name-only --diff-filter=U 2>/dev/null)
    if [[ -z "$conflicted" ]]; then
        gut_success "No conflicts detected!"
        return
    fi
    echo -e "${CLR_BRED}Conflicting files:${CLR_RESET}"
    echo "$conflicted" | sed "s/^/   /"
    echo ""
    echo "Steps to resolve:"
    echo "  1. Open each file and look for conflict markers (<<<<<<, ======, >>>>>>)"
    echo "  2. Edit each file, keeping the changes you want"
    echo "  3. Run 'gut save <file>' to mark each file as resolved"
    echo "  4. Run 'gut save' to complete the merge/rebase"
    echo ""
    echo -e "Or to ABORT the merge entirely: ${CLR_CYAN}gut git merge --abort${CLR_RESET}"
}

gut_rescue_lost() {
    gut_header "Rescue: Find Lost Commits"
    echo -e "${CLR_BYELLOW}Recent reflog entries (commits that might be lost):${CLR_RESET}"
    git reflog --date=relative --format="%C(auto)%h%Creset %Cgreen(%cr)%Creset %s" | head -20 | nl -ba | sed 's/^/  /'
    echo ""
    echo "To recover a lost commit, run:"
    echo -e "  ${CLR_CYAN}gut branch new <name>${CLR_RESET}   and then:"
    echo -e "  ${CLR_CYAN}gut git cherry-pick <hash>${CLR_RESET}"
}

gut_rescue_rebase() {
    gut_header "Rescue: Stuck Rebase"
    if [[ -d "$(git rev-parse --git-dir)/rebase-merge" ]] || \
       [[ -d "$(git rev-parse --git-dir)/rebase-apply" ]]; then
        gut_warn "A rebase is in progress."
        echo ""
        echo "Options:"
        echo "  1) Abort rebase (return to state before rebase started)"
        echo "  2) Skip current commit and continue"
        echo "  3) Continue (after resolving conflicts)"
        read -r -p "$(echo -e "${CLR_CYAN}Choice [1/2/3]: ${CLR_RESET}")" choice
        case "$choice" in
            1) git rebase --abort; gut_success "Rebase aborted." ;;
            2) git rebase --skip;  gut_log "Skipped. Rebase continues..." ;;
            3) git rebase --continue ;;
            *) gut_log "Cancelled." ;;
        esac
    else
        gut_success "No rebase in progress."
    fi
}

gut_rescue_stash() {
    gut_header "Rescue: Stash Recovery"
    if ! git stash list | grep -q .; then
        echo -e "  ${CLR_DIM}(no stashes found)${CLR_RESET}"
        return
    fi
    echo -e "Saved stashes:"
    git stash list | nl -ba | sed 's/^/  /'
    echo ""
    echo "  1) Apply most recent stash (keeps it in stash list)"
    echo "  2) Pop most recent stash (removes from stash list)"
    echo "  3) Show stash contents"
    echo "  4) Cancel"
    read -r -p "$(echo -e "${CLR_CYAN}Choice [1/2/3/4]: ${CLR_RESET}")" choice
    case "$choice" in
        1) git stash apply; gut_success "Stash applied." ;;
        2) git stash pop;   gut_success "Stash popped." ;;
        3) git stash show -p | head -60 ;;
        *) gut_log "Cancelled." ;;
    esac
}

gut_rescue_init() {
    gut_header "Rescue: Initialize Repository"
    if gut_is_repo; then
        gut_warn "This directory is already a Git repository."
        return
    fi
    gut_log "Initializing new Git repository..."
    git init
    gut_success "Repository initialized! Use 'gut save' to make your first commit."
}

gut_rescue_health() {
    gut_header "Repository Health Check"

    # Basic repo check
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [[ -z "$branch" ]]; then
        gut_error "Not a git repository."
        return
    fi

    echo -e "${CLR_BGREEN} Branch:${CLR_RESET} ${branch}"

    # Detached HEAD
    if [[ "$branch" == "HEAD" ]]; then
        gut_warn "Detached HEAD  run: gut rescue detached"
    else
        gut_success "HEAD is healthy."
    fi

    # Uncommitted changes
    local dirty
    dirty=$(git status --porcelain)
    if [[ -n "$dirty" ]]; then
        gut_warn "Uncommitted changes present."
    else
        gut_success "Working tree is clean."
    fi

    # Conflicts
    local conflicts
    conflicts=$(git diff --name-only --diff-filter=U 2>/dev/null)
    if [[ -n "$conflicts" ]]; then
        gut_error "Unresolved merge conflicts! Run: gut rescue conflicts"
    else
        gut_success "No merge conflicts."
    fi

    # Rebase in progress
    if [[ -d "$(git rev-parse --git-dir)/rebase-merge" ]] || \
       [[ -d "$(git rev-parse --git-dir)/rebase-apply" ]]; then
        gut_warn "Rebase in progress. Run: gut rescue rebase"
    else
        gut_success "No in-progress rebase."
    fi

    # Remote tracking
    if git remote get-url origin >/dev/null 2>&1; then
        gut_success "Remote 'origin' configured: $(git remote get-url origin)"
    else
        gut_warn "No remote 'origin' configured."
    fi

    echo ""
}

# Entry point
sub="${1:-health}"; shift || true
case "$sub" in
    detached)  gut_rescue_detached ;;
    conflicts) gut_rescue_conflicts ;;
    lost)      gut_rescue_lost ;;
    rebase)    gut_rescue_rebase ;;
    stash)     gut_rescue_stash ;;
    init)      gut_rescue_init ;;
    health|"") gut_rescue_health ;;
    *) gut_error "Unknown rescue subcommand: $sub"
       echo "Usage: gut rescue [health|detached|conflicts|lost|rebase|stash|init]"
       exit 1 ;;
esac

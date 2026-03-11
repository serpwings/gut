#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     snapshot.sh
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

gut_snapshot() {
    gut_header "Snapshot (Quicksave)"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local msg="snapshot: ${timestamp}"

    gut_log "Creating a timestamped stash snapshot..."
    if git diff --quiet && git diff --cached --quiet; then
        gut_warn "Nothing to snapshot  your working tree is clean."
        return
    fi

    git stash push --include-untracked --message "$msg"
    gut_success "Snapshot saved: '${msg}'"
    echo "Restore it anytime with: gut stash pop"
    echo "List all snapshots:      gut stash list"
}

gut_snapshot "$@"

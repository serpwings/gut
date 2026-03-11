#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     pr.sh
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

gut_pr() {
    gut_header "Open Pull Request"

    local remote_url
    remote_url=$(git remote get-url origin 2>/dev/null)
    if [[ -z "$remote_url" ]]; then
        gut_error "No remote 'origin' found."
        exit 1
    fi

    local branch
    branch=$(git rev-parse --abbrev-ref HEAD)

    # Detect provider and build PR URL
    local pr_url=""
    if echo "$remote_url" | grep -q "github.com"; then
        # Normalize SSH and HTTPS URLs
        local repo
        repo=$(echo "$remote_url" | sed 's/.*github\.com[:/]//' | sed 's/\.git$//')
        pr_url="https://github.com/${repo}/pull/new/${branch}"
    elif echo "$remote_url" | grep -q "gitlab.com"; then
        local repo
        repo=$(echo "$remote_url" | sed 's/.*gitlab\.com[:/]//' | sed 's/\.git$//')
        pr_url="https://gitlab.com/${repo}/-/merge_requests/new?merge_request%5Bsource_branch%5D=${branch}"
    elif echo "$remote_url" | grep -q "bitbucket.org"; then
        local repo
        repo=$(echo "$remote_url" | sed 's/.*bitbucket\.org[:/]//' | sed 's/\.git$//')
        pr_url="https://bitbucket.org/${repo}/pull-requests/new?source=${branch}"
    else
        gut_warn "Could not auto-detect provider (GitHub/GitLab/Bitbucket)."
        echo "Remote URL: ${remote_url}"
        echo "Please open a PR/MR manually."
        exit 1
    fi

    gut_log "Opening PR page for branch '${branch}'..."
    echo -e "  URL: ${CLR_CYAN}${pr_url}${CLR_RESET}"

    # Try to open in browser
    if command -v open >/dev/null 2>&1; then
        open "$pr_url"                    # macOS
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$pr_url"               # Linux
    elif command -v start >/dev/null 2>&1; then
        start "$pr_url"                  # Windows Git Bash
    else
        gut_warn "Could not auto-open browser. Please visit the URL above manually."
    fi
}

gut_pr "$@"

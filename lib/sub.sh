#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     sub.sh
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

gut_sub_list() {
    gut_header "Submodules"
    if ! git submodule status 2>/dev/null | grep -q .; then
        echo -e "  ${CLR_DIM}(no submodules)${CLR_RESET}"
        return
    fi
    git submodule status | while read -r hash path branch; do
        local status_char="${hash:0:1}"
        hash="${hash:1}"
        local label=""
        case "$status_char" in
            " ") label="${CLR_GREEN}[OK]   ${CLR_RESET}" ;;
            "+") label="${CLR_YELLOW}[DRIFT]${CLR_RESET}" ; label+=" (commit differs from recorded)" ;;
            "-") label="${CLR_RED}[INIT] ${CLR_RESET}" ; label+=" (not yet initialized)" ;;
            "U") label="${CLR_BRED}[CONF] ${CLR_RESET}" ; label+=" (merge conflict!)" ;;
        esac
        echo -e "   ${label} ${CLR_BOLD}${path}${CLR_RESET} ${CLR_DIM}(${hash:0:8})${CLR_RESET}"
    done
}

gut_sub_add() {
    local url="$1"
    local path="$2"
    if [[ -z "$url" ]]; then
        gut_error "URL required."
        echo "Usage: gut sub add <url> [path]"
        exit 1
    fi
    gut_log "Adding submodule: ${url}"
    if git submodule add "$url" ${path:+"$path"}; then
        gut_success "Submodule added. Run 'gut save' to commit the change."
    fi
}

gut_sub_update() {
    gut_log "Updating all submodules to their recorded commits..."
    git submodule update --init --recursive
    gut_success "Submodules updated."
}

gut_sub_sync() {
    gut_log "Syncing submodule URLs from .gitmodules..."
    git submodule sync --recursive
    gut_success "Submodule URLs synced."
}

gut_sub_remove() {
    local path="$1"
    if [[ -z "$path" ]]; then
        gut_error "Submodule path required."
        echo "Usage: gut sub remove <path>"
        exit 1
    fi
    if ! gut_confirm "Remove submodule '${path}'? This will delete it from the repo config and filesystem."; then
        return
    fi
    gut_log "Removing submodule '${path}'..."
    git submodule deinit -f -- "$path"
    git rm -f "$path"
    rm -rf ".git/modules/${path}"
    gut_success "Submodule '${path}' removed. Run 'gut save' to commit the change."
}

# Entry point
sub="${1}"; shift || true
case "$sub" in
    list|"") gut_sub_list ;;
    add)     gut_sub_add "$@" ;;
    update)  gut_sub_update ;;
    sync)    gut_sub_sync ;;
    remove)  gut_sub_remove "$@" ;;
    *) gut_error "Unknown sub subcommand: $sub"; exit 1 ;;
esac

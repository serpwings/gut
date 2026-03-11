#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     tag.sh
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

gut_tag() {
    local sub="${1:-list}"
    shift 2>/dev/null || true

    case "$sub" in
        list|"")
            gut_header "Tags"
            if git tag | grep -q .; then
                git tag --sort=-version:refname | while IFS= read -r tag; do
                    local date msg
                    date=$(git log -1 --format="%ar" "${tag}" 2>/dev/null || echo "unknown")
                    msg=$(git tag -l --format='%(contents:subject)' "${tag}" 2>/dev/null)
                    if [[ -n "$msg" ]]; then
                        echo -e "  ${CLR_CYAN}${tag}${CLR_RESET}  ${CLR_DIM}${date}${CLR_RESET}   ${msg}"
                    else
                        echo -e "  ${CLR_CYAN}${tag}${CLR_RESET}  ${CLR_DIM}${date}${CLR_RESET}"
                    fi
                done
            else
                echo "  (no tags yet)"
                echo ""
                echo "Create one with: gut tag v1.0.0 -m \"Initial release\""
            fi
            ;;
        create|add|"")
            local tag_name="$1"
            shift
            local msg=""
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    -m) msg="$2"; shift 2 ;;
                    *)  shift ;;
                esac
            done
            if [[ -z "$tag_name" ]]; then
                gut_error "Usage: gut tag create <version> [-m \"message\"]"
                exit 1
            fi
            if [[ -z "$msg" ]]; then
                echo -n -e "${CLR_BCYAN}  Tag message (optional): ${CLR_RESET}"
                read -r msg
            fi
            if [[ -n "$msg" ]]; then
                git tag -a "$tag_name" -m "$msg"
            else
                git tag "$tag_name"
            fi
            gut_success "Tag '${tag_name}' created."
            echo "Push it with: gut tag push ${tag_name}"
            ;;
        push)
            local tag_name="${1:-}"
            if [[ -z "$tag_name" ]]; then
                gut_log "Pushing all tags to remote..."
                git push --tags
            else
                gut_log "Pushing tag '${tag_name}' to remote..."
                git push origin "$tag_name"
            fi
            gut_success "Tag(s) pushed."
            ;;
        delete|remove)
            local tag_name="$1"
            if [[ -z "$tag_name" ]]; then
                gut_error "Usage: gut tag delete <version>"
                exit 1
            fi
            gut_warn "Deleting tag '${tag_name}' locally."
            if gut_confirm "Also delete from remote? (Requires push access)"; then
                git push origin ":refs/tags/${tag_name}" 2>/dev/null && \
                    gut_log "Remote tag deleted."
            fi
            git tag -d "$tag_name"
            gut_success "Tag '${tag_name}' deleted."
            ;;
        latest)
            local latest
            latest=$(git describe --tags --abbrev=0 2>/dev/null) || true
            if [[ -n "$latest" ]]; then
                echo -e "${CLR_BWHITE}Latest tag:${CLR_RESET} ${CLR_CYAN}${latest}${CLR_RESET}"
            else
                gut_warn "No tags found in this repository."
            fi
            ;;
        *)
            gut_error "Unknown tag subcommand: '${sub}'"
            echo "Usage: gut tag [list|create|push|delete|latest]"
            exit 1
            ;;
    esac
}

# Support: `gut tag v1.0.0 -m "message"` shorthand (no subcommand)
if [[ $# -gt 0 && "$1" =~ ^[vV]?[0-9] ]]; then
    gut_tag "create" "$@"
else
    gut_tag "$@"
fi

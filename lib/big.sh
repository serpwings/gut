#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     big.sh
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

# Minimum file size to flag as "large" (default: 1MB)
BIG_THRESHOLD_KB="${GUT_BIG_THRESHOLD_KB:-1024}"

gut_big_scan() {
    gut_header "Large File Scan"

    # --- Working Tree ---
    echo -e "${CLR_BYELLOW} Working Tree (files > ${BIG_THRESHOLD_KB}KB):${CLR_RESET}"
    local found=0
    while IFS= read -r -d '' file; do
        local size_kb
        size_kb=$(du -k "$file" | cut -f1)
        if [[ "$size_kb" -ge "$BIG_THRESHOLD_KB" ]]; then
            printf "  %-60s %s KB\n" "$file" "$size_kb"
            found=1
        fi
    done < <(find . -not -path './.git/*' -type f -print0 2>/dev/null)
    [[ $found -eq 0 ]] && echo -e "  ${CLR_DIM}(none found)${CLR_RESET}"

    # --- Git History ---
    echo -e "\n${CLR_BYELLOW} Git History (blobs > ${BIG_THRESHOLD_KB}KB):${CLR_RESET}"
    local hist_found=0
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git rev-list --objects --all 2>/dev/null | \
        git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' 2>/dev/null | \
        awk -v threshold=$((BIG_THRESHOLD_KB * 1024)) '
            $1 == "blob" && $3 >= threshold {
                printf "  %-60s %d KB\n", $4, $3/1024
            }
        ' | sort -t' ' -k2 -rn | head -20
        if [[ $? -ne 0 ]]; then
            echo -e "  ${CLR_DIM}(could not scan history)${CLR_RESET}"
        fi
        hist_found=1
    fi
    [[ $hist_found -eq 0 ]] && echo -e "  ${CLR_DIM}(none found)${CLR_RESET}"
    echo ""
    echo -e "Tip: Use ${CLR_CYAN}gut big track <file>${CLR_RESET} to add a file to Git LFS."
}

gut_big_track() {
    local file="$1"
    if [[ -z "$file" ]]; then
        gut_error "File or pattern required."
        echo "Usage: gut big track '*.psd'"
        exit 1
    fi
    if ! command -v git-lfs >/dev/null 2>&1; then
        gut_error "Git LFS is not installed."
        echo "Install it from: https://git-lfs.com/"
        exit 1
    fi
    gut_log "Tracking '${file}' with Git LFS..."
    git lfs track "$file"
    gut_success "Now tracking '${file}' with LFS. Run 'gut save .gitattributes' to commit the tracking rule."
}

gut_big_setup() {
    gut_log "Setting up Git LFS for this repository..."
    if ! command -v git-lfs >/dev/null 2>&1; then
        gut_error "Git LFS is not installed."
        echo "Install it from: https://git-lfs.com/"
        exit 1
    fi
    git lfs install
    gut_success "Git LFS is now enabled for this repository."
}

gut_big_status() {
    gut_header "Git LFS Status"
    if ! command -v git-lfs >/dev/null 2>&1; then
        gut_warn "Git LFS is not installed."
        return
    fi
    git lfs status
}

# Entry point
sub="${1}"; shift || true
case "$sub" in
    scan)   gut_big_scan ;;
    track)  gut_big_track "$@" ;;
    setup)  gut_big_setup ;;
    status) gut_big_status ;;
    *) gut_error "Unknown big subcommand: ${sub:-<missing>}"; echo "Usage: gut big [scan|track|setup|status]"; exit 1 ;;
esac

#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     patch.sh
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

gut_patch() {
    local sub="${1:-}"
    shift 2>/dev/null || true

    case "$sub" in
        create|"")
            local n="${1:-1}"
            local out_dir="${2:-.}"
            gut_log "Exporting last ${n} commit(s) as .patch files to '${out_dir}'..."
            git format-patch -"${n}" --output-directory "${out_dir}"
            gut_success "Patch file(s) created in '${out_dir}'."
            echo "Apply on another machine with: gut patch apply <file.patch>"
            ;;
        apply)
            local patch_file="$1"
            if [[ -z "$patch_file" ]]; then
                gut_error "Usage: gut patch apply <file.patch>"
                exit 1
            fi
            if [[ ! -f "$patch_file" ]]; then
                gut_error "File not found: '${patch_file}'"
                exit 1
            fi
            gut_log "Applying patch: ${patch_file}"
            if git am "$patch_file"; then
                gut_success "Patch applied successfully."
            else
                gut_error "Patch failed to apply cleanly."
                echo "You can try: gut git am --abort"
            fi
            ;;
        *)
            gut_error "Unknown patch subcommand: '${sub}'"
            echo "Usage: gut patch [create [N] [dir]|apply <file.patch>]"
            exit 1
            ;;
    esac
}

gut_patch "$@"

#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     alias.sh
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

GUT_ALIAS_FILE="${HOME}/.gutconfig"

gut_alias() {
    local sub="${1:-list}"
    shift 2>/dev/null || true

    case "$sub" in
        list|"")
            gut_header "Gut Aliases"
            if [[ -f "$GUT_ALIAS_FILE" ]]; then
                grep '^alias ' "$GUT_ALIAS_FILE" | while IFS= read -r line; do
                    local name val
                    name=$(echo "$line" | awk '{print $2}')
                    val=$(echo "$line" | cut -d= -f2- | tr -d '"')
                    echo -e "  ${CLR_CYAN}${name}${CLR_RESET}  ${val}"
                done
            else
                echo "  (no aliases defined)"
                echo ""
                echo "Add one with: gut alias add <name> <command>"
            fi
            ;;
        add)
            local name="$1"
            local cmd="${*:2}"
            if [[ -z "$name" || -z "$cmd" ]]; then
                gut_error "Usage: gut alias add <name> <command>"
                exit 1
            fi
            # Remove any existing alias with this name
            if [[ -f "$GUT_ALIAS_FILE" ]]; then
                sed -i.bak "/^alias ${name}=/d" "$GUT_ALIAS_FILE" && rm -f "${GUT_ALIAS_FILE}.bak"
            fi
            echo "alias ${name}=\"${cmd}\"" >> "$GUT_ALIAS_FILE"
            gut_success "Alias '${name}'  '${cmd}' saved to ~/.gutconfig"
            echo "Reload your shell or run: source ~/.gutconfig"
            ;;
        remove|delete)
            local name="$1"
            if [[ -z "$name" ]]; then
                gut_error "Usage: gut alias remove <name>"
                exit 1
            fi
            if [[ -f "$GUT_ALIAS_FILE" ]] && grep -q "^alias ${name}=" "$GUT_ALIAS_FILE"; then
                sed -i.bak "/^alias ${name}=/d" "$GUT_ALIAS_FILE" && rm -f "${GUT_ALIAS_FILE}.bak"
                gut_success "Alias '${name}' removed."
            else
                gut_warn "Alias '${name}' not found."
            fi
            ;;
        run)
            local name="$1"
            shift
            if [[ -f "$GUT_ALIAS_FILE" ]]; then
                local cmd
                cmd=$(grep "^alias ${name}=" "$GUT_ALIAS_FILE" | cut -d= -f2- | tr -d '"')
                if [[ -n "$cmd" ]]; then
                    gut_log "Running: ${cmd} $*"
                    eval "$cmd $*"
                else
                    gut_error "Unknown alias: '${name}'. Run 'gut alias list' to see all."
                    exit 1
                fi
            else
                gut_error "No aliases defined. Use 'gut alias add' to create one."
                exit 1
            fi
            ;;
        *)
            gut_error "Unknown alias subcommand: '${sub}'"
            echo "Usage: gut alias [list|add|remove|run]"
            exit 1
            ;;
    esac
}

gut_alias "$@"

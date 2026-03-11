#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     protect.sh
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

HOOK_DIR=".git/hooks"
HOOK_FILE="${HOOK_DIR}/pre-push"

gut_protect() {
    local sub="${1:-status}"
    shift 2>/dev/null || true

    case "$sub" in
        status)
            gut_header "Branch Protection"
            if [[ -f "$HOOK_FILE" ]] && grep -q "gut-protect" "$HOOK_FILE"; then
                # Parse protected branches from the hook
                local branches
                branches=$(grep 'GUT_PROTECTED=' "$HOOK_FILE" | cut -d'"' -f2)
                echo -e "  ${CLR_GREEN} Protection active${CLR_RESET}"
                echo -e "  Protected branches: ${CLR_CYAN}${branches}${CLR_RESET}"
            else
                echo -e "  ${CLR_YELLOW}  No branch protection configured.${CLR_RESET}"
                echo "  Run: gut protect add main"
            fi
            ;;
        add)
            local branch="${1:-main}"
            gut_log "Adding push protection for branch '${branch}'..."

            # Read existing protected branches if hook already exists
            local existing=""
            if [[ -f "$HOOK_FILE" ]] && grep -q "gut-protect" "$HOOK_FILE"; then
                existing=$(grep 'GUT_PROTECTED=' "$HOOK_FILE" | cut -d'"' -f2)
                # Add new branch if not already there
                if echo "$existing" | grep -qw "$branch"; then
                    gut_warn "'${branch}' is already protected."
                    return
                fi
                existing="${existing} ${branch}"
            else
                existing="$branch"
            fi

            # Write the hook
            cat > "$HOOK_FILE" <<'HOOK'
#!/usr/bin/env bash
# gut-protect: prevent direct pushes to protected branches
HOOK
            cat >> "$HOOK_FILE" <<HOOK
GUT_PROTECTED="${existing}"
HOOK
            cat >> "$HOOK_FILE" <<'HOOK'
current_branch=$(git rev-parse --abbrev-ref HEAD)
remote_branch="$2"
for protected in $GUT_PROTECTED; do
    if [[ "$current_branch" == "$protected" || "$remote_branch" == *"$protected" ]]; then
        echo ""
        echo " gut-protect: Direct push to '${protected}' is blocked."
        echo "   Create a branch and open a PR/MR instead:"
        echo "   gut branch new my-feature"
        echo "   gut sync --publish"
        echo ""
        exit 1
    fi
done
exit 0
HOOK
            chmod +x "$HOOK_FILE"
            gut_success "Branch '${branch}' is now protected from direct pushes."
            ;;
        remove)
            local branch="${1:-}"
            if [[ -z "$branch" ]]; then
                gut_error "Usage: gut protect remove <branch>"
                exit 1
            fi
            if [[ -f "$HOOK_FILE" ]] && grep -q "gut-protect" "$HOOK_FILE"; then
                local existing
                existing=$(grep 'GUT_PROTECTED=' "$HOOK_FILE" | cut -d'"' -f2)
                local new_list
                new_list=$(echo "$existing" | tr ' ' '\n' | grep -vw "$branch" | tr '\n' ' ' | xargs)
                if [[ -z "$new_list" ]]; then
                    rm -f "$HOOK_FILE"
                    gut_success "All protections removed. Hook deleted."
                else
                    sed -i.bak "s/GUT_PROTECTED=\".*\"/GUT_PROTECTED=\"${new_list}\"/" "$HOOK_FILE"
                    rm -f "${HOOK_FILE}.bak"
                    gut_success "Branch '${branch}' is no longer protected."
                fi
            else
                gut_warn "No protection configured. Nothing to remove."
            fi
            ;;
        *)
            gut_error "Unknown protect subcommand: '${sub}'"
            echo "Usage: gut protect [status|add|remove] [branch]"
            exit 1
            ;;
    esac
}

gut_protect "$@"

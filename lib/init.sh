#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     init.sh
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

gut_init() {
    gut_header "Initialize Repository"
    if gut_is_repo; then
        gut_warn "This directory is already a Git repository."
        return
    fi
    gut_log "Initializing new Git repository..."
    git init
    gut_success "Repository initialized! Use 'gut save' to make your first commit."
}

gut_init "$@"

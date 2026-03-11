#!/usr/bin/env bash

# gut - Git with better UX
# https://github.com/serpwings/gut
#
#     install.sh
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

#
# gut install script
# Copies gut to /usr/local/bin (or $GUT_INSTALL_DIR)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${GUT_INSTALL_DIR:-/usr/local}"
BIN_DEST="${INSTALL_DIR}/bin"
LIB_DEST="${INSTALL_DIR}/lib/gut"

echo "Installing gut..."
echo "   bin:  ${BIN_DEST}/gut"
echo "   lib:  ${LIB_DEST}/"
echo ""

# Check if we have permission to write to the destination
if [ ! -w "${INSTALL_DIR}" ] && [ ! -w "$(dirname "${INSTALL_DIR}")" ]; then
    echo " Permission denied: Cannot write to ${INSTALL_DIR}."
    echo "   Try running with sudo:"
    echo "     sudo ./install.sh"
    echo "   Or install to a local directory instead:"
    echo "     GUT_INSTALL_DIR=~/.local ./install.sh"
    exit 1
fi

# Ensure install directories exist
mkdir -p "${BIN_DEST}" || { echo " Failed to create ${BIN_DEST}. Try running with sudo."; exit 1; }
mkdir -p "${LIB_DEST}" || { echo " Failed to create ${LIB_DEST}. Try running with sudo."; exit 1; }
mkdir -p "${INSTALL_DIR}/share/gut/completion" || { echo " Failed to create completion dir. Try running with sudo."; exit 1; }

# Copy library and completion files
cp -r "${SCRIPT_DIR}/lib/"*.sh "${LIB_DEST}/"
cp "${SCRIPT_DIR}/completion/"* "${INSTALL_DIR}/share/gut/completion/"

# Patch bin/gut to reference the installed lib directory
sed "s|LIB_DIR=.*|LIB_DIR=\"${LIB_DEST}\"|" \
    "${SCRIPT_DIR}/bin/gut" > "${BIN_DEST}/gut"

# Make everything executable
chmod +x "${BIN_DEST}/gut"
chmod +x "${LIB_DEST}/"*.sh

# Verify
if command -v gut >/dev/null 2>&1; then
    echo " gut installed successfully!"
    echo "   Run 'gut --help' to get started."
else
    echo " gut installed to ${BIN_DEST}/gut"
    echo ""
    echo "   Make sure ${BIN_DEST} is in your PATH. Add this to your shell profile:"
    echo "   export PATH=\"${BIN_DEST}:\$PATH\""
fi

echo ""
echo "   To enable autocompletion, add the following to your shell profile:"
echo "   For Zsh (~/.zshrc):"
echo "     fpath=(\"${INSTALL_DIR}/share/gut/completion\" \$fpath)"
echo "     compinit"
echo "   For Bash (~/.bash_profile or ~/.bashrc):"
echo "     source \"${INSTALL_DIR}/share/gut/completion/gut-completion.bash\""


#!/usr/bin/env bash
# run_tests.sh  bootstrap BATS and run the gut test suite.
#
# Usage:
#   ./tests/run_tests.sh            # run all tests
#   ./tests/run_tests.sh save.bats  # run a single file

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BATS_DIR="${SCRIPT_DIR}/bats-core"

#  Install BATS if not present 
if ! command -v bats &>/dev/null && [[ ! -x "${BATS_DIR}/bin/bats" ]]; then
    echo " BATS not found. Cloning bats-core into tests/bats-core..."
    git clone --depth 1 https://github.com/bats-core/bats-core.git "${BATS_DIR}" 2>/dev/null
fi

if command -v bats &>/dev/null; then
    BATS=bats
else
    BATS="${BATS_DIR}/bin/bats"
fi

#  Run tests 
cd "$SCRIPT_DIR"

if [[ $# -gt 0 ]]; then
    exec "$BATS" --tap "$@"
else
    exec "$BATS" --tap ./*.bats
fi

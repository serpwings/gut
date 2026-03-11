#!/usr/bin/env bash
# test_helper.bash  shared setup/teardown helpers for gut BATS tests
#
# Every .bats file should load this at the top:
#   load 'test_helper'

#  Locate gut 
# Resolve GUT_HOME relative to this file's location (tests/ lives at root)
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export GUT_HOME="$(cd "${TEST_DIR}/.." && pwd)"
export GUT="${GUT_HOME}/bin/gut"
export GUT_NO_COLOR=1   # keep output predictable in tests
export GUT_NO_EMOJI=1

#  Git identity (needed for commits) 
export GIT_AUTHOR_NAME="Test User"
export GIT_AUTHOR_EMAIL="test@gut.local"
export GIT_COMMITTER_NAME="Test User"
export GIT_COMMITTER_EMAIL="test@gut.local"

#  Repo helpers 

# setup_repo  create a fresh temporary git repo and cd into it.
# Call from BATS setup() functions.
setup_repo() {
    REPO_DIR="$(mktemp -d)"
    cd "$REPO_DIR"
    git init -q
    git checkout -q -b main 2>/dev/null || true
}

# add_commit <message> [file]  create a file and make a commit.
add_commit() {
    local msg="${1:-test commit}"
    local file="${2:-file_$(date +%s%N).txt}"
    echo "content" > "$file"
    git add "$file"
    git commit -q -m "$msg"
}

# teardown_repo  remove the temporary repo created by setup_repo.
teardown_repo() {
    [[ -n "$REPO_DIR" ]] && rm -rf "$REPO_DIR"
}

# setup_remote  create a bare remote and add it as 'origin', then push main.
setup_remote() {
    REMOTE_DIR="$(mktemp -d)"
    git init -q --bare "$REMOTE_DIR"
    git remote add origin "$REMOTE_DIR"
    git push -q --set-upstream origin main
}

# assert_output_contains <string>  fail if $output doesn't contain the string.
assert_output_contains() {
    [[ "$output" == *"$1"* ]] || {
        echo "Expected output to contain: $1"
        echo "Actual output: $output"
        return 1
    }
}

# assert_output_not_contains <string>  fail if $output contains the string.
assert_output_not_contains() {
    [[ "$output" != *"$1"* ]] || {
        echo "Expected output NOT to contain: $1"
        echo "Actual output: $output"
        return 1
    }
}

# assert_file_exists <path>
assert_file_exists() {
    [[ -f "$1" ]] || { echo "Expected file to exist: $1"; return 1; }
}

# assert_on_branch <branch>
assert_on_branch() {
    local actual
    actual=$(git rev-parse --abbrev-ref HEAD)
    [[ "$actual" == "$1" ]] || {
        echo "Expected branch: $1, got: $actual"
        return 1
    }
}

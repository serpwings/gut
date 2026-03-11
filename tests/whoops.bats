#!/usr/bin/env bats
# tests/whoops.bats  tests for lib/whoops.sh (gut whoops)

load 'test_helper'

setup() {
    setup_repo
    add_commit "commit one"
    add_commit "commit two"
    add_commit "commit three"
}
teardown() { teardown_repo; }

@test "gut whoops lists recent reflog entries" {
    run bash -c "printf '\n' | '$GUT' whoops"
    [ "$status" -eq 0 ]
    assert_output_contains "Recent States"
}

@test "gut whoops cancel with empty input does nothing to HEAD" {
    local head_before
    head_before=$(git rev-parse HEAD)
    run bash -c "printf '\n' | '$GUT' whoops"
    [ "$status" -eq 0 ]
    assert_output_contains "Cancelled"
    [ "$(git rev-parse HEAD)" = "$head_before" ]
}

@test "gut whoops rejects an out-of-range choice" {
    run bash -c "printf '999\n' | '$GUT' whoops"
    [ "$status" -ne 0 ]
    assert_output_contains "Invalid choice"
}

@test "gut whoops rejects a non-numeric choice" {
    run bash -c "printf 'abc\n' | '$GUT' whoops"
    [ "$status" -ne 0 ]
    assert_output_contains "Invalid choice"
}

@test "gut whoops auto-stashes dirty work before jumping" {
    local f; f=$(git ls-files | head -1)
    echo "unsaved" >> "$f"
    # Pick entry 2, confirm y  ignore exit code since HEAD@{1} jump may fail
    bash -c "printf '2\ny\n' | '$GUT' whoops" || true
    # The autosave stash is created BEFORE the reset attempt
    run git stash list
    assert_output_contains "whoops-autosave"
}

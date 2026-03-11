#!/usr/bin/env bats
# tests/snapshot.bats  tests for lib/snapshot.sh (gut snapshot)

load 'test_helper'

setup() { setup_repo; add_commit "initial"; }
teardown() { teardown_repo; }

@test "gut snapshot saves a timestamped stash when tree is dirty" {
    local f; f=$(git ls-files | head -1)
    echo "unsaved work" >> "$f"
    run "$GUT" snapshot
    [ "$status" -eq 0 ]
    assert_output_contains "Snapshot saved"
    run git stash list
    assert_output_contains "snapshot:"
}

@test "gut snapshot on a clean tree warns and creates no stash" {
    run "$GUT" snapshot
    [ "$status" -eq 0 ]
    assert_output_contains "Nothing to snapshot"
    run git stash list
    [ "$output" = "" ]
}

@test "gut snapshot includes untracked files and restores them on pop" {
    # Write an untracked file with unique content so we can verify it's stashed
    echo "brand new content" > new_untracked_file.txt
    # Ensure something IS in the working tree (untracked doesn't show in diff)
    local f; f=$(git ls-files | head -1)
    echo "also dirty" >> "$f"
    run "$GUT" snapshot
    [ "$status" -eq 0 ]
    assert_output_contains "Snapshot saved"
    # Restore stash and verify untracked file came back
    git stash pop
    assert_file_exists "new_untracked_file.txt"
}

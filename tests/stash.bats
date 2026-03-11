#!/usr/bin/env bats
# tests/stash.bats  tests for lib/stash.sh (gut stash)

load 'test_helper'

setup() { setup_repo; add_commit "initial"; }
teardown() { teardown_repo; }

@test "gut stash save stashes current changes" {
    local f; f=$(git ls-files | head -1)
    echo "dirty" >> "$f"
    run bash -c "printf 'my stash\n' | '$GUT' stash save"
    [ "$status" -eq 0 ]
    assert_output_contains "stashed"
    run git status --porcelain
    [ "$output" = "" ]
}

@test "gut stash save with message argument uses it directly" {
    local f; f=$(git ls-files | head -1)
    echo "dirty" >> "$f"
    run "$GUT" stash save "named stash"
    [ "$status" -eq 0 ]
    assert_output_contains "stashed"
}

@test "gut stash list shows stash entries" {
    local f; f=$(git ls-files | head -1)
    echo "a" >> "$f"
    git stash push -m "my stash"
    run "$GUT" stash list
    [ "$status" -eq 0 ]
    assert_output_contains "my stash"
}

@test "gut stash list shows empty message when no stashes" {
    run "$GUT" stash list
    [ "$status" -eq 0 ]
    assert_output_contains "no stashes"
}

@test "gut stash pop restores most recent stash" {
    local f; f=$(git ls-files | head -1)
    echo "popped" >> "$f"
    git stash push -m "to-pop"
    run "$GUT" stash pop
    [ "$status" -eq 0 ]
    assert_output_contains "restored"
}

@test "gut stash apply applies stash without removing it" {
    local f; f=$(git ls-files | head -1)
    echo "applied" >> "$f"
    git stash push -m "to-apply"
    run "$GUT" stash apply 0
    [ "$status" -eq 0 ]
    assert_output_contains "applied"
    run git stash list
    assert_output_contains "to-apply"
}

@test "gut stash show shows diff of stash" {
    local f; f=$(git ls-files | head -1)
    echo "showme" >> "$f"
    git stash push -m "show-test"
    run "$GUT" stash show 0
    [ "$status" -eq 0 ]
    assert_output_contains "showme"
}

@test "gut stash drop with 'y' deletes a stash" {
    local f; f=$(git ls-files | head -1)
    echo "drop-me" >> "$f"
    git stash push -m "to-drop"
    # Use here-string to deliver 'y' to the interactive prompt
    run bash -c "printf 'y\n' | '$GUT' stash drop 0"
    assert_output_contains "dropped"
    run git stash list
    [ "$output" = "" ]
}

@test "gut stash clear with 'y' removes all stashes" {
    local f; f=$(git ls-files | head -1)
    echo "a" >> "$f"; git stash push -m "s1"
    echo "b" >> "$f"; git stash push -m "s2"
    run bash -c "printf 'y\n' | '$GUT' stash clear"
    assert_output_contains "cleared"
    run git stash list
    [ "$output" = "" ]
}

@test "gut stash unknown subcommand exits non-zero" {
    run "$GUT" stash frobnicate
    [ "$status" -ne 0 ]
    assert_output_contains "Unknown stash subcommand"
}

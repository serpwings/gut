#!/usr/bin/env bats
# tests/compare.bats  tests for lib/compare.sh (gut compare)

load 'test_helper'

setup() {
    setup_repo
    add_commit "base"
    git checkout -q -b feature
    add_commit "feature commit A"
    add_commit "feature commit B"
    git checkout -q main
    add_commit "main commit"
}
teardown() { teardown_repo; }

@test "gut compare shows ahead/behind counts" {
    git checkout feature
    run "$GUT" compare main
    [ "$status" -eq 0 ]
    assert_output_contains "ahead"
    assert_output_contains "behind"
}

@test "gut compare shows changed files section" {
    git checkout feature
    run "$GUT" compare main
    [ "$status" -eq 0 ]
    assert_output_contains "Changed Files"
}

@test "gut compare shows commits unique to current branch" {
    git checkout feature
    run "$GUT" compare main
    [ "$status" -eq 0 ]
    assert_output_contains "feature commit"
}

@test "gut compare without argument exits non-zero" {
    run "$GUT" compare
    [ "$status" -ne 0 ]
    assert_output_contains "Usage"
}

@test "gut compare with unknown branch exits non-zero" {
    run "$GUT" compare totally-nonexistent-branch
    [ "$status" -ne 0 ]
    assert_output_contains "Unknown branch"
}

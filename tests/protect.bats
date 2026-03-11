#!/usr/bin/env bats
# tests/protect.bats  tests for lib/protect.sh (gut protect)

load 'test_helper'

setup() { setup_repo; add_commit "initial"; }
teardown() { teardown_repo; }

#  status 

@test "gut protect status shows no protection when hook absent" {
    run "$GUT" protect status
    [ "$status" -eq 0 ]
    assert_output_contains "No branch protection"
}

#  add 

@test "gut protect add creates a pre-push hook" {
    run "$GUT" protect add main
    [ "$status" -eq 0 ]
    assert_output_contains "protected"
    assert_file_exists ".git/hooks/pre-push"
}

@test "gut protect add marks hook as executable" {
    "$GUT" protect add main
    [ -x ".git/hooks/pre-push" ]
}

@test "gut protect status shows protected branch after add" {
    "$GUT" protect add main
    run "$GUT" protect status
    [ "$status" -eq 0 ]
    assert_output_contains "main"
    assert_output_contains "Protection active"
}

@test "gut protect add multiple branches accumulates them" {
    "$GUT" protect add main
    "$GUT" protect add develop
    run "$GUT" protect status
    assert_output_contains "main"
    assert_output_contains "develop"
}

@test "gut protect add duplicate branch warns and does not duplicate" {
    "$GUT" protect add main
    run "$GUT" protect add main
    [ "$status" -eq 0 ]
    assert_output_contains "already protected"
    # hook should still only list main once
    local count
    count=$(grep -o "main" .git/hooks/pre-push | wc -l)
    [ "$count" -eq 1 ]
}

#  remove 

@test "gut protect remove removes a single branch" {
    "$GUT" protect add main
    "$GUT" protect add develop
    run "$GUT" protect remove develop
    [ "$status" -eq 0 ]
    assert_output_contains "no longer protected"
    run "$GUT" protect status
    assert_output_not_contains "develop"
    assert_output_contains "main"
}

@test "gut protect remove last branch deletes the hook file" {
    "$GUT" protect add main
    "$GUT" protect remove main
    [ ! -f ".git/hooks/pre-push" ]
}

@test "gut protect remove without a name exits non-zero" {
    run "$GUT" protect remove
    [ "$status" -ne 0 ]
    assert_output_contains "Usage"
}

@test "gut protect remove when no protection warns" {
    run "$GUT" protect remove main
    [ "$status" -eq 0 ]
    assert_output_contains "No protection"
}

#  unknown subcommand 

@test "gut protect unknown subcommand exits non-zero" {
    run "$GUT" protect frobnicate
    [ "$status" -ne 0 ]
    assert_output_contains "Unknown protect subcommand"
}

#!/usr/bin/env bats
# tests/replay.bats  tests for lib/replay.sh (gut replay)

load 'test_helper'

setup() { setup_repo; add_commit "initial"; }
teardown() { teardown_repo; }

@test "gut replay exits non-zero for non-numeric N" {
    add_commit "a"
    run "$GUT" replay abc
    [ "$status" -ne 0 ]
    assert_output_contains "valid number"
}

@test "gut replay exits non-zero for N < 1" {
    add_commit "a"
    run "$GUT" replay 0
    [ "$status" -ne 0 ]
    assert_output_contains "valid number"
}

@test "gut replay squash combines N commits into one" {
    add_commit "wip 1"
    add_commit "wip 2"
    add_commit "wip 3"
    # N=3 is passed as CLI arg; needs a base commit (initial) so HEAD~3 resolves
    run bash -c "printf '1\ncombined\n' | '$GUT' replay 3"
    [ "$status" -eq 0 ]
    assert_output_contains "Squashed"
    [ "$(git log --oneline | wc -l | tr -d ' ')" -eq 2 ]  # initial + squashed
    git log --oneline | grep -q "combined"
}

@test "gut replay squash rejects empty message" {
    add_commit "a"
    add_commit "b"
    run bash -c "printf '1\n\n' | '$GUT' replay 2"
    [ "$status" -ne 0 ]
    assert_output_contains "cannot be empty"
}

@test "gut replay reword changes single commit message" {
    add_commit "old message"
    run bash -c "printf '2\nnew message\n' | '$GUT' replay 1"
    [ "$status" -eq 0 ]
    assert_output_contains "updated"
    git log --oneline | grep -q "new message"
}

@test "gut replay reword exits non-zero for empty new message" {
    add_commit "has message"
    run bash -c "printf '2\n\n' | '$GUT' replay 1"
    [ "$status" -ne 0 ]
    assert_output_contains "cannot be empty"
}

@test "gut replay cancel leaves history untouched" {
    add_commit "stay"
    run bash -c "printf '5\n' | '$GUT' replay 1"
    [ "$status" -eq 0 ]
    assert_output_contains "Cancelled"
    git log --oneline | grep -q "stay"
}

@test "gut replay drop option does not use mapfile" {
    run grep -c "mapfile" "${GUT_HOME}/lib/replay.sh"
    [ "$output" -eq 0 ]
}

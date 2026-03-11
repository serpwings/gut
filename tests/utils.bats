#!/usr/bin/env bats
# tests/utils.bats  tests for shared utilities in lib/utils.sh

load 'test_helper'

setup() { setup_repo; }
teardown() { teardown_repo; }

@test "gut_is_repo returns 0 inside a git repo" {
    run bash -c "
        source '${GUT_HOME}/lib/utils.sh'
        gut_is_repo
    "
    [ "$status" -eq 0 ]
}

@test "gut_is_repo returns 1 outside a git repo" {
    local tmp
    tmp=$(mktemp -d)
    run bash -c "cd '$tmp' && source '${GUT_HOME}/lib/utils.sh' && gut_is_repo"
    [ "$status" -ne 0 ]
    rm -rf "$tmp"
}

@test "gut_confirm defaults to 'n' and returns 1 with empty input" {
    run bash -c "
        source '${GUT_HOME}/lib/utils.sh'
        echo '' | gut_confirm 'Are you sure?'
    "
    [ "$status" -eq 1 ]
}

@test "gut_confirm accepts 'y' input" {
    run bash -c "source '${GUT_HOME}/lib/utils.sh' && gut_confirm 'Sure?' <<< 'y'"
    [ "$status" -eq 0 ]
}

@test "gut_confirm accepts 'yes' input" {
    run bash -c "source '${GUT_HOME}/lib/utils.sh' && gut_confirm 'Sure?' <<< 'yes'"
    [ "$status" -eq 0 ]
}

@test "gut_confirm rejects 'n' input" {
    run bash -c "source '${GUT_HOME}/lib/utils.sh' && gut_confirm 'Sure?' <<< 'n'"
    [ "$status" -eq 1 ]
}

@test "gut_error writes to stderr" {
    run bash -c "
        source '${GUT_HOME}/lib/utils.sh'
        gut_error 'something went wrong' 2>&1
    "
    assert_output_contains "something went wrong"
}

@test "gut_translate_error handles detached HEAD" {
    run bash -c "
        source '${GUT_HOME}/lib/utils.sh'
        gut_translate_error 'detached HEAD detected'
    "
    assert_output_contains "detached"
}

@test "gut_translate_error handles non-fast-forward" {
    run bash -c "
        source '${GUT_HOME}/lib/utils.sh'
        gut_translate_error 'non-fast-forward'
    "
    assert_output_contains "remote has changes"
}

@test "gut_translate_error handles diverged" {
    run bash -c "
        source '${GUT_HOME}/lib/utils.sh'
        gut_translate_error 'your branch has diverged'
    "
    assert_output_contains "diverged"
}

@test "gut --help exits 0 and shows usage" {
    run "$GUT" --help
    [ "$status" -eq 0 ]
    assert_output_contains "gut"
    assert_output_contains "Commands"
}

@test "gut --version shows version string" {
    run "$GUT" --version
    [ "$status" -eq 0 ]
    assert_output_contains "gut v"
}

@test "gut unknown command exits non-zero" {
    run "$GUT" totally-made-up-command
    [ "$status" -ne 0 ]
    assert_output_contains "Unknown command"
}

@test "gut outside a repo shows friendly error" {
    local tmp
    tmp=$(mktemp -d)
    run bash -c "cd '$tmp' && '$GUT' status"
    [ "$status" -ne 0 ]
    assert_output_contains "Not in a Git repository"
    rm -rf "$tmp"
}

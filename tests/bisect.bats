#!/usr/bin/env bats
# tests/bisect.bats  tests for lib/bisect.sh (gut bisect)

load 'test_helper'

setup() {
    setup_repo
    for i in 1 2 3 4 5; do add_commit "commit $i"; done
}
teardown() {
    git bisect reset 2>/dev/null || true
    teardown_repo
}

@test "gut bisect start begins a bisect session" {
    local first_hash
    first_hash=$(git log --oneline | tail -1 | awk '{print $1}')
    run bash -c "printf 'HEAD\n${first_hash}\n' | '$GUT' bisect start"
    [ "$status" -eq 0 ]
    assert_output_contains "Bisect started"
    git bisect reset 2>/dev/null || true
}

@test "gut bisect start requires a good commit" {
    run bash -c "printf 'HEAD\n\n' | '$GUT' bisect start"
    [ "$status" -ne 0 ]
    assert_output_contains "required"
}

@test "gut bisect abort returns to HEAD" {
    local first_hash head_before
    first_hash=$(git log --oneline | tail -1 | awk '{print $1}')
    head_before=$(git rev-parse HEAD)
    git bisect start
    git bisect bad HEAD
    git bisect good "$first_hash"
    run "$GUT" bisect abort
    [ "$status" -eq 0 ]
    assert_output_contains "aborted"
    [ "$(git rev-parse HEAD)" = "$head_before" ]
}

@test "gut bisect log shows bisect history" {
    local first_hash
    first_hash=$(git log --oneline | tail -1 | awk '{print $1}')
    git bisect start
    git bisect bad HEAD
    git bisect good "$first_hash"
    run "$GUT" bisect log
    [ "$status" -eq 0 ]
    assert_output_contains "bisect"
    git bisect reset 2>/dev/null || true
}

@test "gut bisect unknown subcommand exits non-zero" {
    run "$GUT" bisect frobnicate
    [ "$status" -ne 0 ]
    assert_output_contains "Unknown bisect subcommand"
}

@test "gut bisect good source has no double git-bisect-good call" {
    # After the fix, git bisect good should only be called once (captured in bisect_out).
    # The old pattern was: git bisect good / then again in an if-pipe. Verify the
    # if-pipe pattern no longer exists by checking the fixed capture approach is present.
    run grep -c 'bisect_out=.*git bisect good' "${GUT_HOME}/lib/bisect.sh"
    [ "$output" -eq 1 ]
}

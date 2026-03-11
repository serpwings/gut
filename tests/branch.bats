#!/usr/bin/env bats
# tests/branch.bats  tests for lib/branch.sh (gut branch & gut switch)

load 'test_helper'

setup() { setup_repo; add_commit "initial"; }
teardown() { teardown_repo; }

@test "gut branch list shows current branch" {
    run "$GUT" branch list
    [ "$status" -eq 0 ]
    assert_output_contains "main"
}

@test "gut branch with no args lists branches" {
    run "$GUT" branch
    [ "$status" -eq 0 ]
    assert_output_contains "main"
}

@test "gut branch new creates and switches to a new branch" {
    run "$GUT" branch new feature/test
    [ "$status" -eq 0 ]
    assert_output_contains "feature/test"
    assert_on_branch "feature/test"
}

@test "gut branch new without a name exits non-zero" {
    run "$GUT" branch new
    [ "$status" -ne 0 ]
    assert_output_contains "required"
}

@test "gut branch delete removes a merged branch" {
    git checkout -b to-delete
    add_commit "branch commit"
    git checkout main
    git merge -q --no-ff to-delete -m "merge"
    run bash -c "printf 'y\n' | '$GUT' branch delete to-delete"
    [ "$status" -eq 0 ]
    run git branch
    assert_output_not_contains "to-delete"
}

@test "gut branch delete with 'n' confirmation aborts" {
    git checkout -b keep-branch
    add_commit "commit"
    git checkout main
    git merge -q --no-ff keep-branch -m "merge"
    run bash -c "printf 'n\n' | '$GUT' branch delete keep-branch"
    run git branch
    assert_output_contains "keep-branch"
}

@test "gut branch delete without a name exits non-zero" {
    run "$GUT" branch delete
    [ "$status" -ne 0 ]
    assert_output_contains "required"
}

@test "gut branch rename renames current branch" {
    git checkout -b old-name
    add_commit "rename test"
    run "$GUT" branch rename new-name
    [ "$status" -eq 0 ]
    assert_on_branch "new-name"
}

@test "gut branch rename with two args renames a specific branch" {
    git checkout -b source-branch
    add_commit "x"
    git checkout main
    run "$GUT" branch rename source-branch dest-branch
    [ "$status" -eq 0 ]
    run git branch
    assert_output_contains "dest-branch"
    assert_output_not_contains "source-branch"
}

@test "gut switch changes to an existing branch" {
    git checkout -b other
    add_commit "other commit"
    git checkout main
    run "$GUT" switch other
    [ "$status" -eq 0 ]
    assert_on_branch "other"
}

@test "gut switch to nonexistent branch exits non-zero" {
    run "$GUT" switch nonexistent-branch-xyz
    [ "$status" -ne 0 ]
}

@test "gut switch with no argument exits non-zero" {
    run "$GUT" switch
    [ "$status" -ne 0 ]
    assert_output_contains "required"
}

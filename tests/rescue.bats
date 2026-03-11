#!/usr/bin/env bats
# tests/rescue.bats  tests for lib/rescue.sh (gut rescue)

load 'test_helper'

setup() { setup_repo; add_commit "initial"; }
teardown() { teardown_repo; }

#  health check 

@test "gut rescue health check exits 0 in clean repo" {
    run "$GUT" rescue
    [ "$status" -eq 0 ]
    assert_output_contains "Health Check"
}

@test "gut rescue detects detached HEAD in health check" {
    git checkout --detach HEAD
    run "$GUT" rescue
    [ "$status" -eq 0 ]
    assert_output_contains "detached"
}

@test "gut rescue detects uncommitted changes in health check" {
    local f; f=$(git ls-files | head -1)
    echo "dirty" >> "$f"
    run "$GUT" rescue
    [ "$status" -eq 0 ]
    assert_output_contains "Uncommitted"
}

@test "gut rescue detects missing remote in health check" {
    run "$GUT" rescue
    assert_output_contains "No remote"
}

#  rescue init 

@test "gut rescue init warns if already a repo" {
    run "$GUT" rescue init
    [ "$status" -eq 0 ]
    assert_output_contains "already a Git repository"
}

@test "gut rescue init initialises a fresh repo" {
    local tmp; tmp=$(mktemp -d)
    run bash -c "cd '$tmp' && '$GUT' rescue init"
    [ "$status" -eq 0 ]
    assert_output_contains "initialized"
    [ -d "$tmp/.git" ]
    rm -rf "$tmp"
}

#  rescue detached 

@test "gut rescue detached option 1 creates a new branch" {
    git checkout --detach HEAD
    run bash -c "printf '1\nsaved-branch\n' | '$GUT' rescue detached"
    [ "$status" -eq 0 ]
    assert_on_branch "saved-branch"
}

@test "gut rescue detached option 2 switches to existing branch" {
    git checkout --detach HEAD
    run bash -c "printf '2\nmain\n' | '$GUT' rescue detached"
    [ "$status" -eq 0 ]
    assert_on_branch "main"
}

#  rescue conflicts 

@test "gut rescue conflicts reports no conflicts when clean" {
    run "$GUT" rescue conflicts
    [ "$status" -eq 0 ]
    assert_output_contains "No conflicts"
}

@test "gut rescue conflicts shows conflicting files" {
    # Create a merge conflict
    git checkout -b branch-a
    echo "version A" > conflict.txt
    git add conflict.txt; git commit -q -m "branch-a change"
    git checkout main
    echo "version B" > conflict.txt
    git add conflict.txt; git commit -q -m "main change"
    git merge --no-commit branch-a 2>/dev/null || true
    run "$GUT" rescue conflicts
    [ "$status" -eq 0 ]
    assert_output_contains "conflict.txt"
}

#  rescue rebase 

@test "gut rescue rebase reports no rebase when clean" {
    run "$GUT" rescue rebase
    [ "$status" -eq 0 ]
    assert_output_contains "No rebase in progress"
}

#  rescue stash 

@test "gut rescue stash shows no stashes when empty" {
    run "$GUT" rescue stash
    [ "$status" -eq 0 ]
    assert_output_contains "no stashes"
}

#  unknown subcommand 

@test "gut rescue unknown subcommand exits non-zero" {
    run "$GUT" rescue frobnicate
    [ "$status" -ne 0 ]
    assert_output_contains "Unknown rescue subcommand"
}

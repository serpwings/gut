#!/usr/bin/env bats
# tests/status.bats  tests for lib/status.sh (gut status & gut history)

load 'test_helper'

setup() { setup_repo; }
teardown() { teardown_repo; }

#  gut status 

@test "gut status shows branch name" {
    add_commit "init"
    run "$GUT" status
    [ "$status" -eq 0 ]
    assert_output_contains "main"
}

@test "gut status shows staged new file" {
    echo "new" > staged.txt
    git add staged.txt
    run "$GUT" status
    [ "$status" -eq 0 ]
    assert_output_contains "Staged"
    assert_output_contains "staged.txt"
    assert_output_contains "NEW"
}

@test "gut status shows staged modified file" {
    add_commit "init"
    echo "changed" > file_*.txt
    # find the committed file and modify it
    local f
    f=$(git ls-files | head -1)
    echo "modified" >> "$f"
    git add "$f"
    run "$GUT" status
    [ "$status" -eq 0 ]
    assert_output_contains "MOD"
}

@test "gut status shows unstaged modifications" {
    add_commit "init"
    local f
    f=$(git ls-files | head -1)
    echo "unstaged change" >> "$f"
    run "$GUT" status
    [ "$status" -eq 0 ]
    assert_output_contains "Unstaged"
}

@test "gut status shows untracked files" {
    add_commit "init"
    echo "new" > untracked.txt
    run "$GUT" status
    [ "$status" -eq 0 ]
    assert_output_contains "Untracked"
    assert_output_contains "untracked.txt"
}

@test "gut status clean repo shows nothing staged, nothing modified" {
    add_commit "init"
    run "$GUT" status
    [ "$status" -eq 0 ]
    assert_output_contains "nothing staged"
    assert_output_contains "nothing modified"
}

@test "gut status detached HEAD shows warning" {
    add_commit "init"
    git checkout --detach HEAD
    run "$GUT" status
    [ "$status" -eq 0 ]
    assert_output_contains "detached"
}

#  gut history 

@test "gut history shows commits" {
    add_commit "first commit"
    add_commit "second commit"
    run "$GUT" history
    [ "$status" -eq 0 ]
    assert_output_contains "first commit"
    assert_output_contains "second commit"
}

@test "gut history N limits to N commits" {
    for i in 1 2 3 4 5; do add_commit "commit $i"; done
    run "$GUT" history 2
    [ "$status" -eq 0 ]
    # Should show at most 2 commits
    local count
    count=$(echo "$output" | grep -c "commit [0-9]")
    [ "$count" -le 2 ]
}

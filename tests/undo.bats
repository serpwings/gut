#!/usr/bin/env bats
# tests/undo.bats  tests for lib/undo.sh (gut undo)

load 'test_helper'

setup() { setup_repo; }
teardown() { teardown_repo; }

#  Soft undo (commit mode) 

@test "gut undo soft-undoes the last commit and keeps changes staged" {
    add_commit "first"
    run "$GUT" undo
    [ "$status" -eq 0 ]
    assert_output_contains "undone"
    # No commits remain
    local commits; commits=$(git log --oneline 2>/dev/null | wc -l | tr -d ' ')
    [ "$commits" -eq 0 ]
    # Changes should be staged
    git diff --cached --name-only | grep -q "."
}

@test "gut undo -n 2 soft-undoes 2 commits" {
    add_commit "a"
    add_commit "b"
    add_commit "c"
    run "$GUT" undo -n 2
    [ "$status" -eq 0 ]
    [ "$(git log --oneline | wc -l | tr -d ' ')" -eq 1 ]
}

@test "gut undo on no commits prints an error" {
    run "$GUT" undo
    assert_output_contains "No commits to undo"
}

#  Hard undo (with confirmation) 

@test "gut undo --hard with 'y' discards last commit and changes" {
    add_commit "to-discard"
    run bash -c "printf 'y\n' | '$GUT' undo --hard" || true
    assert_output_contains "Discarded"
    local commits; commits=$(git log --oneline 2>/dev/null | wc -l | tr -d ' ')
    [ "$commits" -eq 0 ]
}

@test "gut undo --hard with 'n' aborts and preserves commit" {
    add_commit "keep-me"
    run bash -c "printf 'n\n' | '$GUT' undo --hard" || true
    [ "$(git log --oneline | wc -l | tr -d ' ')" -eq 1 ]
}

#  File mode 

@test "gut undo <file> unstages a staged file" {
    add_commit "base"
    echo "staged content" > staged_file.txt
    git add staged_file.txt
    run "$GUT" undo staged_file.txt
    [ "$status" -eq 0 ]
    assert_output_contains "Unstaged"
    run git diff --cached --name-only
    assert_output_not_contains "staged_file.txt"
}

@test "gut undo --hard <file> with 'y' discards working-tree changes" {
    add_commit "baseline"
    local f; f=$(git ls-files | head -1)
    echo "dirty" >> "$f"
    bash -c "printf 'y\n' | '$GUT' undo --hard '$f'" || true
    # File should be restored to the last committed state
    run git diff "$f"
    [ "$output" = "" ]
}

#  Root commit edge case 

@test "gut undo handles undoing the root commit gracefully" {
    add_commit "root"
    run "$GUT" undo
    [ "$status" -eq 0 ]
    local commits; commits=$(git log --oneline 2>/dev/null | wc -l | tr -d ' ')
    [ "$commits" -eq 0 ]
}

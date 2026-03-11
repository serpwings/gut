#!/usr/bin/env bats
# tests/save.bats  tests for lib/save.sh (gut save)

load 'test_helper'

setup() { setup_repo; }
teardown() { teardown_repo; }

#  Basic staging + commit 

@test "gut save -m creates a commit from already-staged files" {
    echo "hello" > hello.txt
    git add hello.txt
    run "$GUT" save -m "initial commit"
    [ "$status" -eq 0 ]
    assert_output_contains "saved"
    [ "$(git log --oneline | wc -l)" -eq 1 ]
}

@test "gut save --all -m stages and commits all changes" {
    echo "foo" > foo.txt
    run "$GUT" save --all -m "add foo"
    [ "$status" -eq 0 ]
    assert_output_contains "saved"
    [ "$(git log --oneline | wc -l)" -eq 1 ]
}

@test "gut save -a -m is an alias for --all" {
    echo "bar" > bar.txt
    run "$GUT" save -a -m "add bar"
    [ "$status" -eq 0 ]
    [ "$(git log --oneline | wc -l)" -eq 1 ]
}

@test "gut save stages and commits specific files only" {
    echo "keep" > keep.txt
    echo "skip" > skip.txt
    run "$GUT" save keep.txt -m "only keep"
    [ "$status" -eq 0 ]
    # skip.txt should be untracked
    git status --porcelain | grep -q "?? skip.txt"
}

@test "gut save with no staged files warns instead of committing" {
    run "$GUT" save -m "nothing here"
    [ "$status" -eq 0 ]
    assert_output_contains "Nothing to save"
}

#  Amend 

@test "gut save --amend -m rewrites the last commit message" {
    add_commit "original message"
    run "$GUT" save --amend -m "amended message"
    [ "$status" -eq 0 ]
    git log --oneline | grep -q "amended message"
}

@test "gut save --amend incorporates staged changes into last commit" {
    add_commit "first"
    echo "extra" > extra.txt
    git add extra.txt
    run "$GUT" save --amend -m "first + extra"
    [ "$status" -eq 0 ]
    # Still only one commit in history
    [ "$(git log --oneline | wc -l)" -eq 1 ]
}

#  Message validation 

@test "gut save rejects an empty commit message when prompted" {
    echo "content" > f.txt
    git add f.txt
    # Send empty string as interactive message
    run bash -c "echo '' | '$GUT' save"
    [ "$status" -ne 0 ]
    assert_output_contains "cannot be empty"
}

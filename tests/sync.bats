#!/usr/bin/env bats
# tests/sync.bats  tests for lib/sync.sh (gut sync)

load 'test_helper'

# Re-usable helper: init a repo, commit, set up a local bare remote, push.
# Uses the branch name 'main' and forces the bare remote to also use 'main'.
_setup_with_remote() {
    setup_repo
    # Rename branch to 'main' portably (works on all git versions)
    git branch -m main 2>/dev/null || git checkout -b main 2>/dev/null || true
    add_commit "initial"
    REMOTE_DIR="$(mktemp -d)"
    git -c init.defaultBranch=main init -q --bare "$REMOTE_DIR" 2>/dev/null \
        || git init -q --bare "$REMOTE_DIR"
    git remote add origin "$REMOTE_DIR"
    git push -q --set-upstream origin HEAD:main 2>/dev/null
    # Ensure local branch is tracking origin/main (suppress "branch set up" message)
    git branch --set-upstream-to=origin/main main >/dev/null 2>&1 || true
}


setup() { _setup_with_remote; }
teardown() {
    teardown_repo
    [[ -n "$REMOTE_DIR" ]] && rm -rf "$REMOTE_DIR"
}

@test "gut sync reports up to date when nothing changed" {
    run bash -c "'$GUT' sync 2>&1"
    [ "$status" -eq 0 ]
    assert_output_contains "up to date"
}

@test "gut sync pushes when local is ahead" {
    add_commit "local new commit"
    run bash -c "'$GUT' sync 2>&1"
    [ "$status" -eq 0 ]
    assert_output_contains "pushed"
}

@test "gut sync pulls when remote is ahead" {
    local clone_dir
    clone_dir=$(mktemp -d)
    git clone -q "$REMOTE_DIR" "$clone_dir"
    (
        cd "$clone_dir"
        git config user.email "test@gut.local"
        git config user.name "Test"
        echo "remote" > remote_file.txt
        git add remote_file.txt
        git commit -q -m "remote commit"
        git push -q
    )
    rm -rf "$clone_dir"
    run "$GUT" sync
    [ "$status" -eq 0 ]
    assert_output_contains "Pulled"
}

@test "gut sync --publish pushes a new branch for the first time" {
    git checkout -q -b new-feature
    add_commit "feature work"
    run "$GUT" sync --publish
    [ "$status" -eq 0 ]
    assert_output_contains "published"
}

@test "gut sync without upstream exits non-zero" {
    git checkout --orphan orphan-branch
    git rm -rf . >/dev/null 2>&1 || true
    add_commit "orphan"
    run "$GUT" sync
    [ "$status" -ne 0 ]
}

@test "gut sync exits with error if remote is unreachable" {
    git remote set-url origin "git://255.255.255.255/nonexistent.git"
    run "$GUT" sync
    # sync should fail  exact error message may vary by OS/timeout
    [ "$status" -ne 0 ]
}

@test "gut sync warns about unsaved local changes" {
    # git diff --quiet only checks tracked files; modify one
    local f; f=$(git ls-files | head -1)
    echo "dirty" >> "$f"
    run bash -c "'$GUT' sync 2>&1"
    assert_output_contains "unsaved local changes"
}

#!/usr/bin/env bats
# tests/patch.bats  tests for lib/patch.sh (gut patch)

load 'test_helper'

setup() {
    setup_repo
    add_commit "first commit"
    add_commit "second commit"
    PATCH_DIR="$(mktemp -d)"
}
teardown() {
    teardown_repo
    [[ -n "$PATCH_DIR" ]] && rm -rf "$PATCH_DIR"
}

@test "gut patch create exports the last commit as a .patch file" {
    run "$GUT" patch create 1 "$PATCH_DIR"
    [ "$status" -eq 0 ]
    assert_output_contains "Patch file"
    local count
    count=$(find "$PATCH_DIR" -maxdepth 1 -name "*.patch" | wc -l | tr -d ' ')
    [ "$count" -gt 0 ]
}

@test "gut patch create N=2 exports 2 commits" {
    run "$GUT" patch create 2 "$PATCH_DIR"
    [ "$status" -eq 0 ]
    local count
    count=$(find "$PATCH_DIR" -maxdepth 1 -name "*.patch" | wc -l | tr -d ' ')
    [ "$count" -ge 2 ]
}

@test "gut patch apply imports a patch into a fresh repo" {
    # Generate a patch from this repo into a temp directory
    git format-patch -1 --output-directory "$PATCH_DIR" HEAD
    local patch_file
    patch_file=$(find "$PATCH_DIR" -maxdepth 1 -name "*.patch" | head -1)

    # Create a new repo at the parent state (one commit behind)
    local fresh_dir
    fresh_dir=$(mktemp -d)
    cd "$fresh_dir"
    git init -q
    git checkout -q -b main 2>/dev/null || true
    git commit -q --allow-empty -m "root"

    run "$GUT" patch apply "$patch_file"
    [ "$status" -eq 0 ]
    assert_output_contains "applied"
    cd "$REPO_DIR"
    rm -rf "$fresh_dir"
}

@test "gut patch apply with missing file exits non-zero" {
    run "$GUT" patch apply "$PATCH_DIR/does-not-exist.patch"
    [ "$status" -ne 0 ]
    assert_output_contains "not found"
}

@test "gut patch apply with no argument exits non-zero" {
    run "$GUT" patch apply
    [ "$status" -ne 0 ]
    assert_output_contains "Usage"
}

@test "gut patch unknown subcommand exits non-zero" {
    run "$GUT" patch frobnicate
    [ "$status" -ne 0 ]
    assert_output_contains "Unknown patch subcommand"
}

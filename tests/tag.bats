#!/usr/bin/env bats
# tests/tag.bats  tests for lib/tag.sh (gut tag)

load 'test_helper'

setup() { setup_repo; add_commit "initial"; }
teardown() { teardown_repo; }

@test "gut tag list shows empty message when no tags" {
    run "$GUT" tag list
    [ "$status" -eq 0 ]
    assert_output_contains "no tags"
}

@test "gut tag list shows existing tags" {
    git tag v1.0.0
    run "$GUT" tag list
    [ "$status" -eq 0 ]
    assert_output_contains "v1.0.0"
}

@test "gut tag create makes a lightweight tag" {
    # Send empty message for the optional annotation prompt
    run bash -c "printf '\n' | '$GUT' tag create v0.1.0"
    [ "$status" -eq 0 ]
    assert_output_contains "created"
    git tag | grep -q "v0.1.0"
}

@test "gut tag create with -m makes an annotated tag" {
    run "$GUT" tag create v1.2.0 -m "Release 1.2.0"
    [ "$status" -eq 0 ]
    assert_output_contains "created"
    git tag -n | grep -q "Release 1.2.0"
}

@test "gut tag create without a name exits non-zero" {
    run bash -c "printf '\n' | '$GUT' tag create"
    [ "$status" -ne 0 ]
}

@test "gut tag with version shorthand creates a tag" {
    run bash -c "printf '\n' | '$GUT' tag v2.0.0"
    [ "$status" -eq 0 ]
    assert_output_contains "created"
    git tag | grep -q "v2.0.0"
}

@test "gut tag latest shows the most recent tag" {
    git tag v0.9.0
    add_commit "after tag"
    git tag v1.0.0
    run "$GUT" tag latest
    [ "$status" -eq 0 ]
    assert_output_contains "v1.0.0"
}

@test "gut tag latest warns when no tags exist" {
    run "$GUT" tag latest
    # gut_warn uses stdout; exit code may be 0 or non-zero
    assert_output_contains "No tags found"
}

@test "gut tag delete removes a tag locally" {
    git tag v9.9.9
    run bash -c "printf 'n\n' | '$GUT' tag delete v9.9.9"
    # Output says "Tag 'v9.9.9' deleted."
    assert_output_contains "v9.9.9"
    run git tag
    assert_output_not_contains "v9.9.9"
}

@test "gut tag delete without a name exits non-zero" {
    run bash -c "printf '\n' | '$GUT' tag delete"
    [ "$status" -ne 0 ]
    assert_output_contains "Usage"
}

@test "gut tag unknown subcommand exits non-zero" {
    run "$GUT" tag frobnicate
    [ "$status" -ne 0 ]
    assert_output_contains "Unknown tag subcommand"
}

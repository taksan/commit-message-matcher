#!/usr/bin/env ./libs/bats/bin/bats
load 'libs/bats-assert/load'
load 'libs/bats-support/load'

setup() {
    SUBJECT=$(realpath ${BATS_TEST_DIRNAME}/../matcher.sh)
    TMP_DIR=$(mktemp -d /tmp/test-XXXXXX)
    cd $TMP_DIR && mkdir fake-repo && cd fake-repo
    (
        git init
        git config --local user.email "you@example.com"
        git config --local user.name "Your Name"
        echo "fake-repo" > README.md
        git add README.md
        git commit -m "some stuff"
    ) > /dev/null
    LATEST_SHA=$(git rev-parse HEAD)
}

teardown() {
    if [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"
    fi
}

@test "should match message pattern" {
    cd $TMP_DIR/fake-repo

    run $SUBJECT "$LATEST_SHA" stuff
    local EXPECTED="::set-output name=matches::true"

    assert_output --partial "$EXPECTED"
}

@test "should NOT match message pattern" {
    cd $TMP_DIR/fake-repo

    run $SUBJECT "$LATEST_SHA" fakestuff
    local EXPECTED="::set-output name=matches::false"

    assert_output --partial "$EXPECTED"
}

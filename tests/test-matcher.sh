#!/bin/bash
set -euo pipefail

function prepare() {
    exec 3>&1
    exec 1>&-
    rm -fr fake-repo
    mkdir fake-repo
    echo "fake-repo" > fake-repo/README.md
    cd fake-repo
    git init
    git add README.md
    git commit -m "some stuff"
    git rev-parse HEAD >&3
}

function should_match() {
    local LATEST_SHA=$(prepare)
    local ACTUAL=$(cd fake-repo && $SUBJECT "$LATEST_SHA" stuff)
    local EXPECTED="::set-output name=matches::true"
    assert_equals "$EXPECTED" "$ACTUAL"
}

function should_not_match() {
    local LATEST_SHA=$(prepare)
    local ACTUAL=$(cd fake-repo && $SUBJECT "$LATEST_SHA" nostuff)
    local EXPECTED="::set-output name=matches::false"
    assert_equals "$EXPECTED" "$ACTUAL"
}

function @test() {
    local test_name=$1
    $test_name > /tmp/error || {
        echo "$test_name ${txtred}failed${txtreset}"
        cat /tmp/error
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
     }
}

function assert_equals() {
    local EXPECTED=$1
    local ACTUAL=$2
    if [ "$ACTUAL" != "$EXPECTED" ]; then
        echo "  Expected: $EXPECTED"
        echo "  Actual:   $ACTUAL"
        return 1
    fi
}
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
txtred=$(tput setaf 1)    # Red
txtreset=$(tput sgr0)     # Reset your text

SUBJECT=$(realpath ${DIR}/../matcher.sh)

FAIL_COUNT=0
@test should_match
@test should_not_match

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo "All tests passed"
else
    echo "Some tests failed; See above"
    exit 1
fi
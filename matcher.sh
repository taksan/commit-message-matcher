#!/bin/bash

set -eu

COMMIT_SHA="$1"
PATTERN="$2"

MESSAGE=$(git log --format=%B -n 1 "$COMMIT_SHA")
RESULT="false"
if [[ "$MESSAGE" =~ $PATTERN ]]; then
    RESULT="true"
fi
echo "::set-output name=matches::$RESULT"
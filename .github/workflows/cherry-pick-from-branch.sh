#!/usr/bin/env bash

set -euo pipefail

# This script is intended to be called by the Github Action update_upstream_from_fork.yaml
# It is triggered on a push event and will cherry-pick the commits from the push
# onto "DEST_REMOTE/$DEST_BRANCH
# Assumptions:
# In a repo
# $DEST_REPO/$DEST_BRANCH is defined, readable, and writeable
# $BEFORE_SHA..$LAST_SHA must define a sequence of commits

# TODO git grep agave -- * after cherry-pick. Fail if we find new agave references?

DEST_REMOTE=$1      # eg "upstream" (must already be defined and writeable in the repo)
DEST_BRANCH=$2      # eg "master" - must exist in the repo
BEFORE_SHA=$3       # the last commit before the ones to cherry-pick. $BEFORE_SHA is NOT cherry-picked.
LAST_SHA=$4         # The last commit to cherry-pick.

echo "DEST_REMOTE: $DEST_REMOTE"
echo "DEST_BRANCH: $DEST_BRANCH"
echo "BEFORE_SHA: $BEFORE_SHA"
echo "LAST_SHA: $LAST_SHA"

SKIP_COMMIT_STRING="\[anza migration\]"

# TODO commenting these causes a silent failure. Make it fail loudly
git config --global user.email "noreply@anza.xyz"
git config --global user.name "GHA: Update Upstream From Fork"
git fetch --all
echo "-------------------------"
echo "git log --oneline remotes/$DEST_REMOTE/$DEST_BRANCH:"
git log --oneline "remotes/$DEST_REMOTE/$DEST_BRANCH" -10
echo "-----------------------"
echo "git log --oneline $BEFORE_SHA~..$LAST_SHA"
git log --oneline "$BEFORE_SHA~..$LAST_SHA" -10
echo "-------------------------"
git checkout -b temp_branch "remotes/$DEST_REMOTE/$DEST_BRANCH"

for sha1 in $(git log --reverse --format=format:%H $BEFORE_SHA..$LAST_SHA); do
    echo "-------------------------------------"
    echo "SHA1: $sha1"
    commit_message=$(git log --format=%B $sha1~..$sha1)
    echo "Commit message: $commit_message"
    if ! [[ $commit_message =~ $SKIP_COMMIT_STRING ]] ; then
        echo "Commit message '$commit_message' does not contain $SKIP_COMMIT_STRING. Cherry-picking..."
        git cherry-pick "$sha1"
    else
        echo "Commit message  '$commit_message' contains $SKIP_COMMIT_STRING. Skipping..."
    fi
done
git status
git log -10
git push "$DEST_REMOTE" "$DEST_BRANCH"      # TODO This seems to be pushing the local copy of DEST_BRANCH rather than the temp_branch

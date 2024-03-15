#!/usr/bin/env bash
# Why
# What
# Assumptions:
# In a repo
# $DEST_REPO/$DEST_BRANCH is defined, readable, and writeable
# $BEFORE_SHA..$LAST_SHA must define a sequence of commits
# fetch all has just been run

DEST_REMOTE=$1
DEST_BRANCH=$2
BEFORE_SHA=$3
LAST_SHA=$4

echo "DEST_REMOTE: $DEST_REMOTE"
echo "DEST_BRANCH: $DEST_BRANCH"
echo "BEFORE_SHA: $BEFORE_SHA"
echo "LAST_SHA: $LAST_SHA"

SKIP_COMMIT_STRING="DO NOT SYNC"

git config --global user.email "noreply@anza.xyz"
git config --global user.name "GHA: Update Upstream From Fork" #TODO better name
git fetch --all
echo "-------------------------"
echo "git log --oneline remotes/$DEST_REMOTE/$DEST_BRANCH:"
git log --oneline "remotes/$DEST_REMOTE/$DEST_BRANCH"
echo "-----------------------"
echo "git log --oneline $BEFORE_SHA~..$LAST_SHA"
git log --oneline "$BEFORE_SHA~..$LAST_SHA"
echo "-------------------------"
git branch -D temp_branch
git checkout -b temp_branch "remotes/$DEST_REMOTE/$DEST_BRANCH"

for sha1 in $(git log --reverse --format=format:%H $BEFORE_SHA..$LAST_SHA); do
    echo "-------------------------------------"
    echo "SHA1: $sha1"
    commit_message=$(git log --format=%B $sha1~..$sha1)
    echo "$commit_message"
    if ! [[ $commit_message =~ $SKIP_COMMIT_STRING ]] ; then
        echo "Commit message does not contain $SKIP_COMMIT_STRING. Cherry-picking..."
        git cherry-pick "$sha1"
    else
        echo "Commit message contains $SKIP_COMMIT_STRING. Skipping..."
    fi
done
git push "$DEST_REMOTE" "$DEST_BRANCH"

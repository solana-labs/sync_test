#!/usr/bin/env bash
# Shell script:
# input: sha_before, last_sha
# Checkout temp branch
# for sha in sha_before..last_sha
#   If commit message doesn't contain FOOBAR:
#     Cherry pick sha to temp branch
# Push upstream master


# TODO a way to skip a commit (CI migration, etc)
# TODO all referencs to "master" need to be dynamic


DEST_REMOTE=$1
DEST_BRANCH=$2
BEFORE_SHA=$3
LAST_SHA=$4

echo "DEST_REMOTE: $DEST_REMOTE"
echo "DEST_BRANCH: $DEST_BRANCH"
echo "BEFORE_SHA: $BEFORE_SHA"
echo "LAST_SHA: $LAST_SHA"

SKIP_COMMIT_STRING="DO NOT SYNC"

git config --global user.email "will.hickey@anza.xyz"
git config --global user.name "GHA: Update Upstream From Fork"
git fetch --all
echo "-------------------------"
echo "git log --oneline remotes/upstream/master:"
git log --oneline remotes/upstream/master
echo "-----------------------"
echo "git log --oneline origin/master"
git log --oneline origin/master
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
# git cherry-pick remotes/upstream/master..origin/master
# git push upstream master

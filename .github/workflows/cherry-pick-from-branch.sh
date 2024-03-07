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

SRC=$1
DEST=$2
BRANCH=$1
BEFORE_SHA=$4
LAST_SHA=$5

BRANCH="master"
SKIP_COMMIT_STRING="DO NOT SYNC"

git config --global user.email "will.hickey@anza.xyz"
git config --global user.name "GHA: Update Upstream From Fork"
git fetch --all
echo "-------------------------"
echo "git log --oneline remotes/upstream/master:"
git log --oneline remotes/upstream/master
echo "-----------------------\ngit log --oneline origin/master"
git log --oneline origin/master
echo "-------------------------"
# git branch -D temp_branch
# git checkout -b temp_branch "remotes/$DEST/$BRANCH"

for sha1 in $(git log --reverse --format=format:%H remotes/upstream/$BRANCH..origin/$BRANCH); do
    echo "SHA1: $sha1"
    commit_message=$(git log --format=%B $sha1~..$sha1)
    echo "$commit_message"
    if ! [[ $commit_message =~ $SKIP_COMMIT_STRING ]] ; then
        echo "$commit_message does not contain $SKIP_COMMIT_STRING"
    fi
    # if not include magic word
    # cherry pick commit
done
# git cherry-pick remotes/upstream/master..origin/master
# git push upstream master

#!/usr/bin/env bash
# Shell script:
# input: sha_before, last_sha
# Checkout temp branch
# for sha in sha_before..last_sha
#   If commit message doesn't contain FOOBAR:
#     Cherry pick sha to temp branch
# Push upstream master

git config --global user.email "will.hickey@anza.xyz"
git config --global user.name "GHA: Update Upstream From Fork"
git fetch --all
echo "-------------------------"
echo "git log --oneline remotes/upstream/master:"
git log --oneline remotes/upstream/master
echo "-----------------------\ngit log --oneline origin/master"
git log --oneline origin/master
echo "-------------------------"
git checkout -b temp_branch remotes/upstream/master
git cherry-pick remotes/upstream/master..origin/master
git push upstream master

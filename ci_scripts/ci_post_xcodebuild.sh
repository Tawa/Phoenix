#!/bin/sh

#  ci_post_xcodebuild.sh
#  Phoenix

if [[ $CI_WORKFLOW == "GitHub Release" ]];
then
    "$CI_WORKSPACE/ci_scripts/CreateGitHubRelease.swift" $CI_TAG $CI_ARCHIVE_PATH $GITHUB_TOKEN
fi

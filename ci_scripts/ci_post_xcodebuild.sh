#!/bin/sh

#  ci_post_xcodebuild.sh
#  Phoenix

if [[ $CI_WORKFLOW == "GitHub Release" ]];
then
    cd ci_scripts/release.xcarchive/Products/Applications/
    zip -r ../../../Phoenix.app.zip Phoenix.app
    
    ARCHIVE_PATH="$CI_WORKSPACE/ci_scripts/Phoenix.app.zip"
    "$CI_WORKSPACE/ci_scripts/CreateGitHubRelease.swift" $CI_TAG $ARCHIVE_PATH $GITHUB_TOKEN
fi

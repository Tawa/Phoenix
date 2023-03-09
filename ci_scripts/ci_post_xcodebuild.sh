#!/bin/sh

#  ci_post_xcodebuild.sh
#  Phoenix

if [[ $CI_WORKFLOW == "GitHub Release" ]];
then
    ARCHIVE_PATH="$CI_WORKSPACE/ci_scripts/Phoenix.app.zip"

    cd "$ARCHIVE_PATH/Products/Applications/"
    zip -r $ARCHIVE_PATH Phoenix.app
    
    "$CI_WORKSPACE/ci_scripts/CreateGitHubRelease.swift" $CI_TAG $ARCHIVE_PATH $GITHUB_TOKEN
fi

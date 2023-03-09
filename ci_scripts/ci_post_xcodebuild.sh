#!/bin/sh

#  ci_post_xcodebuild.sh
#  Phoenix

if [[ $CI_WORKFLOW == "GitHub Release" ]];
then
    ZIP_PATH="$CI_WORKSPACE/ci_scripts/Phoenix.app.zip"

    cd "$CI_ARCHIVE_PATH/Products/Applications/"
    zip -r $ZIP_PATH Phoenix.app
    
    "$CI_WORKSPACE/ci_scripts/CreateGitHubRelease.swift" $CI_TAG $ZIP_PATH $GITHUB_TOKEN
fi

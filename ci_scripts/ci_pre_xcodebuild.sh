#!/bin/sh

#  ci_pre_xcodebuild.sh
#  Phoenix

if [[ $CI_WORKFLOW == "GitHub Release" ]];
then
    # Replace entitlements to disable Sandbox for the GitHub Release
    cp -fr "$CI_PRIMARY_REPOSITORY_PATH/Phoenix/Phoenix.entitlements" "$CI_PRIMARY_REPOSITORY_PATH/Phoenix/PhoenixRelease.entitlements"
    "$CI_PRIMARY_REPOSITORY_PATH/ci_scripts/EnableGitHubReleaseTarget.swift" "$CI_PRIMARY_REPOSITORY_PATH/Phoenix.xcodeproj/xcshareddata/xcschemes/Phoenix.xcscheme"
fi

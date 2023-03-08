#!/bin/sh

#  ci_pre_xcodebuild.sh
#  Phoenix

if [[ $CI_WORKFLOW == "GitHub Release" ]];
then
    # Replace entitlements to disable Sandbox for the GitHub Release
    cp -fr "$CI_WORKSPACE/Phoenix/Phoenix.entitlements" "$CI_WORKSPACE/Phoenix/PhoenixRelease.entitlements"
    "$CI_WORKSPACE/ci_scripts/EnableGitHubReleaseTarget.swift" "$CI_WORKSPACE/Phoenix.xcodeproj/xcshareddata/xcschemes/Phoenix.xcscheme"
fi

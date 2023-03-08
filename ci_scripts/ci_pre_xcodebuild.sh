#!/bin/sh

#  ci_pre_xcodebuild.sh
#  Phoenix

if [[ $CI_WORKFLOW == "GitHub Release" ]];
then
    # Replace entitlements to disable Sandbox for the GitHub Release
    cp -fr Phoenix/Phoenix.entitlements Phoenix/PhoenixRelease.entitlements
    "./EnableGitHubReleaseTarget.swift" "../Phoenix.xcodeproj/xcshareddata/xcschemes/Phoenix.xcscheme"
fi

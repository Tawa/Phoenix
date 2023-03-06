#!/bin/sh

#  ci_pre_xcodebuild.sh
#  Phoenix
#
#  Created by Tawa Nicolas on 06.03.23.
#  

if [[ $CI_WORKFLOW == "GitHub Release" ]];
then
    # Replace entitlements to disable Sandbox for the GitHub Release
    cp -fr Phoenix/Phoenix.entitlements Phoenix/PhoenixRelease.entitlements
fi

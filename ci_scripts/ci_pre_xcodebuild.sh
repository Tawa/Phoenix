#!/bin/sh

#  ci_pre_xcodebuild.sh
#  Phoenix
#
#  Created by Tawa Nicolas on 05.03.23.
#  

if [[ $CI_WORKFLOW == "PR Unit Tests" ]];
then
    echo "Validating \"Package.swift\" files"
    ./PhoenixProjectValidator ../Modules/Modules.ash ../Modules
else
    echo "ci_pre_xcodebuild No Actions"
fi

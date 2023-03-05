#!/bin/sh

#  ci_pre_xcodebuild.sh
#  Phoenix
#
#  Created by Tawa Nicolas on 05.03.23.
#  

#if [[ $CI_WORKFLOW == "PR Unit Tests" ]];
#then
    echo "Validating \"Package.swift\" files"
    cmd="./ProjectValidatorCommand ../Modules/Modules.ash ../Modules"
    $cmd
    status=$?
    [ $status -eq 0 ] && echo "$cmd command was successful" || echo "$cmd failed"
    exit $status
#else
#    echo "ci_pre_xcodebuild No Actions"
#fi

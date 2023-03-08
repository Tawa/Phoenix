#!/bin/sh

#  ci_pre_xcodebuild.sh
#  Phoenix

if [[ $CI_WORKFLOW == "PR Unit Tests" ]];
then
    echo "Validating \"Package.swift\" files"
    cmd="./ProjectValidatorCommand ../Modules/Modules.ash ../Modules"
    $cmd
    status=$?
    [ $status -eq 0 ] && echo "$cmd command was successful" || echo "$cmd failed"
    exit $status
fi

#!/bin/bash
NAME=$1
LAST_NAME=$2
IS_TRUE=$3

if [[ $IS_TRUE == "true" ]]
then
        echo "Hello $NAME $LAST_NAME . Welcome to the DevOps Club."
else
        echo "Please check the parameters"
fi

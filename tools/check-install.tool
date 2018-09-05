#!/bin/bash

COMMAND=$1

if [[ $# -eq 0 ]] ; then
    echo 'Must specify command'
    exit 1
fi

if [ -x "$(command -v $COMMAND)" ]; then
    echo "$COMMAND is installed"
    exit 0
else
    echo "$COMMAND is not installed"
    exit 1
fi
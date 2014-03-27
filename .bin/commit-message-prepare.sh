#!/bin/bash

# Initialize variables
CURRENT_STORY_ID=`git rev-parse --abbrev-ref HEAD | grep -oEi '[0-9]+'`
FILTERED_BRANCH_NAME=`git rev-parse --abbrev-ref HEAD | grep -oEi '^.*-pt[0-9]+$'`

# Checking whether we were able to extract PivotalTracker story ID from branch name or not.
if [ ${FILTERED_BRANCH_NAME} ] && [ ${CURRENT_STORY_ID} ]; then

        echo "[#$CURRENT_STORY_ID]" >> "$1"
fi
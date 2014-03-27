#!/bin/bash

# Retrieve path to the folder where script is stored.
SCRIPT_FOLDER_PATH=$( cd "$( dirname "$0" )" && pwd )

cp "${SCRIPT_FOLDER_PATH}/commit-message-prepare.sh" "${SCRIPT_FOLDER_PATH}/../.git/hooks/prepare-commit-msg"
chmod +x "${SCRIPT_FOLDER_PATH}/../.git/hooks/prepare-commit-msg"
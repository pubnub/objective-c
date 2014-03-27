#!/bin/bash

cp "commit-message-prepare.sh" "../.git/hooks/prepare-commit-msg"
chmod +x "../.git/hooks/prepare-commit-msg"
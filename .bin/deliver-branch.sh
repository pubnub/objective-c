#!/bin/bash

# Retrieve current script folder
SCRIPT_FOLDER_PATH=$( cd "$( dirname "$0" )" && pwd )

# Specify PubNub library folder name (where main library classes is stored).
LIBRARY_SOURCE_FOLDER_NAME="PubNub"

# Specify PubNub library source from which source code should be copied to demo and test projects.
LIBRARY_SOURCE_PATH="$SCRIPT_FOLDER_PATH/../iOS/iPadDemoApp/pubnub/libs/$LIBRARY_SOURCE_FOLDER_NAME"

# Retrieve current commit SHA 
PRE_COMMIT_SHA=$( git rev-parse HEAD )

# Retrieve current branch name
CURRENT_BRANCH_NAME=$( git symbolic-ref --short HEAD )

# Try to commit any changes in the branch
git commit -a

# Retrieve current commit SHA value after attempt to store changes
POST_COMMIT_SHA=$( git rev-parse HEAD )

# Check whether there PRE- and POST-commit SHA changed or everything remain the same.
if [ "$PRE_COMMIT_SHA" != "$POST_COMMIT_SHA" ]; then

	# Update branch name in PubNub core file
	sed -E -i "" "s/(kPNCodebaseBranch = @\")[A-Za-z0-9-]*(\")/\1$CURRENT_BRANCH_NAME\2/g" "$LIBRARY_SOURCE_PATH/Core/PubNub.m"

	# Update commit SHA value in PubNub core file
	sed -E -i "" "s/(kPNCodeCommitIdentifier = @\")[A-Za-z0-9-]*(\")/\1$POST_COMMIT_SHA\2/g" "$LIBRARY_SOURCE_PATH/Core/PubNub.m"
	
	# Commit updated PubNub client git source information
	git commit -a -m "* updated information about source code base branch and commit SHA"

	# Send changes to remote origin
	git push --force --set-upstream origin "$CURRENT_BRANCH_NAME"

	echo "[DELIVER::SUCCESS] $CURRENT_BRANCH_NAME has been delivered and code base information has been updated"
fi
if [ "$PRE_COMMIT_SHA" == "$POST_COMMIT_SHA" ]; then
	
	echo "[DELIVER::FAILED] Looks like there is nothing to commit or some kind of error doesn't allow to. Check git output for more information."
fi


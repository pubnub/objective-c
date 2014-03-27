#!/bin/bash

# Store reference on current folder from which script has been called
CURRENT_FOLDER=$(pwd)

# Retrieve path to the folder where script is stored.
SCRIPT_FOLDER_PATH=$( cd "$( dirname "$0" )" && pwd )
cd "$SCRIPT_FOLDER_PATH/.."

# Specify PubNub library folder name (where main library classes is stored).
LIBRARY_SOURCE_FOLDER_NAME="PubNub"

# Specify search root directory where script will try to find project into which library should be copied.
TARGET_SEARCH_ROOT="."

# Specify PubNub library source from which source code should be copied to demo and test projects.
LIBRARY_SOURCE_PATH="$TARGET_SEARCH_ROOT/iOS/iPadDemoApp/pubnub/libs/$LIBRARY_SOURCE_FOLDER_NAME"
IS_LIBRARY_SOURCE_AT_SEARCH_PATH=$((`find $TARGET_SEARCH_ROOT -name $LIBRARY_SOURCE_FOLDER_NAME -type d | grep $LIBRARY_SOURCE_PATH | wc -l` + 0))

# Specify how much places
TOTAL_DESTINATIONS_COUNT=$((`find $TARGET_SEARCH_ROOT -name $LIBRARY_SOURCE_FOLDER_NAME -type d -print | wc -l` - $IS_LIBRARY_SOURCE_AT_SEARCH_PATH))
PROCESSED_DESTINATIONS_COUNT=0
PROGRESS="   0%"

function updateProgress {
    
    BAR_WIDTH=50
    FILLED_PROGRESS_LENGTH=0
    UNFILLED_PROGRESS_LENGTH=0
    FILLED_PROGRESS=""
    UNFILLED_PROGRESS=""
    SPACES="   "
    PROGRESS_IN_PERCENTS=$(printf "%.0f" "$(echo "100*$PROCESSED_DESTINATIONS_COUNT/$TOTAL_DESTINATIONS_COUNT" | bc -l)")
    if [[ $PROGRESS_IN_PERCENTS -ge 10 ]]; then
        SPACES="  "
    fi
    if [[ $PROGRESS_IN_PERCENTS -eq 100 ]]; then
        SPACES=" "
    fi
    FILLED_PROGRESS_LENGTH=$(printf "%.0f" "$(echo "$PROGRESS_IN_PERCENTS/2" | bc -l)")
    UNFILLED_PROGRESS_LENGTH=$(($BAR_WIDTH-$FILLED_PROGRESS_LENGTH))
    printf -v FILLED_PROGRESS '%*s' "$FILLED_PROGRESS_LENGTH"
    printf -v UNFILLED_PROGRESS '%*s' "$UNFILLED_PROGRESS_LENGTH"
    PROGRESS=$SPACES$PROGRESS_IN_PERCENTS"% ["${FILLED_PROGRESS// /=}${UNFILLED_PROGRESS// /-}"]"
}

CURRENT_FOLDER=$(pwd)
WORKING_FOLDER=$CURRENT_FOLDER/$LIBRARY_SOURCE_PATH

echo ""
echo "Copying PubNub library source code from $LIBRARY_SOURCE_PATH to demo projects and tests:"
for TARGET_FOLDER in `find $TARGET_SEARCH_ROOT -name $LIBRARY_SOURCE_FOLDER_NAME -type d -print`
do
    if [ "$TARGET_FOLDER" != "$LIBRARY_SOURCE_PATH" ]; then
        cd "$WORKING_FOLDER" && cp -r . "$CURRENT_FOLDER/$TARGET_FOLDER"
        PROCESSED_DESTINATIONS_COUNT=$(($PROCESSED_DESTINATIONS_COUNT + 1))
        updateProgress
        echo -ne "$PROGRESS Target: $TARGET_FOLDER\033[K\r"
        # sleep 0.5
    fi
done
cd "$CURRENT_FOLDER"
echo -ne "PubNub library copied into $TOTAL_DESTINATIONS_COUNT folders.\033[K\r"
echo ""
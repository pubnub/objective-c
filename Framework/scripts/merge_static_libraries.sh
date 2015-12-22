#!/bin/sh

set -e

if [[ ${BUILDING_UNIVERSAL_FRAMEWORK:=0} == 0 ]]; then

    FRAMEWORK_BINARIES_PATH="${SRCROOT}/Products/PubNub.framework"
    xcrun libtool -static -o "${FRAMEWORK_BINARIES_PATH}/PubNub-merged" "${FRAMEWORK_BINARIES_PATH}/PubNub" "${FRAMEWORK_BINARIES_PATH}/CocoaLumberjack"
    rm "${FRAMEWORK_BINARIES_PATH}/PubNub"
    rm "${FRAMEWORK_BINARIES_PATH}/CocoaLumberjack"
    mv "${FRAMEWORK_BINARIES_PATH}/PubNub-merged" "${FRAMEWORK_BINARIES_PATH}/PubNub"
fi
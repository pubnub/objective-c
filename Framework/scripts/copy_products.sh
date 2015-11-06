#!/bin/sh

set -e

# Extracting platform name (simulator or device)
if [[ ${BUILDING_UNIVERSAL_FRAMEWORK:=0} == 0 ]]; then

    PRODUCTS_PATH="${SRCROOT}/Products"
    BUILT_FRAMEWORKS=("CocoaLumberjack" "PubNub")
    if [[ $PLATFORM_NAME =~ (macosx) ]]; then
        ARTIFACTS_PATH="${BUILD_DIR}/${CONFIGURATION}"
    else
        ARTIFACTS_PATH="${BUILD_DIR}/${CONFIGURATION}-${PLATFORM_NAME}"
    fi

    # Clean up from previous builds
    if [[ -d "${PRODUCTS_PATH}" ]]; then
        rm -R "${PRODUCTS_PATH}"
    fi

    mkdir -p "${PRODUCTS_PATH}"

    # Copy frameworks to products folder.
    for frameworkName in "${BUILT_FRAMEWORKS[@]}"
    do
        FRAMEWORK_BUNDLE_NAME="${frameworkName}.framework"
        FRAMEWORK_BUILD_PATH="${ARTIFACTS_PATH}/${FRAMEWORK_BUNDLE_NAME}"
        cp -RP "${FRAMEWORK_BUILD_PATH}" "${PRODUCTS_PATH}/${FRAMEWORK_BUNDLE_NAME}"
    done
fi

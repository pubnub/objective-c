#!/bin/sh

set -e

FRAMEWORKS_BUILD_CONFIGURATION="Release"
FRAMEWORKS_PATH="${BUILD_DIR}/Frameworks"
FRAMEWORKS_TARGET_ARCHITECTURES='i386 x86_64'
[[ "${TARGET_NAME}" =~ (iOS|watchOS|Fabric) ]] && FRAMEWORK_NAME="PubNub (${BASH_REMATCH[1]})"
PRODUCTS_PATH="${SRCROOT}/Products"

# Clean up from previous builds
if [[ -d "${FRAMEWORKS_PATH}" ]]; then
    rm -R "${FRAMEWORKS_PATH}"
fi
if [[ -d "${PRODUCTS_PATH}" ]]; then
    rm -R "${PRODUCTS_PATH}"
fi

PLATFORMS=($SUPPORTED_PLATFORMS)
# Compile framework for all required platforms.
for sdk in "${PLATFORMS[@]}"
do
    echo "Building ${FRAMEWORK_NAME} for ${sdk}..."
    if [[ $sdk =~ (simulator) ]]; then
        [[ "${sdk}" =~ (iphone) ]] && FRAMEWORKS_TARGET_ARCHITECTURES="i386 x86_64"
        [[ "${sdk}" =~ (watch) ]] && FRAMEWORKS_TARGET_ARCHITECTURES="i386"
    else
        [[ "${sdk}" =~ (iphone) ]] && FRAMEWORKS_TARGET_ARCHITECTURES="armv7 armv7s arm64"
        [[ "${sdk}" =~ (watch) ]] && FRAMEWORKS_TARGET_ARCHITECTURES="armv7k"
    fi

xcrun --no-cache xcodebuild -project "${PROJECT_FILE_PATH}" -target "${FRAMEWORK_NAME}" -configuration "${FRAMEWORKS_BUILD_CONFIGURATION}" -sdk "${sdk}" BUILD_DIR="${BUILD_DIR}" OBJROOT="${OBJROOT}" BUILD_ROOT="${BUILD_ROOT}" SYMROOT="${SYMROOT}" ARCHS="${FRAMEWORKS_TARGET_ARCHITECTURES}" VALID_ARCHS="${FRAMEWORKS_TARGET_ARCHITECTURES}"  ONLY_ACTIVE_ARCH=NO $ACTION > /dev/null
    echo "Built ${FRAMEWORK_NAME} for ${sdk}"
done

# Building universal binary
echo "Building universal framework..."
echo "Artifacts stored in: ${BUILD_DIR}"
BUILT_FRAMEWORKS=("CocoaLumberjack" "PubNub")
for sdk in "${PLATFORMS[@]}"
do
    if [[ $sdk =~ (simulator) ]]; then
        SIMULATOR_ARTIFACTS_PATH="${BUILD_DIR}/${FRAMEWORKS_BUILD_CONFIGURATION}-${sdk}"
    else
        OS_ARTIFACTS_PATH="${BUILD_DIR}/${FRAMEWORKS_BUILD_CONFIGURATION}-${sdk}"
    fi
done

## Prepare folders
mkdir -p "${FRAMEWORKS_PATH}"
mkdir -p "${PRODUCTS_PATH}"

# Copy ARM binaries and build "fat" binary for each built framework.
for frameworkName in "${BUILT_FRAMEWORKS[@]}"
do
    FRAMEWORK_BUNDLE_NAME="${frameworkName}.framework"
    FRAMEWORK_ARM_BUILD_PATH="${OS_ARTIFACTS_PATH}/${FRAMEWORK_BUNDLE_NAME}"
    FRAMEWORK_SIM_BUILD_PATH="${SIMULATOR_ARTIFACTS_PATH}/${FRAMEWORK_BUNDLE_NAME}"
    FRAMEWORK_DESTINATION_PATH="${FRAMEWORKS_PATH}/${FRAMEWORK_BUNDLE_NAME}"
    cp -r "${FRAMEWORK_ARM_BUILD_PATH}" "${FRAMEWORK_DESTINATION_PATH}"
    xcrun lipo -create "${FRAMEWORK_DESTINATION_PATH}/${frameworkName}" "${FRAMEWORK_SIM_BUILD_PATH}/${frameworkName}" -output "${FRAMEWORK_DESTINATION_PATH}/${frameworkName}"
    cp -r "${FRAMEWORKS_PATH}/${FRAMEWORK_BUNDLE_NAME}" "${PRODUCTS_PATH}/${FRAMEWORK_BUNDLE_NAME}"
done
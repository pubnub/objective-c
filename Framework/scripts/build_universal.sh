#!/bin/sh

set -e

FRAMEWORKS_BUILD_CONFIGURATION="Release"
FRAMEWORKS_PATH="${BUILD_DIR}/Frameworks"
FRAMEWORKS_TARGET_ARCHITECTURES='i386 x86_64'
PNENABLE_BITCODE="YES"
[[ "${TARGET_NAME}" =~ (iOS|tvOS|watchOS|Fabric) ]] && FRAMEWORK_NAME="PubNub (${BASH_REMATCH[1]})"
[[ ${BUILDING_STATIC_FRAMEWORK:=0} == 1 ]] && FRAMEWORK_NAME="Static ${FRAMEWORK_NAME}"

PRODUCTS_PATH="${SRCROOT}/Products"

# Clean up from previous builds
[[ -d "${FRAMEWORKS_PATH}" ]] && rm -R "${FRAMEWORKS_PATH}"
[[ -d "${PRODUCTS_PATH}" ]] && rm -R "${PRODUCTS_PATH}"

PLATFORMS=($SUPPORTED_PLATFORMS)

# Compile framework for all required platforms.
for sdk in "${PLATFORMS[@]}"
do
    echo "Building ${FRAMEWORK_NAME} for ${sdk}..."
    if [[ $sdk =~ (simulator) ]]; then
        [[ "${sdk}" =~ (iphone) ]] && FRAMEWORKS_TARGET_ARCHITECTURES="i386 x86_64"
        [[ "${sdk}" =~ (appletv) ]] && FRAMEWORKS_TARGET_ARCHITECTURES="x86_64"
        [[ "${sdk}" =~ (watch) ]] && FRAMEWORKS_TARGET_ARCHITECTURES="i386"
    else
        [[ "${sdk}" =~ (iphone) ]] && FRAMEWORKS_TARGET_ARCHITECTURES="armv7 armv7s arm64"
        [[ "${sdk}" =~ (appletv) ]] && FRAMEWORKS_TARGET_ARCHITECTURES="arm64"
        [[ "${sdk}" =~ (watch) ]] && FRAMEWORKS_TARGET_ARCHITECTURES="armv7k"
    fi

echo "xcrun --no-cache xcodebuild -project \"${PROJECT_FILE_PATH}\" -target \"${FRAMEWORK_NAME}\" -configuration \"${FRAMEWORKS_BUILD_CONFIGURATION}\" -sdk \"${sdk}\" BUILD_DIR=\"${BUILD_DIR}\" OBJROOT=\"${OBJROOT}/DependantBuilds\" BUILD_ROOT=\"${BUILD_ROOT}\" SYMROOT=\"${SYMROOT}\" ARCHS=\"${FRAMEWORKS_TARGET_ARCHITECTURES}\" VALID_ARCHS=\"${FRAMEWORKS_TARGET_ARCHITECTURES}\" ONLY_ACTIVE_ARCH=NO ENABLE_BITCODE=${PNENABLE_BITCODE} $ACTION > /dev/null"
    xcrun --no-cache xcodebuild -project "${PROJECT_FILE_PATH}" -target "${FRAMEWORK_NAME}" -configuration "${FRAMEWORKS_BUILD_CONFIGURATION}" -sdk "${sdk}" BUILD_DIR="${BUILD_DIR}" OBJROOT="${OBJROOT}/DependantBuilds" BUILD_ROOT="${BUILD_ROOT}" SYMROOT="${SYMROOT}" ARCHS="${FRAMEWORKS_TARGET_ARCHITECTURES}" VALID_ARCHS="${FRAMEWORKS_TARGET_ARCHITECTURES}" ONLY_ACTIVE_ARCH=NO ENABLE_BITCODE=$PNENABLE_BITCODE $ACTION > /dev/null
    echo "Built ${FRAMEWORK_NAME} for ${sdk}"
done

# Building universal binary
echo "Building universal framework..."
echo "Artifacts stored in: ${BUILD_DIR}"
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

# Copy ARM binaries and build "fat" binary.
if [[ ${BUILDING_STATIC_FRAMEWORK:=0} == 0 ]]; then
    FRAMEWORK_BUNDLE_NAME="PubNub.framework"
    FRAMEWORK_ARM_BUILD_PATH="${OS_ARTIFACTS_PATH}/${FRAMEWORK_BUNDLE_NAME}"
    FRAMEWORK_SIM_BUILD_PATH="${SIMULATOR_ARTIFACTS_PATH}/${FRAMEWORK_BUNDLE_NAME}"
    FRAMEWORK_DESTINATION_PATH="${FRAMEWORKS_PATH}/${FRAMEWORK_BUNDLE_NAME}"
else
    FRAMEWORK_BUNDLE_NAME="PubNub.framework"
    FRAMEWORK_ARM_BUILD_PATH="${OS_ARTIFACTS_PATH}"
    FRAMEWORK_SIM_BUILD_PATH="${SIMULATOR_ARTIFACTS_PATH}"
    FRAMEWORK_DESTINATION_PATH="${FRAMEWORKS_PATH}/${FRAMEWORK_BUNDLE_NAME}"
fi

FRAMEWORK_PRODUCTS_PATH="${PRODUCTS_PATH}/${FRAMEWORK_BUNDLE_NAME}"
if [[ ${BUILDING_STATIC_FRAMEWORK:=0} == 0 ]]; then
    cp -RP "${FRAMEWORK_ARM_BUILD_PATH}" "${FRAMEWORK_DESTINATION_PATH}"
    xcrun lipo -create "${FRAMEWORK_DESTINATION_PATH}/PubNub" "${FRAMEWORK_SIM_BUILD_PATH}/PubNub" -output "${FRAMEWORK_DESTINATION_PATH}/PubNub"
else
    [[ ! -d "${FRAMEWORK_PRODUCTS_PATH}" ]] && mkdir -p "${FRAMEWORK_PRODUCTS_PATH}"
    if [[ ! -d "${FRAMEWORK_PRODUCTS_PATH}/Headers" ]]; then
        cp -RP "${FRAMEWORK_ARM_BUILD_PATH}/Headers" "${FRAMEWORK_PRODUCTS_PATH}/Headers"
        find "${FRAMEWORK_ARM_BUILD_PATH}/" -type f -name 'PubNub*-Info.plist' -exec cp '{}' "${FRAMEWORK_PRODUCTS_PATH}/Info.plist" ';'
    fi
    cp "${FRAMEWORK_ARM_BUILD_PATH}/PubNub.a" "${FRAMEWORK_PRODUCTS_PATH}/PubNub.a"

    xcrun lipo -create "${FRAMEWORK_PRODUCTS_PATH}/PubNub.a" "${FRAMEWORK_SIM_BUILD_PATH}/PubNub.a" -output "${FRAMEWORK_PRODUCTS_PATH}/PubNub"
    rm "${FRAMEWORK_PRODUCTS_PATH}/PubNub.a"
fi

if [[ ${BUILDING_STATIC_FRAMEWORK:=0} == 0 ]]; then
    cp -RP "${FRAMEWORKS_PATH}/${FRAMEWORK_BUNDLE_NAME}" "${FRAMEWORK_PRODUCTS_PATH}"
fi

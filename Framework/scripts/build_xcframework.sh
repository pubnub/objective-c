#!/bin/sh
set -e

# Module map override function
write_module_map () {
    cat >$1 <<EOF
framework module PubNub {
  umbrella header "PubNub.h"

  link "z"
  export *
  module * { export * }

  explicit module Swift {
    header "PubNub-Swift.h"
    requires objc
  }
}
EOF
}

BUILD_WITH_CATALYST_SUPPORT=0

if [[ "$TARGET_NAME" =~ (Catalyst) ]]; then
    echo "Building Catalyst XCFramework with device / simulator / Catalyst slices"
    TARGET_NAME="XCFramework (iOS)"
    BUILD_WITH_CATALYST_SUPPORT=1
else
    echo "Building regular XCFramework with device / simulator slices"
fi

if [[ "$SUPPORTED_PLATFORMS" =~ (iphone) ]]; then
    DEVICE_SDK="iphoneos"
    SIMULATOR_SDK="iphonesimulator"
    SIMULATOR_TARGET_ARCHITECTURES="x86_64 arm64"
elif [[ "$SUPPORTED_PLATFORMS" =~ (appletv) ]]; then
    DEVICE_SDK="appletvos"
    SIMULATOR_SDK="appletvsimulator"
    SIMULATOR_TARGET_ARCHITECTURES="x86_64 arm64"
elif [[ "$SUPPORTED_PLATFORMS" =~ (watch) ]]; then
    DEVICE_SDK="watchos"
    SIMULATOR_SDK="watchsimulator"
    SIMULATOR_TARGET_ARCHITECTURES="x86_64 arm64"
fi


SCHEME_NAME="${TARGET_NAME/XCFramework/Framework}"
ARCHIVES_PATH="$(mktemp -d)"
PRODUCTS_PATH="${SRCROOT}/Products"
DERIVED_DATA_PATH="$ARCHIVES_PATH/DerivedData"
MACOS_ARCHIVE_PATH="$ARCHIVES_PATH/macos.xcarchive"
DEVICE_ARCHIVE_PATH="$ARCHIVES_PATH/device.xcarchive"
SIMULATOR_ARCHIVE_PATH="$ARCHIVES_PATH/simulator.xcarchive"
MACOS_FRAMEWORK_PATH="${MACOS_ARCHIVE_PATH}/Products/Library/Frameworks/PubNub.framework"
DEVICE_FRAMEWORK_PATH="${DEVICE_ARCHIVE_PATH}/Products/Library/Frameworks/PubNub.framework"
SIMULATOR_FRAMEWORK_PATH="${SIMULATOR_ARCHIVE_PATH}/Products/Library/Frameworks/PubNub.framework"
XCFRAMEWORK_PATH="$PRODUCTS_PATH/PubNub.xcframework"
echo "[XCFramework] Archives path: $ARCHIVES_PATH"

# Clean up framework build products repository.
[[ -d "$PRODUCTS_PATH" ]] && rm -R "$PRODUCTS_PATH"
mkdir -p "$PRODUCTS_PATH"

# Build framework for general device
xcodebuild archive \
    -scheme "$SCHEME_NAME" \
    -sdk "$DEVICE_SDK" \
    -archivePath "$DEVICE_ARCHIVE_PATH" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SWIFT_EMIT_MODULE_INTERFACE=YES \
    ONLY_ACTIVE_ARCH=NO \
    SUPPORTS_MACCATALYST=NO \
    clean
    
echo "[XCFramework] Archive has been created for '$DEVICE_SDK': $DEVICE_ARCHIVE_PATH"

# Build framework for simulator
xcodebuild archive \
    -scheme "$SCHEME_NAME" \
    -sdk "$SIMULATOR_SDK" \
    -archivePath "$SIMULATOR_ARCHIVE_PATH" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    ARCHS="$SIMULATOR_TARGET_ARCHITECTURES" \
    VALID_ARCHS="$SIMULATOR_TARGET_ARCHITECTURES" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SWIFT_EMIT_MODULE_INTERFACE=YES \
    ONLY_ACTIVE_ARCH=NO \
    SUPPORTS_MACCATALYST=NO \
    clean

echo "[XCFramework] Archive has been created for '$SIMULATOR_SDK': $SIMULATOR_ARCHIVE_PATH"

# Build iOS for macOS framework if Catalyst support required.
if [ "$BUILD_WITH_CATALYST_SUPPORT" == 1 ]; then

    # Destination matching reads SUPPORTS_MACCATALYST from the environment, not from the command line settings. Without
    # it exported (when script is started from Xcode with other destination) xcodebuild reports 'Found no destinations
    # which allow the archive action'.
    export SUPPORTS_MACCATALYST=YES

    xcodebuild archive \
        -scheme "$SCHEME_NAME" \
        -sdk macosx \
        -archivePath "$MACOS_ARCHIVE_PATH" \
        -derivedDataPath "$DERIVED_DATA_PATH" \
        -destination 'platform=macOS,arch=x86_64,variant=Mac Catalyst' \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        SWIFT_EMIT_MODULE_INTERFACE=YES \
        ONLY_ACTIVE_ARCH=NO \
        SUPPORTS_MACCATALYST=YES \
        clean
        
    echo "[XCFramework] Archive has been created for 'macosx': $MACOS_ARCHIVE_PATH"
fi

# Update modules map
write_module_map "$DEVICE_FRAMEWORK_PATH/Modules/module.modulemap"
write_module_map "$SIMULATOR_FRAMEWORK_PATH/Modules/module.modulemap"

if [ "$BUILD_WITH_CATALYST_SUPPORT" == 0 ]; then
    # Pack built device / simulator slices into XCFramework
    xcodebuild -create-xcframework \
        -framework "$DEVICE_FRAMEWORK_PATH" \
        -framework "$SIMULATOR_FRAMEWORK_PATH" \
        -output "$XCFRAMEWORK_PATH"
else
    write_module_map "$MACOS_FRAMEWORK_PATH/Modules/module.modulemap"
            
    echo "[XCFramework] Adding frameworks to XCFramework..."
    
    # Pack built device / simulator / Catalyst slices into XCFramework
    xcodebuild -create-xcframework \
        -framework "$DEVICE_FRAMEWORK_PATH" \
        -framework "$SIMULATOR_FRAMEWORK_PATH" \
        -framework "$MACOS_FRAMEWORK_PATH" \
        -output "$XCFRAMEWORK_PATH"
            
    echo "[XCFramework] Frameworks added to XCFramework: $XCFRAMEWORK_PATH"
fi

rm -rf "$ARCHIVES_PATH"

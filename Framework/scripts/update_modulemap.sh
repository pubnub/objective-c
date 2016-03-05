#!/bin/sh

set -e

if [[ ${BUILDING_UNIVERSAL_FRAMEWORK:=0} == 0 ]]; then

    PRODUCTS_PATH="${SRCROOT}/Products"
    BUILT_FRAMEWORKS=("CocoaLumberjack" "PubNub")

    # Add/modify module map for each of built frameworks/libraries.
    for frameworkName in "${BUILT_FRAMEWORKS[@]}"
    do
        if [[ ${BUILDING_STATIC_FRAMEWORK:=0} == 0 ]]; then
            MODULE_NAME="${frameworkName}"
            FRAMEWORK_BUNDLE_NAME="${frameworkName}.framework"
        else
            MODULE_NAME="PubNub"
            FRAMEWORK_BUNDLE_NAME="PubNub.framework"
        fi

        if [[ $PLATFORM_NAME =~ (macosx) ]]; then
            FRAMEWORK_MODULES_PATH="${PRODUCTS_PATH}/${FRAMEWORK_BUNDLE_NAME}/Versions/A/Modules"
        else
            FRAMEWORK_MODULES_PATH="${PRODUCTS_PATH}/${FRAMEWORK_BUNDLE_NAME}/Modules"
        fi
        MODULEMAP_PATH="${FRAMEWORK_MODULES_PATH}/module.modulemap"

        if [ ! -f "${MODULEMAP_PATH}" ] || [ ${BUILDING_STATIC_FRAMEWORK:=0} == 0 ] ; then
            [[ ! -d "${FRAMEWORK_MODULES_PATH}" ]] && mkdir -p "${FRAMEWORK_MODULES_PATH}"

            cat >"${MODULEMAP_PATH}" <<EOF
framework module $MODULE_NAME {
  umbrella header "${MODULE_NAME}.h"

EOF
            if [[ $FRAMEWORK_BUNDLE_NAME =~ (PubNub) ]]; then
                cat >>"${MODULEMAP_PATH}" <<EOF
  link "z"

EOF
            fi
            cat >>"${MODULEMAP_PATH}" <<EOF
  export *
  module * { export * }
}
EOF
        fi
done
fi

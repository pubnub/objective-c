#!/bin/sh

set -e

if [[ ${BUILDING_UNIVERSAL_FRAMEWORK:=0} == 0 ]]; then

    write_module_map () {
        cat >$1 <<EOF
framework module PubNub {
  umbrella header "PubNub.h"

  link "z"
  export *
  module * { export * }
}
EOF
    }

    ORIGINAL_MODULEMAP_PATH="${TARGET_TEMP_DIR}/module.modulemap"
    [[ -f "${ORIGINAL_MODULEMAP_PATH}" ]] && rm "${ORIGINAL_MODULEMAP_PATH}"
    write_module_map "${ORIGINAL_MODULEMAP_PATH}"

    if [[ ${CARTHAGE:=0} == 0 ]]; then
        PRODUCTS_PATH="${SRCROOT}/Products"
        if [[ $PLATFORM_NAME =~ (macosx) ]]; then
            FRAMEWORK_MODULES_PATH="${PRODUCTS_PATH}/PubNub.framework/Versions/A/Modules"
        else
            FRAMEWORK_MODULES_PATH="${PRODUCTS_PATH}/PubNub.framework/Modules"
        fi
        MODULEMAP_PATH="${FRAMEWORK_MODULES_PATH}/module.modulemap"
        if [ ! -f "${MODULEMAP_PATH}" ] || [ ${BUILDING_STATIC_FRAMEWORK:=0} == 0 ] ; then
            [[ ! -d "${FRAMEWORK_MODULES_PATH}" ]] && mkdir -p "${FRAMEWORK_MODULES_PATH}"
            cp "${ORIGINAL_MODULEMAP_PATH}" "${MODULEMAP_PATH}"
        fi
    fi
fi

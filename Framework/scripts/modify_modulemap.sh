#!/bin/sh

set -e

# Declare path to framework's module map containing folder.
MODULEMAP_FOLDER_PATH="${SRCROOT}/Products/PubNub.framework/Modules"

# Check whether module map folder exists or not.
if [[ -d "${MODULEMAP_FOLDER_PATH}" ]]; then

    MODULEMAP_PATH="${MODULEMAP_FOLDER_PATH}/module.modulemap"
    cat >"${MODULEMAP_PATH}" <<EOF
framework module PubNub {
  umbrella header "PubNub.h"

  link "z"

  export *
  module * { export * }
}
EOF
fi

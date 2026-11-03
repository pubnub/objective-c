#!/usr/bin/env bash
set -e

# Git root directory.
GIT_ROOT_PATH="$(git rev-parse --show-toplevel)"

# Swift Package Manager requires public headers to be placed in a single directory. Regenerate `PubNub/include` so
# the release always ships links to the actual list of headers.
bash "$GIT_ROOT_PATH/Framework/scripts/export_for_spm.sh"

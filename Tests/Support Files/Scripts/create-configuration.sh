#!/usr/bin/env bash
set -e


BRCF="\033[1;31m"



# Git root directory (initially call is done from repository on which Travis started job, so it appears to be
# private / source repository),
GIT_ROOT_PATH="$(git rev-parse --show-toplevel)"
CONFIGURATION_PATH="$GIT_ROOT_PATH/Tests/Support Files/tests-configuration.json"


if [[ -z $TESTS_SUBSCRIBE_KEY ]]; then
  echo -e "${BRCF}Regular subscribe key for integration tests is missing (TESTS_SUBSCRIBE_KEY)${CF}"
  exit 1
fi

if [[ -z $TESTS_PUBLISH_KEY ]]; then
  echo -e "${BRCF}Regular publish key for integration tests is missing (TESTS_PUBLISH_KEY)${CF}"
  exit 1
fi

if [[ -z $TESTS_PAM_SUBSCRIBE_KEY ]]; then
  echo -e "${BRCF}PAM-enabled subscribe key for integration tests is missing 
(TESTS_PAM_SUBSCRIBE_KEY)${CF}"
  exit 1
fi

if [[ -z $TESTS_PAM_PUBLISH_KEY ]]; then
  echo -e "${BRCF}PAM-enabled publish key for integration tests is missing 
(TESTS_PAM_PUBLISH_KEY)${CF}"
  exit 1
fi

# Store file with tests configuration.
echo "{
  \"keys\": {
    \"publish\": \"$TESTS_PUBLISH_KEY\",
    \"subscribe\": \"$TESTS_SUBSCRIBE_KEY\",
    \"publish-pam\": \"$TESTS_PAM_PUBLISH_KEY\",
    \"subscribe-pam\": \"$TESTS_PAM_SUBSCRIBE_KEY\"
  }
}" > "$CONFIGURATION_PATH"
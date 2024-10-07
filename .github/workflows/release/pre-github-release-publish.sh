#!/usr/bin/env bash
set -e


CF="\033[0m"
DF="\033[2m"
BRCF="\033[1;31m"
GCF="\033[32m"
LCCF="\033[96m"


# Git root directory (initially call is done from repository on which Travis started job, so it appears to be
# private / source repository),
GIT_ROOT_PATH="$(git rev-parse --show-toplevel)"
FRAMEWORKS_BUILD_PATH="$GIT_ROOT_PATH/Framework/Products"
DEPLOYMENT_RELEASE_ARTIFACTS="$GIT_ROOT_PATH/.github/.release/artifacts"

build_framework() {
  local lowerCaseTarget="$(tr '[:upper:]' '[:lower:]' <<< "$1")"
  local frameworkType="xcframework"
  local schemeType="XCFramework"
  local targetSDK="macosx"
  local target="$1"

  if [[ $1 == macOS ]]; then
    frameworkType="framework"
    schemeType="Framework"
    target="OSX"
  else
    [[ $1 == Catalyst ]] && targetSDK="iphoneos"
    [[ $1 == tvOS ]] && targetSDK="appletvos"
    [[ $1 == iOS ]] && targetSDK="iphoneos"
  fi

  echo -en "${CF}${LCCF}Building $schemeType for '${DF}$1${CF}${LCCF}'...${CF} "

  if ! xcodebuild -project "$GIT_ROOT_PATH/Framework/PubNub Framework.xcodeproj" -scheme "$schemeType ($target)" -sdk "$targetSDK" clean build > /dev/null 2>&1; then
    echo -e "${CF}${BRCF}failed${CF}"

    xcodebuild \
      -project "$GIT_ROOT_PATH/Framework/PubNub Framework.xcodeproj" \
      -scheme "$schemeType ($target)" \
      -sdk "$targetSDK" \
      clean \
      build

    exit 1
  fi

  echo -e "${CF}${GCF}done${CF}"

  echo -en "${CF}${LCCF}Archiving '${DF}PubNub.$frameworkType${CF}${LCCF}'...${CF} "

  if ! tar -zcf "$DEPLOYMENT_RELEASE_ARTIFACTS/PubNub.$lowerCaseTarget.$frameworkType.tar.gz" -C "$FRAMEWORKS_BUILD_PATH/" "PubNub.$frameworkType" > /dev/null 2>&1; then
    echo -e "${CF}${BRCF}failed${CF}"

    tar -zcf \
      "$DEPLOYMENT_RELEASE_ARTIFACTS/PubNub.$lowerCaseTarget.$frameworkType.tar.gz" \
      -C "$FRAMEWORKS_BUILD_PATH/" \
      "PubNub.$frameworkType"
    exit 1
  fi

  echo -e "${CF}${GCF}done${CF}"
}

build_framework macOS
build_framework iOS
build_framework tvOS

if [[ "$(sw_vers -productVersion)" =~ ([0-9]+)\.([0-9]+) ]]; then
  if [[ ${BASH_REMATCH[1]} -eq 10 && ${BASH_REMATCH[2]} -ge 15 || ${BASH_REMATCH[1]} -gt 10 ]]; then
    build_framework Catalyst
  else
    echo -e "\n\n\n${CF}${BRCF}[${DF}deploy${CF}${BRCF}] WARNING: Framework with Catalyst support can't be build on 
macOS $(sw_vers -productVersion) (minimum 10.15 required)!\n\n\n${CF}"
  fi
fi

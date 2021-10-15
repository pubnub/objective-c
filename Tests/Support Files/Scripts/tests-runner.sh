#!/usr/bin/env bash
set -e


CF="\033[0m"
BF="\033[1m"
DF="\033[2m"
BRCF="\033[1;31m"
GCF="\033[32m"
LCCF="\033[96m"


# Git root directory (initially call is done from repository on which Travis started job, so it appears to be
# private / source repository),
GIT_ROOT_PATH="$(git rev-parse --show-toplevel)"
PODSPEC_FILE_PATH="$GIT_ROOT_PATH/PubNub.podspec"

if ! [[ -r $PODSPEC_FILE_PATH ]]; then
  echo -e "${BRCF}PubNub.podspec file not found: $PODSPEC_FILE_PATH${CF}"
  exit 1
fi


TEST_SCHEME_TYPE="Mocked Integration Tests"
[[ $2 == integration ]] && TEST_SCHEME_TYPE="Integration Tests"
[[ $2 == coverage ]] && TEST_SCHEME_TYPE="Code Coverage"
[[ $2 == contract ]] && TEST_SCHEME_TYPE="Contract Tests"

# Maximum number of tests which should run for same device type (various versions).
[[ -n $3 ]] && MAXIMUM_DESTINATIONS="$3" || MAXIMUM_DESTINATIONS=3
# List of targets on which test should be launched.
DESTINATION_NAMES=("macOS")
DESTINATIONS=()
PLATFORM="macOS"


if [[ $2 == contract && $1 != ios ]]; then
  echo -e "${BRCF}Contract testing implemented only for iOS${CF}"
  exit 1
fi

if [[ $1 != macos ]]; then
	[[ $1 == tvos ]] && PLATFORM="tvOS" || PLATFORM="iOS"
	[[ $1 == tvos ]] && DEVICE="Apple TV" || DEVICE="iPhone"
	SUPPORTED_VERSION_SPECS_KEY="spec.$1.deployment_target"
	REGEXP="${SUPPORTED_VERSION_SPECS_KEY}[[:space:]]*=[[:space:]]*'([0-9]+)\.[0-9]+'"
	VERSION_REGEXP="\((([0-9]+)\.[0-9]+(\.[0-9]+)?)\)"
	[[ $(< "$PODSPEC_FILE_PATH") =~ $REGEXP ]] && MINIMUM_MAJOR_VERSION="${BASH_REMATCH[1]}"
	MAXIMUM_MAJOR_VERSION="$MINIMUM_MAJOR_VERSION"
	AVAILABLE_DEVICES=()
	DESTINATION_NAMES=()

	# Extract list of devices which correspond to target platform and minimum version requirement
	if [[ $TRAVIS == true ]]; then
		while IFS='' read -r match; do
			# Skip destinations for iPhone paired watches
			[[ $DEVICE == iPhone ]] && [[ $match =~ Watch ]] && continue

			# Skip destination if it's OS version is lower than specified in Podspec.
			[[ $match =~ $VERSION_REGEXP ]] && [[ ${BASH_REMATCH[2]} -lt $MINIMUM_MAJOR_VERSION ]] && \
				continue

			[[ ${BASH_REMATCH[2]} -gt $MAXIMUM_MAJOR_VERSION ]] && \
			  MAXIMUM_MAJOR_VERSION="${BASH_REMATCH[2]}"

			AVAILABLE_DEVICES+=("$match")
	  done < <(echo "$(instruments -s devices)" | grep -E "^$DEVICE")
  else
		while IFS='' read -r match; do
			# Skip destinations for iPhone paired watches
			[[ $DEVICE == iPhone ]] && [[ $match =~ Watch ]] && continue

			# Skip destination if it's OS version is lower than specified in Podspec.
			[[ $match =~ $VERSION_REGEXP ]] && [[ ${BASH_REMATCH[2]} -lt $MINIMUM_MAJOR_VERSION ]] && \
				continue

			[[ ${BASH_REMATCH[2]} -gt $MAXIMUM_MAJOR_VERSION ]] && \
			  MAXIMUM_MAJOR_VERSION="${BASH_REMATCH[2]}"

			AVAILABLE_DEVICES+=("$match")
	  done < <(echo "$(xcrun xctrace list devices)" | grep -E "^$DEVICE")
  fi

	NEXT_MAJOR_VERSION=$MAXIMUM_MAJOR_VERSION

  while [[ $NEXT_MAJOR_VERSION -ge $MINIMUM_MAJOR_VERSION ]] && [[ $MAXIMUM_DESTINATIONS -gt 0 ]]; do
	  for ((deviceIdx=${#AVAILABLE_DEVICES[@]}-1; deviceIdx>=0; deviceIdx--)); do
	  	DEVICE_INFORMATION="${AVAILABLE_DEVICES[$deviceIdx]}"

	  	if [[ $DEVICE_INFORMATION =~ $VERSION_REGEXP ]] && [[ ${BASH_REMATCH[2]} == "$NEXT_MAJOR_VERSION" ]]; then
	  		OS="${BASH_REMATCH[1]}"
	  		[[ $DEVICE_INFORMATION =~ (.*)[[:space:]]\((([0-9]+)\.[0-9]+(\.[0-9]+)?)\) ]] && \
	  			DEVICE_NAME="${BASH_REMATCH[1]}"

	  		[[ -n $DEVICE_NAME && $TRAVIS != true ]] && DEVICE_NAME="$(echo "$DEVICE_NAME" | sed -e "s/ Simulator//")"
				DESTINATION_NAMES+=("$DEVICE_NAME $OS")
	  		DESTINATIONS+=("platform=$PLATFORM Simulator,name=$DEVICE_NAME,OS=$OS")
				MAXIMUM_DESTINATIONS=$((MAXIMUM_DESTINATIONS-1))
	  		break
	  	fi
		done

		NEXT_MAJOR_VERSION=$((NEXT_MAJOR_VERSION-1))
  done
else
	DESTINATIONS+=("platform=macOS")
fi

# Iterate through list of fetched destinations and run tests.
for destinationPlatformIdx in "${!DESTINATIONS[@]}"; do
  DESTINATION_PLATFORM="${DESTINATIONS[$destinationPlatformIdx]}"
  DESTINATION_NAME="${DESTINATION_NAMES[$destinationPlatformIdx]}"

  echo -e "${LCCF}Running tests for '${DF}$DESTINATION_NAME${CF}${LCCF}'...${CF}"
	xcodebuild \
		-workspace "$GIT_ROOT_PATH/Tests/PubNub Tests.xcworkspace" \
		-scheme "[$PLATFORM] $TEST_SCHEME_TYPE" \
		-destination "$DESTINATION_PLATFORM" \
		-parallel-testing-enabled NO \
		test && XCODE_BUILD_EXITCODE="${PIPESTATUS[0]}"
		# test | xcpretty --simple && XCODE_BUILD_EXITCODE="${PIPESTATUS[0]}"

		if [[ $XCODE_BUILD_EXITCODE -gt 0 ]]; then
			echo -e "${BRCF}xcodebuild exited with error code: $XCODE_BUILD_EXITCODE"
			exit $XCODE_BUILD_EXITCODE
	fi
done
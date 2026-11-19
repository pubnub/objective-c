#!/usr/bin/env bash
#
# Runs Clang Static Analyzer on the PubNub SDK target (Framework (iOS) scheme)
# and fails if the analyzer reports any warning. Pods and Tests are not analyzed.
#
# Usage: Framework/scripts/run_static_analyzer.sh [destination-sdk]  (default: iphonesimulator)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SDK="${1:-iphonesimulator}"
DERIVED="${ANALYZER_DERIVED_DATA:-$(mktemp -d)}"
LOG="$DERIVED/analyzer.log"
mkdir -p "$DERIVED"

cd "$ROOT"
EXTRA_FLAGS='$(inherited)'" -Xclang -analyzer-disable-checker -Xclang osx.cocoa.IncompatibleMethodTypes -Xclang -analyzer-disable-checker -Xclang osx.cocoa.NSError"
EXTRA_FLAGS+=" -Xclang -analyzer-checker -Xclang optin.performance.GCDAntipattern -Xclang -analyzer-checker -Xclang osx.cocoa.AutoreleaseWrite"

set +e
xcodebuild analyze \
  -project "Framework/PubNub Framework.xcodeproj" \
  -scheme "Framework (iOS)" \
  -sdk "$SDK" \
  -configuration Debug \
  -derivedDataPath "$DERIVED" \
  CODE_SIGNING_ALLOWED=NO \
  OTHER_CFLAGS="$EXTRA_FLAGS" \
  CLANG_ANALYZER_OUTPUT=text \
  CLANG_ANALYZER_NONNULL=NO \
  CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION=NO \
  CLANG_ANALYZER_SECURITY_FLOATLOOPCOUNTER=YES \
  CLANG_ANALYZER_SECURITY_INSECUREAPI_RAND=YES \
  CLANG_ANALYZER_SECURITY_INSECUREAPI_STRCPY=YES \
  >"$LOG" 2>&1
STATUS=$?
set -e

# Only report findings located in the SDK sources.
WARNINGS="$(grep -E '^/.*: warning: ' "$LOG" | grep -v '/Pods/' | sort -u || true)"

if [ $STATUS -ne 0 ]; then
  tail -n 60 "$LOG"
  echo "error: xcodebuild analyze failed (exit $STATUS). Full log: $LOG" >&2
  exit $STATUS
fi

if [ -n "$WARNINGS" ]; then
  echo "Clang Static Analyzer reported issues:" >&2
  echo "$WARNINGS" >&2
  exit 1
fi

echo "Clang Static Analyzer: no issues found."

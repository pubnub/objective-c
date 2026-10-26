#!/usr/bin/env bash
#
# Regenerates `PubNub/include/` which is used by Swift Package Manager (see `Package.swift`).
#
# SPM requires all public headers to be located in a single directory (`publicHeadersPath`). The SDK keeps headers
# next to sources, so this script mirrors them as relative symlinks into `PubNub/include/PubNub/`.
#
# Headers which get mirrored:
#   - every header reachable from `PubNub/PubNub.h` through `#import "X.h"` / `#import <PubNub/X.h>`;
#   - every header imported anywhere in framework style (`<PubNub/X.h>` / `"PubNub/X.h"`), because such
#     imports can only be resolved through the module directory.
# Header file names must be unique (the `<PubNub/X.h>` namespace is flat).
#
# Usage: Framework/scripts/export_for_spm.sh [--check]
#   --check   Don't modify anything. Exit with 1 if the committed `include/` is out of date.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SOURCES="$ROOT/PubNub"
INCLUDE="$SOURCES/include"
TARGET="$INCLUDE/PubNub"
CHECK=0
[[ "${1:-}" == "--check" ]] && CHECK=1

cd "$SOURCES"

# Relative paths of all headers (without generated `include/`).
ALL="$(find . -type f -name '*.h' -not -path './include/*' | sed 's|^\./||' | LC_ALL=C sort)"

DUPLICATES="$(echo "$ALL" | awk -F/ '{print $NF}' | sort | uniq -d)"
if [[ -n "$DUPLICATES" ]]; then
  echo "error: duplicate header file names (flat <PubNub/...> namespace requires unique names):" >&2
  echo "$DUPLICATES" >&2
  exit 1
fi

path_for() { echo "$ALL" | awk -F/ -v n="$1" '$NF == n { print; exit }'; }

PUBLIC=()
QUEUE=("PubNub.h")
SEEN=" PubNub.h "

while IFS= read -r NAME; do
  FOUND="$(path_for "$NAME")"
  if [[ -n "$FOUND" && "$SEEN" != *" $FOUND "* ]]; then
    SEEN="$SEEN$FOUND "
    QUEUE+=("$FOUND")
  fi
done < <(grep -rhoE --include='*.h' --include='*.m' '#[[:space:]]*(import|include)[[:space:]]+[<"]PubNub/[^">]+\.h' . \
         | sed -E 's|.*PubNub/||' | awk -F/ '{print $NF}' | sort -u)

while [[ ${#QUEUE[@]} -gt 0 ]]; do
  CURRENT="${QUEUE[0]}"
  QUEUE=("${QUEUE[@]:1}")
  PUBLIC+=("$CURRENT")
  while IFS= read -r NAME; do
    [[ -z "$NAME" ]] && continue
    FOUND="$(path_for "$NAME")"
    [[ -z "$FOUND" ]] && continue # System / third-party header.
    if [[ "$SEEN" != *" $FOUND "* ]]; then
      SEEN="$SEEN$FOUND "
      QUEUE+=("$FOUND")
    fi
  done < <(sed -n -E 's/^[[:space:]]*#[[:space:]]*(import|include)[[:space:]]+(<PubNub\/|")([^">]+\.h)[">].*/\3/p' "$CURRENT" \
           | awk -F/ '{print $NF}' | sort -u)
done

EXPECTED="$(for P in "${PUBLIC[@]}"; do echo "$(basename "$P") -> ../../$P"; done | LC_ALL=C sort)"

if [[ $CHECK == 1 ]]; then
  ACTUAL="$( (cd "$TARGET" 2>/dev/null && for L in *; do [[ -L "$L" ]] && echo "$L -> $(readlink "$L")"; done) | LC_ALL=C sort || true)"
  if [[ "$EXPECTED" != "$ACTUAL" ]]; then
    echo "error: PubNub/include/PubNub is out of date. Run Framework/scripts/export_for_spm.sh" >&2
    diff <(echo "$EXPECTED") <(echo "$ACTUAL") | head -20 >&2 || true
    exit 1
  fi
  exit 0
fi

rm -rf "$TARGET"
mkdir -p "$TARGET"
for P in "${PUBLIC[@]}"; do
  ln -s "../../$P" "$TARGET/$(basename "$P")"
done

# Directory umbrella: every header in `include/PubNub` belongs to the module, so SPM doesn't require all of them to
# be reachable from a single umbrella header.
cat > "$INCLUDE/module.modulemap" <<'MODULEMAP'
module PubNub {
    umbrella "PubNub"
    export *
    module * { export * }
}
MODULEMAP

echo "Generated ${#PUBLIC[@]} header links in PubNub/include/PubNub"

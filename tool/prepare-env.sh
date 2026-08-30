#!/bin/sh
# Install one environment's Firebase, RevenueCat and Cloud Functions config where each is read, plus the unflavored files both share.
set -eu
. "$(dirname "$0")/_common.sh"

SRC="env_assets"

TARGET="${1:-}"
case "$TARGET" in
  dev | prod) ;;
  *) fail "usage: prepare-env.sh <dev|prod>" ;;
esac

# Gitignored, so a clone never has it.
[ -d "$SRC" ] || fail "$SRC/ is missing — restore your own copy"

# `<source under env_assets>|<destination>`, newline separated so the default IFS splits it; no path here has a space.
PAIRS="
$TARGET.json|env/$TARGET.json
fastlane.env|ios/fastlane/.env
$TARGET-google-services.json|android/app/google-services.json
$TARGET-GoogleService-Info.plist|ios/Runner/GoogleService-Info.plist
$TARGET-Info.plist|ios/Runner/Info.plist
$TARGET-function.env|functions/.env
"

# All checked before anything is written.
MISSING=""
for pair in $PAIRS; do
  SRC_FILE="$SRC/${pair%%|*}"
  [ -f "$SRC_FILE" ] || MISSING="$MISSING $SRC_FILE"
done

if [ -n "$MISSING" ]; then
  warn "missing in $SRC/:"
  for f in $MISSING; do
    item "$f"
  done
  fail "nothing was copied"
fi

# Widest source path first, so every destination starts in the same column: the list is read down the arrow, and a ragged one has to be read across each line instead.
WIDTH=0
for pair in $PAIRS; do
  SRC_FILE="$SRC/${pair%%|*}"
  if [ "${#SRC_FILE}" -gt "$WIDTH" ]; then
    WIDTH="${#SRC_FILE}"
  fi
done

step "config — $TARGET"
for pair in $PAIRS; do
  SRC_FILE="$SRC/${pair%%|*}"
  DST_FILE="${pair#*|}"
  cp "$SRC_FILE" "$DST_FILE"
  item "$(pad "$SRC_FILE" "$WIDTH") -> $DST_FILE"
done

done_msg "$TARGET config installed"
# functions/.env is read by the Firebase CLI at deploy time, not by the app.
warn "functions/.env reaches the backend only on the next deploy"

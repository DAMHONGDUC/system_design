#!/bin/sh
# Build an iOS release archive for one environment, with its config attached.
set -eu
. "$(dirname "$0")/_common.sh"

TARGET="${1:-}"
[ $# -gt 0 ] && shift

# Both go to TestFlight, so both export app-store — it is the only method App Store Connect accepts. Override with --export-method to sideload one.
case "$TARGET" in
  dev)
    ENV_FILE="env/dev.json"
    ;;
  prod)
    ENV_FILE="env/prod.json"
    ;;
  *) fail "usage: build-ipa.sh <dev|prod> [flutter build ipa args...]" ;;
esac

EXPORT_METHOD="app-store"

# `--export-method` makes Flutter generate the ExportOptions.plist itself, and that generator maps the MAIN bundle id only.
EXPORT_PLIST_GIVEN=0
for arg in "$@"; do
  case "$arg" in
    --export-options-plist | --export-options-plist=*) EXPORT_PLIST_GIVEN=1 ;;
  esac
done

if [ "$EXPORT_PLIST_GIVEN" -eq 0 ]; then
  set -- --export-method "$EXPORT_METHOD" "$@"
else
  EXPORT_METHOD="caller's --export-options-plist"
fi

# Existence only — never the contents (hard rule 13).
[ -f "$ENV_FILE" ] || fail "$ENV_FILE is missing — run: melos run set-up"

# Gitignored, and a build input of the Runner target rather than a runtime lookup.
GSP="ios/Runner/GoogleService-Info.plist"
# On CI it is written from the GOOGLE_SERVICE_INFO_PLIST secret.
[ -f "$GSP" ] || fail "$GSP is missing — download it from the Firebase console"

# Both environments write to the same folder under the same filename, so a stale IPA from the other one is indistinguishable from this build's.
IPA_DIR="build/ios/ipa"
rm -rf "$IPA_DIR"

# Version and build number are edited in pubspec.yaml, never passed as a flag: `--build-number` ships a build whose version exists nowhere in git.
VERSION=$(grep '^version:' pubspec.yaml | head -1 | cut -d' ' -f2)

step "build ipa — $TARGET $VERSION"
$FL build ipa \
  --release \
  --dart-define-from-file="$ENV_FILE" \
  "$@"

done_msg "built $TARGET $VERSION into $IPA_DIR"
# Both environments share one bundle id, so both land in the SAME TestFlight app and the build number is the only thing telling them apart.
warn "bump version: in pubspec.yaml before the next build — App Store Connect refuses a number it has seen"

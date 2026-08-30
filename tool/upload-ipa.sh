#!/bin/sh
# Upload the IPA already in build/ios/ipa, without rebuilding.
#
# The recovery path for a release that built and then failed to upload: the
# binary on disk is the one that was built, so nothing here builds or bumps.
set -eu
. "$(dirname "$0")/_common.sh"

TARGET="${1:-}"
case "$TARGET" in
  dev | prod) ;;
  *) fail "usage: upload-ipa.sh <dev|prod>" ;;
esac

IPA_DIR="build/ios/ipa"
# Named before fastlane spends a minute on App Store Connect to say the same thing.
[ -d "$IPA_DIR" ] || fail "no $IPA_DIR — run: melos run release-$TARGET"
ls "$IPA_DIR"/*.ipa >/dev/null 2>&1 || fail "no .ipa in $IPA_DIR — run: melos run release-$TARGET"

command -v bundle >/dev/null 2>&1 || fail "bundler not found — cd ios && bundle install"

step "upload $TARGET"
# One line each: the glob can match more than one, and a multi-line message inside a single line breaks the column every other line keeps.
for ipa in "$IPA_DIR"/*.ipa; do
  item "$ipa"
done
(cd ios && bundle exec fastlane upload flavor:"$TARGET" notes:"$TARGET")

done_msg "uploaded $TARGET to TestFlight"

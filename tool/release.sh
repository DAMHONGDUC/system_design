#!/bin/sh
# One environment, end to end: set up, install config, deploy, ship.
#
# Nothing in here names an app: the flavour is an argument, the paths are the
# ones every app embedding this design system uses, and the app-specific part
# lives where it belongs — in that app's fastlane lane.
set -eu
. "$(dirname "$0")/_common.sh"

TARGET="${1:-}"
case "$TARGET" in
  dev | prod) ;;
  *) fail "usage: release.sh <dev|prod>" ;;
esac

# Here rather than 25 minutes in, with the config installed and the backend already deployed.
command -v bundle >/dev/null 2>&1 || fail "bundler not found — cd ios && bundle install"

# The order is the whole point of the command. set-up wipes and regenerates, so
# it runs BEFORE the config it would otherwise build against; the config has to
# be in the tree before the deploy reads functions/.env and before the lane
# compares GoogleService-Info.plist with the flavor. Run by hand in another
# order, the build ships against the wrong Firebase project and says nothing.
step "release $TARGET — 1/4 set up"
sh "$SCRIPT_DIR/set-up.sh"

step "release $TARGET — 2/4 config"
sh "$SCRIPT_DIR/prepare-env.sh" "$TARGET"

step "release $TARGET — 3/4 firebase"
sh "$SCRIPT_DIR/deploy-firebase.sh" "$TARGET"

step "release $TARGET — 4/4 testflight"
(cd ios && bundle exec fastlane beta flavor:"$TARGET" bump:true)

done_msg "released $TARGET"
# bump:true rewrites pubspec.yaml locally but only CI commits it (`if bump && is_ci`).
warn "commit the bumped build number in pubspec.yaml — a local run does not"

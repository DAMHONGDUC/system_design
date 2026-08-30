#!/bin/sh
# One environment, end to end: set up, install config, check, deploy, ship.
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
# it has to run BEFORE the config it would otherwise build against; the config
# has to be in the tree before the deploy reads functions/.env and before the
# lane compares GoogleService-Info.plist with the flavor. Run by hand in any
# other order, the build ships against the wrong Firebase project and says
# nothing.
step "release $TARGET — 1/5 set up"
sh "$SCRIPT_DIR/set-up.sh"

step "release $TARGET — 2/5 config"
sh "$SCRIPT_DIR/prepare-env.sh" "$TARGET"

step "release $TARGET — 3/5 pre-build"
sh "$SCRIPT_DIR/pre-build.sh"

step "release $TARGET — 4/5 firebase"
sh "$SCRIPT_DIR/deploy-firebase.sh" "$TARGET"

step "release $TARGET — 5/5 testflight"
(cd ios && bundle exec fastlane beta flavor:"$TARGET" bump:true notes:"$TARGET")

done_msg "released $TARGET"
# bump:true rewrites pubspec.yaml locally but only CI commits it (`if bump && is_ci`).
warn "commit the bumped build number in pubspec.yaml — a local run does not"

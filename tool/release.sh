#!/bin/sh
# One environment, end to end: install config, deploy, ship.
#
# Nothing in here names an app: the flavour is an argument, the paths are the
# ones every app embedding this design system uses, and the app-specific part
# lives where it belongs — in that app's fastlane lane.
set -eu
. "$(dirname "$0")/_common.sh"

# Everything runs inside `main` because `sh` reads a script by byte offset AS it
# executes it: the fastlane step holds that offset for ~25 minutes, and a commit
# to this file in the meantime leaves the pointer mid-line in the new text —
# 2026-08-31 resumed on a bare `"` and died with `unexpected EOF` at a line
# number this file has never had, after the build had already shipped. A
# function body is parsed whole before the first step runs, so a release in
# flight no longer depends on the file staying still.
main() {
  TARGET="${1:-}"
  case "$TARGET" in
    dev | prod) ;;
    *) fail "usage: release.sh <dev|prod>" ;;
  esac

  # Here rather than 25 minutes in, with the config installed and the backend already deployed.
  command -v bundle >/dev/null 2>&1 || fail "bundler not found — cd ios && bundle install"

  # The order is the whole point of the command: the config has to be in the tree
  # before the deploy reads functions/.env and before the lane compares
  # GoogleService-Info.plist with the flavor. Run by hand in another order, the
  # build ships against the wrong Firebase project and says nothing.
  #
  # set-up is NOT part of this (owner's rule). A release builds the tree as it
  # stands; a tree that needs restoring is restored by `melos run set-up` first,
  # on purpose, rather than paying a cold wipe-and-regenerate on every release.
  step "release $TARGET — 1/3 config"
  sh "$SCRIPT_DIR/prepare-env.sh" "$TARGET"

  step "release $TARGET — 2/3 firebase"
  sh "$SCRIPT_DIR/deploy-firebase.sh" "$TARGET"

  step "release $TARGET — 3/3 testflight"
  (cd ios && bundle exec fastlane beta flavor:"$TARGET" bump:true)

  done_msg "released $TARGET"
  # bump:true rewrites pubspec.yaml locally but only CI commits it (`if bump && is_ci`).
  warn "commit the bumped build number in pubspec.yaml — a local run does not"
}

# `exit` on the same line: it is parsed with the call, so nothing reads the file again after main returns.
main "$@"; exit 0

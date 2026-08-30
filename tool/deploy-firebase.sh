#!/bin/sh
# Deploy one environment's Firebase side: firestore rules, indexes, functions.
set -eu
. "$(dirname "$0")/_common.sh"

ENV_NAME="${1:-}"
case "$ENV_NAME" in
  dev | prod) ;;
  *) fail "usage: deploy-firebase.sh <dev|prod> [rules|functions]" ;;
esac

TARGET="${2:-all}"
case "$TARGET" in
  all | rules | functions) ;;
  *) fail "unknown target '$TARGET' — expected: rules, functions, or nothing" ;;
esac

# The CLI is resolved rather than assumed, and the repo's own copy wins: the standalone binary installed on PATH runs every predeploy hook through the npm 8 bundled inside it, which dies on `npm run lint` with "Cannot read properties of undefined (reading 'stdin')" before eslint or tsc ever start. The one in functions/node_modules runs on the machine's real node and npm, so the hooks behave the way they do in a plain shell.
FIREBASE="$PWD/functions/node_modules/.bin/firebase"
if [ ! -x "$FIREBASE" ]; then
  command -v firebase >/dev/null 2>&1 ||
    fail "firebase CLI not found — npm --prefix functions install, or https://firebase.google.com/docs/cli"
  FIREBASE=firebase
fi

# `.firebaserc` is read here rather than left to the CLI so the prompt can name the project *before* anything is sent, and so a missing alias fails.
project_id() {
  sed -n 's/.*"'"$1"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' .firebaserc
}

ENV_ID=$(project_id "$ENV_NAME")
if [ -z "$ENV_ID" ]; then
  warn "no '$ENV_NAME' alias in .firebaserc"
  fail "create it with: firebase use --add   (docs/setup/FIREBASE_PROJECT.md)"
fi

step "firebase — $ENV_NAME"
info "project: $ENV_ID"
info "cli: $FIREBASE"

# Until prod is its own project both aliases resolve to the same id, and then `deploy-firebase-dev` is a production deploy wearing another name.
DEV_ID=$(project_id dev)
PROD_ID=$(project_id prod)
if [ -n "$DEV_ID" ] && [ "$DEV_ID" = "$PROD_ID" ]; then
  warn "dev and prod are the SAME project — this reaches real users"
fi

ask "deploy $TARGET to $ENV_ID? [y/N] "
# Melos hands the script a piped stdout but leaves stdin alone; /dev/tty is the one that survives a `sh tool/... < something`, so try it and fall back.
REPLY=''
# stderr is redirected BEFORE /dev/tty: redirections apply left to right, so the other order reports the failure to the original stderr anyway.
read -r REPLY 2>/dev/null </dev/tty || read -r REPLY || true
case "$REPLY" in
  y | Y) ;;
  *) fail "aborted" ;;
esac

# Every deploy passes `--project` rather than running `firebase use` first.
if [ "$TARGET" = "all" ] || [ "$TARGET" = "rules" ]; then
  step "rules and indexes"
  "$FIREBASE" deploy --project "$ENV_NAME" --only firestore:rules,firestore:indexes
fi

if [ "$TARGET" = "all" ] || [ "$TARGET" = "functions" ]; then
  # Deploying a build that fails its own tests costs a second deploy to undo.
  step "functions tests"
  # Both scripts are optional: these tools are shared with backends that define neither, where `npm test` fails with "Missing script: test" — a message that reads as a broken checkout rather than as a check that does not apply.
  if has_npm_script functions build; then
    (cd functions && npm run build)
  else
    info "no build script in functions/package.json, nothing to compile"
  fi

  if has_npm_script functions test; then
    (cd functions && npm test)
  else
    info "no test script in functions/package.json, nothing to run"
  fi

  step "functions"
  "$FIREBASE" deploy --project "$ENV_NAME" --only functions
fi

done_msg "deployed $TARGET to $ENV_NAME"

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

# The template is the app's declaration that it HAS dart-define config: set-up.sh
# copies it into place, so an app that keeps one wants the real file and a
# missing one is an error. An app with no template never passes
# --dart-define-from-file at all — these tools are shared with apps whose every
# value is compiled in, and there a demand for env/dev.json reads as a broken
# checkout rather than as a step that does not apply.
TEMPLATE=$(env_template "$TARGET")
if [ -n "$TEMPLATE" ]; then
  # Existence only — never the contents (hard rule 13).
  [ -f "$ENV_FILE" ] || fail "$ENV_FILE is missing — run: melos run set-up"
  set -- --dart-define-from-file="$ENV_FILE" "$@"
  info "config: $ENV_FILE (declared by $TEMPLATE)"
else
  ENV_FILE=""
  info "no env template — this app compiles its config in, no dart-defines"
fi

# Gitignored, and a build input of the Runner target rather than a runtime lookup.
GSP="ios/Runner/GoogleService-Info.plist"
if has_firebase; then
  # On CI it is written from the GOOGLE_SERVICE_INFO_PLIST secret.
  [ -f "$GSP" ] || fail "$GSP is missing — download it from the Firebase console"
fi

# `flutter build ipa` resolves the Swift package graph before it archives, and
# it runs that step deliberately WITHOUT `-skipPackageUpdates` — so every
# archive contacts github to re-check the version-ranged remotes, populated
# cache or not. It also drops that step's stdout, so an unreachable github
# surfaces ~40 seconds in as `Couldn't fetch updates from remote repositories:`
# with the reason cut off.
#
# The same command is run here first, for two reasons: the reason survives, and
# a resolve that succeeds here leaves flutter's nothing to fetch. Four
# attempts, because this failure is rarely a clean one — where github is
# filtered rather than blocked the connect times out on some attempts and not
# others, so a single probe reports whichever one it happened to get.
SPM_PINS="ios/Runner.xcworkspace/xcshareddata/swiftpm/Package.resolved"
if [ -f "$SPM_PINS" ]; then
  # Flutter clones into <build dir>/SourcePackages and hands the archive the
  # same -clonedSourcePackagesDirPath. Warming any other directory would leave
  # its own resolve with nothing on disk to reuse.
  SPM_CLONE_DIR="$PWD/build/ios/SourcePackages"
  SPM_LOG=$(mktemp)
  SPM_OK=0

  # No -workspace and no -scheme, exactly as flutter runs it: naming a scheme
  # here would resolve a different graph from the one the archive uses.
  for _ in 1 2 3 4; do
    if (
      cd ios &&
        xcrun xcodebuild -resolvePackageDependencies \
          -clonedSourcePackagesDirPath "$SPM_CLONE_DIR"
    ) >"$SPM_LOG" 2>&1; then
      SPM_OK=1
      break
    fi
  done

  if [ "$SPM_OK" -eq 0 ]; then
    # xcodebuild names the host and the timeout on these lines and flutter
    # throws them away — they are the whole point of resolving here.
    grep -E 'fatal:|error:|Couldn' "$SPM_LOG" | while IFS= read -r spm_line; do
      item "$spm_line"
    done
    rm -f "$SPM_LOG"
    fail "swift package resolution failed four times, and every remote package comes from github.com — the archive would die 40 seconds in with the reason cut off. Connect to a VPN and run this again."
  fi

  rm -f "$SPM_LOG"
  info "swift packages: resolved into $SPM_CLONE_DIR"
fi

# Both environments write to the same folder under the same filename, so a stale IPA from the other one is indistinguishable from this build's.
IPA_DIR="build/ios/ipa"
rm -rf "$IPA_DIR"

# Version and build number are edited in pubspec.yaml, never passed as a flag: `--build-number` ships a build whose version exists nowhere in git.
VERSION=$(grep '^version:' pubspec.yaml | head -1 | cut -d' ' -f2)

step "build ipa — $TARGET $VERSION"
$FL build ipa \
  --release \
  "$@"

done_msg "built $TARGET $VERSION into $IPA_DIR"
# Both environments share one bundle id, so both land in the SAME TestFlight app and the build number is the only thing telling them apart.
warn "bump version: in pubspec.yaml before the next build — App Store Connect refuses a number it has seen"

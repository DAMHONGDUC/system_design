#!/bin/sh
# What a release build needs before it is worth starting.
#
# A blocker is something App Review or the build itself will stop on; the
# optional lines are release-only and warn instead. First ✗ is the first thing
# to fix. Missing pieces are tracked in docs/rules/PENDING_SETUP.md.
#
# No `set -e`: every check runs, so the output is the whole list rather than
# the first failure. `set -u` still applies.
set -u
. "$(dirname "$0")/_common.sh"

FAILED=0

# `ok`/`bad` come from _common.sh, so the ✓/✗ vocabulary is the same everywhere.
blocker() {
  if [ "$2" = "0" ]; then
    ok "$1"
  else
    bad "$1"
    FAILED=$((FAILED + 1))
  fi
}

# Named `optional`, not `warn`: `_common.sh` already owns `warn`, and two
# functions with one name is how a script starts lying about which ran.
optional() {
  if [ "$2" = "0" ]; then
    ok "$1"
  else
    warn "! $1"
  fi
}

exists() {
  [ -f "$1" ] && echo 0 || echo 1
}

step "firebase and sign-in"
blocker "lib/firebase_options.dart" "$(exists lib/firebase_options.dart)"
blocker "ios/Runner/GoogleService-Info.plist" "$(exists ios/Runner/GoogleService-Info.plist)"
blocker "android/app/google-services.json" "$(exists android/app/google-services.json)"
optional ".firebaserc — needed by deploy-firebase-*" "$(exists .firebaserc)"

# The reversed iOS client id has to be a URL scheme or Google sign-in comes back to nothing. `flutterfire configure` does not add it.
if [ -f ios/Runner/GoogleService-Info.plist ]; then
  REVERSED=$(/usr/libexec/PlistBuddy -c "Print :REVERSED_CLIENT_ID" \
    ios/Runner/GoogleService-Info.plist 2>/dev/null)
  if [ -n "$REVERSED" ]; then
    grep -q "$REVERSED" ios/Runner/Info.plist
    blocker "reversed client id is a URL scheme in Info.plist" "$?"
  fi
fi

step "account deletion"
# App Store 5.1.1(v): the account AND its data. A build where that export went missing deletes nothing.
grep -q "deleteAccount" functions/src/index.ts
blocker "the deleteAccount callable is exported" "$?"

step "app icon"
# Checksum, not size: the icon can be any size, but exactly one byte sequence means "nobody replaced the template".
FLUTTER_DEFAULT_ICON=7770183009e914112de7d8ef1d235a6a30c5834424858e0d2f8253f6b8d31926
ICON=ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
if [ -f "$ICON" ]; then
  [ "$(shasum -a 256 "$ICON" | cut -d' ' -f1)" != "$FLUTTER_DEFAULT_ICON" ]
  blocker "not Flutter's default icon" "$?"
else
  blocker "the 1024 icon exists" 1
fi

step "ios build settings"
# HealthKit and the pressure alerts each read a permission the app dies without.
grep -q "NSHealthShareUsageDescription" ios/Runner/Info.plist
blocker "NSHealthShareUsageDescription" "$?"
grep -q "NSLocationWhenInUseUsageDescription" ios/Runner/Info.plist
blocker "NSLocationWhenInUseUsageDescription" "$?"

# Sign in with Apple does not work on device without the entitlement, and the build setting has to name it on all three configurations.
blocker "ios/Runner/Runner.entitlements" "$(exists ios/Runner/Runner.entitlements)"
grep -q "com.apple.developer.applesignin" ios/Runner/Runner.entitlements 2>/dev/null
blocker "the entitlement declares Sign in with Apple" "$?"
# Per target, not in total: Runner and the widget each need the setting on
# Debug, Release and Profile, and a total of six can also be one target twice.
PBXPROJ=ios/Runner.xcodeproj/project.pbxproj
[ "$(grep -c 'CODE_SIGN_ENTITLEMENTS = Runner/' "$PBXPROJ")" = "3" ]
blocker "app: CODE_SIGN_ENTITLEMENTS on all three configurations" "$?"
[ "$(grep -c 'CODE_SIGN_ENTITLEMENTS = BaroEaseWidget/' "$PBXPROJ")" = "3" ]
blocker "widget: CODE_SIGN_ENTITLEMENTS on all three configurations" "$?"

# The home screen widget reads the app's data through the App Group; without it on BOTH sides the widget renders empty and nothing errors.
WIDGET_ENT=ios/BaroEaseWidget/BaroEaseWidget.entitlements
blocker "$WIDGET_ENT" "$(exists "$WIDGET_ENT")"
grep -q "application-groups" "$WIDGET_ENT" 2>/dev/null &&
  grep -q "application-groups" ios/Runner/Runner.entitlements 2>/dev/null
blocker "app and widget share an App Group" "$?"

step "android build settings"
ANDROID_GRADLE=android/app/build.gradle.kts
blocker "$ANDROID_GRADLE" "$(exists "$ANDROID_GRADLE")"
grep -q 'id("com.google.gms.google-services")' "$ANDROID_GRADLE" 2>/dev/null
blocker "the Google Services Gradle plugin is applied" "$?"
grep -q 'appId = "com.dd.migraine.tracker"' "$ANDROID_GRADLE" 2>/dev/null
blocker "the application id is com.dd.migraine.tracker" "$?"
# A warning, not a blocker: this app ships iOS first and Android is only kept
# compiling (CLAUDE.md), so the debug key is the known state — and an iOS
# release must not stop on it. It becomes a blocker the day Android ships.
! grep -q 'signingConfig = signingConfigs.getByName("debug")' "$ANDROID_GRADLE" 2>/dev/null
optional "android release signing is not the debug key" "$?"

step "release credentials"
# Warnings: none of this stops a local build, and the lane refuses loudly on its own when one is missing.
optional "env/prod.json" "$(exists env/prod.json)"
optional "env_assets/ — the real per-flavour config" \
  "$([ -d env_assets ] && echo 0 || echo 1)"
optional "ios/fastlane/.env — the release credentials" "$(exists ios/fastlane/.env)"
optional "ios/Gemfile.lock — run 'bundle install' in ios/" "$(exists ios/Gemfile.lock)"

step "analyzer"
sh "$SCRIPT_DIR/analyze.sh" >/dev/null 2>&1
blocker "zero findings" "$?"

echo ""
if [ "$FAILED" -eq 0 ]; then
  done_msg "pre-build clean"
else
  fail "$FAILED blocker(s) unmet — fix the ✗ lines above"
fi

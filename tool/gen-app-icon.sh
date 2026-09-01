#!/bin/sh
# One source PNG to every icon the app ships: launcher sizes plus rounded native splash copies for iOS and Android.
set -eu
. "$(dirname "$0")/_common.sh"

SOURCE=${APP_ICON_SOURCE:-assets/app_icon.png}
FINAL=${APP_ICON_FINAL:-assets/final_app_icon.png}
LAUNCH_DIR=ios/Runner/Assets.xcassets/LaunchImage.imageset
ANDROID_RES_DIR=android/app/src/main/res
IOS_PROJECT=ios/Runner.xcodeproj/project.pbxproj
ROUNDER="$SCRIPT_DIR/round_icon_corners.dart"

# Named before anything runs: the three steps below all read the file this one writes, so a missing original fails at the end of step one otherwise.
[ -f "$SOURCE" ] ||
  fail "no $SOURCE — the generated original goes there (docs/setup/APP_ICON.md)"

# `--verbosity=error` on every `dart run` of ours: Dart 3.9 prints "Running build hooks..." to STDERR, and melos labels every stderr line ERROR — three real-looking errors in a run that worked. Compilation errors still print.
QUIET="run --verbosity=error"

# $1 = pixel size, $2 = file name. The launch storyboard's image view cannot clip, so the corners are baked into the alpha here.
launch_icon() {
  $DT $QUIET "$ROUNDER" "$FINAL" "$LAUNCH_DIR/$2" "$1"
}

# $1 = density, $2 = pixel size. A transparent rounded tile stays consistent on legacy Android and inside Android 12's system splash mask.
android_launch_icon() {
  _android_dir="$ANDROID_RES_DIR/drawable-$1"
  mkdir -p "$_android_dir"
  $DT $QUIET "$ROUNDER" "$FINAL" "$_android_dir/launch_image.png" "$2"
}

step "prepare source icon"
if [ "${APP_ICON_STRIP_MARKER:-0}" = 1 ]; then
  $DT $QUIET "$SCRIPT_DIR/strip_icon_marker.dart" "$SOURCE" "$FINAL"
else
  cp "$SOURCE" "$FINAL"
fi

step "launcher icons"
# Config is the `flutter_launcher_icons:` block at the bottom of pubspec.yaml.
$DT run flutter_launcher_icons

# flutter_launcher_icons 0.14.4 rewrites every ASSETCATALOG setting after it sees an xcconfig line; only APPICON_NAME should change.
sed 's/ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = AppIcon;/ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;/' "$IOS_PROJECT" > "$IOS_PROJECT.tmp"
mv "$IOS_PROJECT.tmp" "$IOS_PROJECT"

step "launch screen"
launch_icon 112 LaunchImage.png
launch_icon 224 'LaunchImage@2x.png'
launch_icon 336 'LaunchImage@3x.png'
android_launch_icon mdpi 112
android_launch_icon hdpi 168
android_launch_icon xhdpi 224
android_launch_icon xxhdpi 336
android_launch_icon xxxhdpi 448

done_msg "icons regenerated from $SOURCE"

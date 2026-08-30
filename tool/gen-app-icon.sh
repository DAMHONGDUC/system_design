#!/bin/sh
# One source PNG to every icon the app ships: the watermark stripped, the launcher sizes generated, the launch screen's rounded copies written.
set -eu
. "$(dirname "$0")/_common.sh"

SOURCE=assets/images/app_icon.png
FINAL=assets/images/final_app_icon.png
LAUNCH_DIR=ios/Runner/Assets.xcassets/LaunchImage.imageset
ROUNDER="$SCRIPT_DIR/round_icon_corners.dart"

# Named before anything runs: the three steps below all read the file this one writes, so a missing original fails at the end of step one otherwise.
[ -f "$SOURCE" ] ||
  fail "no $SOURCE — the generated original goes there (docs/setup/APP_ICON.md)"

# $1 = pixel size, $2 = file name. The launch storyboard's image view cannot clip, so the corners are baked into the alpha here.
launch_icon() {
  $DT run "$ROUNDER" "$FINAL" "$LAUNCH_DIR/$2" "$1"
}

step "strip the watermark"
$DT run "$SCRIPT_DIR/strip_icon_marker.dart" "$SOURCE" "$FINAL"

step "launcher icons"
# Config is the `flutter_launcher_icons:` block at the bottom of pubspec.yaml.
$DT run flutter_launcher_icons

step "launch screen"
launch_icon 112 LaunchImage.png
launch_icon 224 'LaunchImage@2x.png'
launch_icon 336 'LaunchImage@3x.png'

done_msg "icons regenerated from $SOURCE"

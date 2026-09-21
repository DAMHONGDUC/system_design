#!/bin/sh
# Erase the image generator's watermark from the app icon artwork, in place.
set -eu
. "$(dirname "$0")/_common.sh"

SOURCE=${APP_ICON_SOURCE:-assets/images/app_icon.png}
STRIPPER="$SCRIPT_DIR/strip_icon_marker.dart"

[ -f "$SOURCE" ] ||
  fail "no $SOURCE — the 1024x1024 artwork goes there (docs/setup/APP_ICON.md)"

# Its own command, not a step inside gen-app-icon (owner's rule): the watermark belongs to the artwork, so it is stripped ONCE when a new image arrives, while the icons are regenerated many times after. Folding it in re-ran a clone-stamp over an already-clean corner on every single run.
step "strip marker"

# Via a temp: the stripper decodes the whole PNG before it writes, and pointing it at its own input is how a half-written file becomes the only copy of the artwork. `.tmp` sits beside the original so the move stays on one filesystem.
$DT run --verbosity=error "$STRIPPER" "$SOURCE" "$SOURCE.tmp"
mv "$SOURCE.tmp" "$SOURCE"

info "check the corner at full size, then run: melos run gen-app-icon"
done_msg "marker stripped from $SOURCE"

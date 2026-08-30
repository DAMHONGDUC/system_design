# Shared by every tool/ script.

# Absolute, and resolved BEFORE the cd below: every script sources this one by a path relative to the caller's cwd, and after the cd that path points nowhere.
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# These scripts live in the design system submodule, but every path they touch — ios/, functions/, env_assets/, pubspec.yaml — belongs to the app repo. So the root is DERIVED (three levels up from packages/system_design/tool), never taken from the caller's cwd: run from inside the submodule, `cd .` would leave every relative path pointing at the wrong repo and the failure would name a missing file rather than the wrong directory.
cd "${MELOS_ROOT_PATH:-$(CDPATH= cd -- "$SCRIPT_DIR/../../.." && pwd)}"

# Colour on unless `NO_COLOR` (no-color.org) says otherwise.
if [ -z "${NO_COLOR:-}" ]; then
  C_STEP=$(printf '\033[1;36m')
  C_WARN=$(printf '\033[1;33m')
  C_OK=$(printf '\033[1;32m')
  C_BAD=$(printf '\033[1;31m')
  C_OFF=$(printf '\033[0m')
else
  C_STEP=''
  C_WARN=''
  C_OK=''
  C_BAD=''
  C_OFF=''
fi

# `flutter` is a shell alias for `fvm flutter` on a dev machine, and aliases do not exist inside a script — resolve it or we run the wrong SDK.
if [ -f .fvmrc ] && command -v fvm >/dev/null 2>&1; then
  FL="fvm flutter"
  DT="fvm dart"
else
  FL="flutter"
  DT="dart"
fi

# One meaning per colour: cyan opens an action, green passed, red failed,
# yellow warns. Owner's rule: THE MARK CARRIES THE COLOUR AND THE MESSAGE STAYS
# PLAIN — a wall of coloured sentences is a wall, and the eye scanning for the
# ✗ has to read it instead of finding it. `step` is the one exception: it has
# no mark, so the title is the mark.
step() { printf '%s==> %s%s\n' "$C_STEP" "$1" "$C_OFF"; }
info() { printf '    %s\n' "$1"; }
warn() { printf '    %s!%s %s\n' "$C_WARN" "$C_OFF" "$1"; }
ok() { printf '    %s✓%s %s\n' "$C_OK" "$C_OFF" "$1"; }
bad() { printf '    %s✗%s %s\n' "$C_BAD" "$C_OFF" "$1"; }
done_msg() { printf '%s✓%s %s\n' "$C_OK" "$C_OFF" "$1"; }
fail() {
  printf '%s✗%s %s\n' "$C_BAD" "$C_OFF" "$1" >&2
  exit 1
}

# Shared by every tool/ script.

# Absolute, and resolved BEFORE the cd below: every script sources this one by a path relative to the caller's cwd, and after the cd that path points nowhere.
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# These scripts live in the design system submodule, but every path they touch — ios/, functions/, env_assets/, pubspec.yaml — belongs to the app repo. So the root is DERIVED (three levels up from packages/system_design/tool), never taken from the caller's cwd: run from inside the submodule, `cd .` would leave every relative path pointing at the wrong repo and the failure would name a missing file rather than the wrong directory.
cd "${MELOS_ROOT_PATH:-$(CDPATH= cd -- "$SCRIPT_DIR/../../.." && pwd)}"

# Colour on unless `NO_COLOR` (no-color.org) says otherwise.
if [ -z "${NO_COLOR:-}" ]; then
  C_STEP=$(printf '\033[1;36m')
  C_INFO=$(printf '\033[1;34m')
  C_WARN=$(printf '\033[1;33m')
  C_OK=$(printf '\033[1;32m')
  C_BAD=$(printf '\033[1;31m')
  C_ASK=$(printf '\033[1;35m')
  C_TIME=$(printf '\033[1;37m')
  C_DIM=$(printf '\033[2m')
  C_OFF=$(printf '\033[0m')
else
  C_STEP=''
  C_INFO=''
  C_WARN=''
  C_OK=''
  C_BAD=''
  C_ASK=''
  C_TIME=''
  C_DIM=''
  C_OFF=''
fi

# Exported because `git submodule foreach` runs its body in a shell of its own: the environment crosses over, the functions below do not, so a line printed in there has to build itself out of these.
export C_STEP C_INFO C_WARN C_OK C_BAD C_ASK C_TIME C_DIM C_OFF

# `flutter` is a shell alias for `fvm flutter` on a dev machine, and aliases do not exist inside a script — resolve it or we run the wrong SDK.
if [ -f .fvmrc ] && command -v fvm >/dev/null 2>&1; then
  FL="fvm flutter"
  DT="fvm dart"
else
  FL="flutter"
  DT="dart"
fi

# Every line is the same three columns — TIME, a three-wide gutter holding the
# mark, then the message — so the times read down one column and the messages
# down another however long the line above was:
#
#   [10:04:31]: ==> config — dev                  a step, flush left in the gutter
#   [10:04:31]:   i installing 6 files            a line inside that step
#   [10:04:31]:   · env_assets/dev.json -> env/…  an entry in a list under it
#   [10:04:32]: ✔   dev config installed          the script's own verdict, flush left again
#
# The nesting IS the mark's position in the gutter: flush left is the script
# talking about itself (a step opening, the run ending), right is one line
# inside the step above it. Indenting the message instead would put the marks
# in a ragged column, which is the one column the eye scans.
#
# One meaning per colour: cyan opens an action, blue informs, yellow warns,
# green passed, red failed, magenta is waiting for an answer. Owner's rule: THE
# MARK CARRIES THE COLOUR AND THE MESSAGE STAYS PLAIN — a wall of coloured
# sentences is a wall, and the eye scanning for the ✘ has to read it instead of
# finding it. `step` is the one exception: it has no mark, so the title is the
# mark. The time is white and bracketed (owner's rule): it opens every line, so
# it is read as the line's edge rather than as one of the marks — no colour of
# the five means anything there, and a sixth would.

_ts() { date '+%H:%M:%S'; }

# `[10:21:37]:` — the brackets and the colon are the shape the owner asked for,
# and they are what keeps the timestamp from reading as part of the message.
_stamp() { printf '%s[%s]:%s' "$C_TIME" "$(_ts)" "$C_OFF"; }

# $1 gutter (three columns, mark included), $2 its colour, $3 the message.
_line() {
  printf '%s %s%s%s %s\n' "$(_stamp)" "$2" "$1" "$C_OFF" "$3"
}

step() { printf '%s %s==> %s%s\n' "$(_stamp)" "$C_STEP" "$1" "$C_OFF"; }
info() { _line '  i' "$C_INFO" "$1"; }
warn() { _line '  ⚠' "$C_WARN" "$1"; }
ok() { _line '  ✔' "$C_OK" "$1"; }
bad() { _line '  ✘' "$C_BAD" "$1"; }
# An entry in a list under the line above — dim on purpose: six copied paths are
# one fact, and six blue `i` marks claim they are six.
item() { _line '  ·' "$C_DIM" "$1"; }
done_msg() { _line '✔  ' "$C_OK" "$1"; }
# No newline: the answer is typed on the line the question is asked on.
ask() { printf '%s %s  ?%s %s' "$(_stamp)" "$C_ASK" "$C_OFF" "$1"; }
fail() {
  _line '✘  ' "$C_BAD" "$1" >&2
  exit 1
}

# True when the app declares $1 in its pubspec.yaml, under any section. Codegen is a choice an app makes, and these scripts are shared with apps that made it the other way: no `build_runner` there means there is nothing to generate, and running it anyway fails with "could not find package build_runner", which reads as a broken checkout rather than as a step that does not apply.
has_dep() { grep -q "^[[:space:]]*$1:" pubspec.yaml; }

# Pad $1 out to $2 columns, so the second column of a list lines up under itself. POSIX sh has no `local`, hence the underscore: the name is a promise not to read it, not a scope.
pad() {
  _pad_text="$1"
  while [ "${#_pad_text}" -lt "$2" ]; do
    _pad_text="$_pad_text "
  done

  printf '%s' "$_pad_text"
}

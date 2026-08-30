#!/bin/sh
# Regenerate localizations and build_runner output.
set -eu
. "$(dirname "$0")/_common.sh"

step "localizations"
$FL gen-l10n

if has_dep build_runner; then
  step "code generation"
  # build_runner 2.15 removed --delete-conflicting-outputs; it deletes them by default now, and passing it warns on every run.
  $DT run build_runner build
else
  info "no build_runner in pubspec.yaml, nothing to generate"
fi

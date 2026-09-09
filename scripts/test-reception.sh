#!/usr/bin/env bash
set -euo pipefail
panel_root="$(cd "$(dirname "$0")/.." && pwd)"
flutter_bin="${FLUTTER_BIN:-flutter}"
export FLUTTER_SUPPRESS_ANALYTICS=true DART_SUPPRESS_ANALYTICS=true
cd "$panel_root/../2daopinion-app"
"$flutter_bin" test --platform chrome test/integration/submission_emulators.dart --reporter expanded
cd "$panel_root"
"$flutter_bin" test --platform chrome test/integration/intake_emulators.dart --reporter expanded

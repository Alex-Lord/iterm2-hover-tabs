#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SUITE="$(basename "$ROOT")"
APP="$ROOT/build/Deployment/iTerm2.app/Contents/MacOS/iTerm2"
if [[ ! -x "$APP" ]]; then
    echo "Build the Deployment app before running this script." >&2
    exit 1
fi
# Avoid inheriting Codex's color suppression into interactive shells.
# cc-status/it2 must use the isolated app's API socket as well.
exec env -u NO_COLOR -u TERM -u COLORTERM IT2_SUITE="$SUITE" \
    "$APP" -suite "$SUITE" -LeftTabBarExpandsOnHover YES \
    -TabViewType 2 -EnableAPIServer YES -moveToApplicationsFolderAlertSuppress YES

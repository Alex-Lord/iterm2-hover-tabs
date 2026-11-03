Left tab bar hover expansion (based on iTerm2 v3.7.3)
Base commit: 9b6084d879ee780e51f16144277ac2459e668b0d

Behavior
- Optional Advanced setting: Expand the left tab bar on hover? Defaults off.
- Applies to left tabs: a 20-point rail expands after 50 ms and collapses
  100 ms after exit. Expanded width is the saved sidebar width, minimum 180.
- Expansion overlays content without changing terminal/status/toolbelt frames.
- Native tab colors, status indicators, tooltips and accessibility remain.
- Dragging or a tracked menu holds the expanded bar open; focus loss closes it.
- Expanded bars recover from missed exit/focus events. Collapsed idle bars
  have no timer. No global mouse monitor or Accessibility permission is used.
- Fullscreen keeps the rail; tab switching can briefly reveal titles.
- Uses the existing non-Metal compositing while expanded and restores Metal
  on collapse. Follows the existing single-tab visibility preference.

Build
Install full Xcode and SF Symbols. Follow the upstream make setup procedure.
Use the Xcode selected by DEVELOPER_DIR or xcode-select.
With Rust 1.94 and macOS 27, disable stripping to avoid misaligned LINKEDIT
string pools in proc-macro dylibs:
  export CARGO_PROFILE_RELEASE_STRIP=none
  export CARGO_PROFILE_RELEASE_BUILD_OVERRIDE_STRIP=none
  make paranoid-deps BUILD_DIR="$PWD/build"
  BUILD_DIR="$PWD/build" tools/build.sh Development

Optimized local build:
  cp plists/release-iTerm2.plist plists/iTerm2.plist
  BUILD_DIR="$PWD/build" tools/build.sh Deployment
  codesign --force --deep --sign - build/Deployment/iTerm2.app
  codesign --verify --deep --strict build/Deployment/iTerm2.app

Do not commit rebuilt third-party frameworks or submodule outputs. The Xcode
version record must be updated by a real dependency rebuild, not fabricated.

Tests
  tests/hover-tabs/run.sh
  tools/run_tests.expect ModernTests/iTermLayoutCalculatorTest

The standalone checks compile the real controller/layout implementation and
verify 14 state checks, 24 left layouts plus three other positions, the ObjC
bridge, and AppKit recovery from missed exit and focus events.
The existing ModernTests layout suite passes all 31 tests.
Both Development and Deployment builds pass with Xcode 27.1 (27A9275).

Interactive verification
  tests/hover-tabs/launch-test.sh

This starts the Deployment app with a preferences suite named after the
checkout folder, removes NO_COLOR inherited from automation, enables the
isolated API server, and points cc-status/it2 at that suite. It suppresses
release-build self-migration so relaunching cannot drop the suite arguments.
Do not start a second instance using the same suite while one is running.
Test at least two tabs, normal/fullscreen, enter/exit, focus changes, dragging,
menus, tab colors, Claude status colors, and unchanged terminal columns.
The user verified hover, terminal width, and colors before installation.

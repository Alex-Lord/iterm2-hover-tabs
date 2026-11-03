#!/bin/bash
set -euo pipefail
repo_dir="$(cd "$(dirname "$0")/../.." && pwd)"
build_dir="$(mktemp -d "${TMPDIR:-/tmp}/iterm-hover-tests.XXXXXX")"
trap 'rm -rf "$build_dir"' EXIT
xcrun swiftc -swift-version 5 -warnings-as-errors \
    "$repo_dir/sources/TerminalView/iTermHoverTabBarController.swift" \
    "$repo_dir/tests/hover-tabs/state-tests.swift" \
    -o "$build_dir/state-tests"
"$build_dir/state-tests"
xcrun clang -fobjc-arc -Wall -Wextra -Werror \
    -I "$repo_dir/sources/TerminalView" \
    "$repo_dir/sources/TerminalView/iTermLayoutCalculator.m" \
    "$repo_dir/tests/hover-tabs/layout-tests.m" \
    -framework Foundation -framework CoreGraphics \
    -o "$build_dir/layout-tests"
"$build_dir/layout-tests"
xcrun swiftc -swift-version 5 -warnings-as-errors -parse-as-library \
    -emit-module -module-name HoverTabs \
    -emit-objc-header-path "$build_dir/HoverTabs-Swift.h" \
    "$repo_dir/sources/TerminalView/iTermHoverTabBarController.swift" \
    -o "$build_dir/HoverTabs.swiftmodule"
xcrun clang -fobjc-arc -fsyntax-only -fmodules -Wall -Wextra -Werror \
    -I "$build_dir" "$repo_dir/tests/hover-tabs/bridge-test.m"
echo "PASS: Swift-to-Objective-C controller interface"

xcrun swiftc -swift-version 5 -warnings-as-errors \
    "$repo_dir/sources/TerminalView/iTermHoverTabBarController.swift" \
    "$repo_dir/tests/hover-tabs/tracking-tests.swift" \
    -o "$build_dir/tracking-tests"
"$build_dir/tracking-tests"

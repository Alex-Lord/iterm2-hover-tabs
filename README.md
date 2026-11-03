# iTerm2 Hover Tabs · 左侧标签自动收起

基于 [iTerm2 3.7.3](https://github.com/gnachman/iTerm2/tree/v3.7.3) 的非官方定制版。

- 左侧标签栏收起为 **20 点**宽；鼠标停留 **50 ms** 后展开，离开 **100 ms** 后收起。
- 展开覆盖在终端上方，终端列数和内容宽度保持不变。
- 保留原生标签颜色、Claude 状态颜色和终端配色。
- 支持全屏、标签拖动、菜单操作及切换标签时短暂显示。
- 修复重建感应区域时漏掉移出事件导致标签栏卡住的问题。

## 下载与安装

从 [Releases](https://github.com/Alex-Lord/iterm2-hover-tabs/releases) 下载 ZIP，解压后将应用放入 Applications。
当前安装包适用于 **Apple Silicon / macOS 13+**，采用本地 ad-hoc 签名，未经过 Apple 公证。
请先结束需要保留的终端任务并备份原版，再替换应用。macOS 如拦截，可在系统设置的“隐私与安全性”中按提示允许打开。

在 iTerm2 设置中将 Tab Bar Location 设为 Left，并在 Advanced 中搜索 “Expand the left tab bar on hover” 设为 Yes。
也可以在退出 iTerm2 后执行：

```sh
defaults write com.googlecode.iterm2 TabViewType -int 2
defaults write com.googlecode.iterm2 LeftTabBarExpandsOnHover -bool true
```

官方更新会覆盖本定制功能。使用本版期间可关闭自动检查及自动安装：

```sh
defaults write com.googlecode.iterm2 SUEnableAutomaticChecks -bool false
defaults write com.googlecode.iterm2 SUAutomaticallyUpdate -bool false
```

## 源码与验证

源码及许可证保留自上游。构建方法和测试说明见 [tests/hover-tabs/README.txt](tests/hover-tabs/README.txt)。
已验证完整 Development / Deployment 构建、31 项上游布局测试、独立状态与布局测试、AppKit 漏事件恢复测试，以及真实窗口的悬停、宽度和颜色表现。

以下为上游项目说明。

---

<div align="center">

# iTerm2

### macOS Terminal Replacement

![Version](https://img.shields.io/badge/version-3.6-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)

**[Website](https://iterm2.com)** • **[Downloads](https://iterm2.com/downloads.html)** • **[Documentation](https://iterm2.com/documentation.html)** • **[Features](https://iterm2.com/features.html)**

</div>

---

## About

iTerm2 is a powerful terminal emulator for macOS that brings the terminal into the modern age with features you never knew you always wanted.

### Key Features

- **tmux Integration** - Native iTerm2 windows/tabs replace tmux's text-based interface. Run tmux -CC and tmux windows become real macOS windows. Sessions persist through crashes, SSH disconnects, and even app upgrades. Collaborate by having two people attach to the same session.
- **Shell Integration** - Deep shell awareness that tracks commands, directories, hostnames, and usernames. Enables click-to-download files via SCP, drag-and-drop uploads, command history per host, recent directories by "frecency," and marks at each prompt.
- **AI Chat** - Built-in LLM chat window that can optionally interact with terminal contents. Link sessions to get context-aware help, run commands on your behalf, or explain output with annotations.
- **Inline Images** - Display images (including animated GIFs) directly in the terminal. Use imgcat to view photos, charts, or visual output without leaving your workflow.
- **Automatic Profile Switching** - Terminal appearance changes automatically based on hostname, username, directory, or running command. SSH to production? Background turns red. Different environments get different visual contexts.
- **Dedicated Hotkey Windows** - System-wide hotkey summons a terminal that slides down from the top of the screen (or any edge), even over fullscreen apps. Pin it or let it auto-hide.
- **Session Restoration** - Sessions run in long-lived server processes. If iTerm2 crashes or upgrades, your shells keep running. When iTerm2 restarts, it reconnects to your sessions exactly where you left off.
- **Built-in Web Browser** - Browser profiles integrate web browsing into iTerm2's window/tab/pane hierarchy. Copy mode, triggers, AI chat, and other terminal features work in browser sessions.
- **Configurable Status Bar** - Per-session status bar showing git branch, CPU/memory graphs, current directory, hostname, custom interpolated strings, or Python API components.
- **Triggers** - Regex patterns that fire actions when matched: highlight text, run commands, send notifications, open password manager, set marks, or invoke Python scripts.
- **Smart Selection** - Quad-click selects semantic objects (URLs, file paths, email addresses, quoted strings). Right-click for context actions. Cmd-click to open.
- **Copy Mode** - Vim-like keyboard selection. Navigate and select text without touching the mouse. Works with marks to jump between command prompts.
- **Instant Replay** - Scrub backward through terminal history to see exactly what was on screen at any moment, with timestamps. Perfect for catching fleeting errors.
- **Python Scripting API** - Full automation and customization via Python. Create custom status bar components, triggers, menu items, or entirely new features.
- **Open Quickly** - Cmd-Shift-O opens a search across all sessions by tab title, command, hostname, directory, or badge. Navigate large session collections instantly.

---

## Installation

### Download

Get the latest version from [iterm2.com/downloads](https://iterm2.com/downloads.html)

For the bleeding edge without building, try the [nightly build](https://iterm2.com/nightly/latest).

### Build from Source

> **Note:** Development builds may be less stable than official releases.

#### Prerequisites

- No manual prerequisites. `make setup` will install [Homebrew](https://brew.sh/), Xcode,
  Rust, and all other dependencies, prompting for confirmation before each privileged step.

#### Clone

```bash
git clone https://github.com/gnachman/iTerm2.git
```

#### Setup (first time)

```bash
make setup
```

`make setup` is interactive and will prompt for confirmation before any privileged or
security-sensitive operation. It performs the following steps:

- **Homebrew** -- Installs [Homebrew](https://brew.sh/) via its official install script
  if not already present. Prompts before running the installer (which requires sudo).
- **Xcode** -- If no Xcode is selected via `xcode-select`, installs
  [xcodes](https://github.com/XcodesOrg/xcodes) (via Homebrew) and
  [aria2](https://aria2.github.io/) (for faster downloads), then either selects an
  existing `/Applications/Xcode*.app` or downloads the latest Xcode automatically.
  Prompts before running `sudo xcode-select` and before accepting the Xcode license.
- **Rust** -- Installs [rustup](https://rustup.rs) via the official `curl | sh`
  installer if not already present. Prompts before executing the script.
- **Homebrew packages** -- Installs cmake, pkg-config, automake, perl, and python3 if
  missing. If `brew link python@3` would overwrite existing symlinks, prompts for
  confirmation before proceeding.
- **SF Symbols** -- Installs the SF Symbols cask (a `.pkg` installer that requires
  sudo). Prompts before attempting the install; continues without it if declined.
- **Python/Rust packages** -- Installs pyobjc (via pip) and cbindgen (via cargo) if not
  already present.
- **Submodules and toolchains** -- Initializes git submodules, adds the x86_64 Rust
  target, and downloads the Metal toolchain.

To skip all confirmation prompts, use `make dangerous-setup` instead.

After setup, compile native dependencies and build:

```bash
make paranoid-deps   # compile OpenSSL, libsixel, libgit2, Sparkle, etc. (sandboxed)
make                 # build iTerm2
```

Re-run `make paranoid-deps` whenever your active Xcode version changes -- the file `last-xcode-version` tracks which version was last used.

If your Xcode version differs from the one committed in `last-xcode-version` (e.g. you're on an older machine), suppress the noise without committing your local version:

```bash
git update-index --skip-worktree last-xcode-version
```

To undo: `git update-index --no-skip-worktree last-xcode-version`

#### Build

```bash
make Development
```

#### Run

```bash
make run
```

#### Architecture

Builds target your native architecture by default. To produce a universal (arm64 + x86_64) binary:

```bash
UNIVERSAL=1 make Development
```

#### Code signing

Code signing is disabled by default to keep contributor builds simple. To enable it with the project's signing identity:

```bash
SIGNED=1 make Development
```

#### Building in Xcode

If you prefer building from Xcode instead of the command line:

1. Complete the **Clone** and **Setup** steps above.
2. Configure code signing with your team ID:

   ```bash
   tools/set_team_id.sh YOUR_TEAM_ID
   ```

   This script updates `DEVELOPMENT_TEAM` in all Xcode project files (iTerm2 and its dependencies like Sparkle, SwiftyMarkdown, etc.) so code signing works with your identity.

   **To find your team ID:** Open Keychain Access, find your "Apple Development" or "Developer ID" certificate, and look for the 10-character string in parentheses (e.g., "H7V7XYVQ7D").

   **No Developer account?** Skip this step and select "Sign to Run Locally" in Xcode's Signing & Capabilities tab.

3. Open `iTerm2.xcodeproj` in Xcode.
4. Edit Scheme (Cmd-<) and set Build Configuration to **Development**.
5. Press Cmd-R to build and run.

---

## Development

### Contributing

We welcome contributions! Please read our [contribution guide](https://gitlab.com/gnachman/iterm2/-/wikis/How-to-Contribute) before submitting pull requests.

---

## Bug Reports & Issues

- **File bugs:** [iterm2.com/bugs](https://iterm2.com/bugs)
- **Issue tracker:** [GitLab Issues](https://gitlab.com/gnachman/iterm2/issues)

> **Note:** We use GitLab for issues because it provides better support for attachments.

---

## Resources

| Resource         | Link                                                              |
| ---------------- | ----------------------------------------------------------------- |
| Official Website | [iterm2.com](https://iterm2.com)                                  |
| Documentation    | [iterm2.com/documentation](https://iterm2.com/documentation.html) |
| Community        | [iTerm2 Discussions](https://gitlab.com/gnachman/iterm2/-/issues) |
| Downloads        | [iterm2.com/downloads](https://iterm2.com/downloads.html)         |

---

## License

iTerm2 is distributed under the [GPLv3](LICENSE) license.

---

## Support

If you love iTerm2, consider:

- Starring this repository
- Spreading the word
- [Sponsoring development](https://iterm2.com/donate.html)

---

<div align="center">

**Made by [George Nachman](https://github.com/gnachman) and [contributors](https://github.com/gnachman/iTerm2/graphs/contributors)**

</div>

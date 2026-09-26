# 🚀 Arch Linux + Hyprland (Lua) Dotfiles & Installation Suite

A modular, production-ready installation script and dotfiles configuration for **Arch Linux** running **Hyprland** (featuring modern **Lua configuration**), **Tide-Island dynamic island**, **Kitty terminal**, **Awww wallpaper daemon**, and the **SDDM Astronaut theme**.

Inspired by the design and structure of [JaKooLit/Arch-Hyprland](https://github.com/JaKooLit/Arch-Hyprland).

---

## 📸 Overview of the Desktop Environment

- **Window Manager**: [Hyprland](https://hypr.land) with dynamic Lua configuration (`~/.config/hypr/hyprland.lua`).
- **Dynamic Island / Status Bar**: [Tide-Island](https://github.com/enhaoswen/tide-island) powered by [Quickshell](https://quickshell.outfoxxed.me/).
- **Wallpaper Daemon**: `awww` / `awww-daemon` (the modern successor to `swww`).
- **Terminal Emulator**: [Kitty](https://sw.kovidgoyal.net/kitty/) with JetBrainsMono Nerd Font & Catppuccin theme.
- **Application Launcher**: `rofi-wayland` (`ALT + SPACE`).
- **File Manager**: `thunar` with thumbnail support, archive tools, and custom terminal action (`uca.xml`).
- **Clipboard Management**: `cliphist` with `wl-paste` watchers.
- **Screenshot Tool**: `hyprshot` (`ALT + SHIFT + S`).
- **Display Manager**: `sddm` with [SDDM Astronaut Theme](https://github.com/keyitdev/sddm-astronaut-theme).
- **Sound Architecture**: PipeWire + WirePlumber (`wpctl` hardware volume binds).

---

## 📂 Repository Structure

```
arch-hyprland-dotfiles/
├── install.sh                  # Master interactive/unattended installation script
├── README.md                   # Complete documentation & keybindings guide
├── install-scripts/            # Modular installation stages
│   ├── 00-base-and-aur.sh      # Base-devel, pacman sync, and yay installer
│   ├── 01-hypr-pkgs.sh         # Official Arch packages (Hyprland, PipeWire, Kitty, Fonts)
│   ├── 02-aur-pkgs.sh          # AUR packages (tide-island, quickshell, hyprshot, cliphist)
│   ├── 03-sddm-theme.sh        # SDDM configuration & Astronaut theme
│   ├── 04-dotfiles.sh          # Dotfiles deployment, dynamic path patching & backup
│   └── 05-gpu-check.sh         # GPU detection (NVIDIA / AMD / Intel) & Wayland flags
├── dotfiles/                   # Extracted, sanitized configuration files
│   ├── .config/
│   │   ├── hypr/
│   │   │   └── hyprland.lua    # Hyprland Lua configuration
│   │   ├── kitty/
│   │   │   ├── kitty.conf      # Kitty terminal config
│   │   │   └── colors/
│   │   │       └── colors.conf # Color theme
│   │   ├── tide-island/
│   │   │   └── userconfig.json # Dynamic Island widget config
│   │   ├── Thunar/
│   │   │   ├── accels.scm      # Thunar accelerators
│   │   │   └── uca.xml         # Custom context menu actions
│   │   ├── xfce4/xfconf/xfce-perchannel-xml/
│   │   │   └── thunar.xml      # Thunar view and hidden file preferences
│   │   └── mimeapps.list       # Default application associations
│   ├── .bashrc                 # Bash shell aliases & custom prompt
│   ├── .bash_profile
│   └── .bash_logout
└── Wallpapers/                 # Desktop wallpapers
    ├── 127218467_p0.jpg
    ├── a_cartoon_of_a_street_with_buildings.jpeg
    ├── fav.jpg
    ├── wall-06.png
    └── wallhaven-2yo6q9.jpg
```

---

## ⚡ Quick Start

### 1. Clone or Copy the Repository
```bash
git clone <your-repo-url> ~/arch-hyprland-dotfiles
cd ~/arch-hyprland-dotfiles
```

### 2. Make the Installer Executable & Run
```bash
chmod +x install.sh install-scripts/*.sh
./install.sh
```

### 3. Installation Options & Flags
You can run `install.sh` interactively or with flags:

| Flag | Description |
| :--- | :--- |
| `-y`, `--noconfirm` | Run unattended installation with automatic default confirmations. |
| `--only-dots` | Skip package installations and only deploy dotfiles and wallpapers. |
| `--skip-sddm` | Skip SDDM display manager setup and keep current display manager. |
| `--skip-gpu` | Skip graphics hardware detection and driver recommendations. |
| `-h`, `--help` | Display command usage and options. |

*Example (Unattended full installation):*
```bash
./install.sh --noconfirm
```

*Example (Only deploy dotfiles & wallpapers):*
```bash
./install.sh --only-dots
```

---

## ⌨️ Default Keybindings (`hyprland.lua`)

The modifier key is set to **`ALT`** in `hyprland.lua`.

### Core Application Shortcuts
| Keybinding | Action |
| :--- | :--- |
| <kbd>ALT</kbd> + <kbd>Return</kbd> | Launch Kitty Terminal |
| <kbd>ALT</kbd> + <kbd>Space</kbd> | Launch Rofi Application Launcher |
| <kbd>ALT</kbd> + <kbd>E</kbd> | Launch Thunar File Manager |
| <kbd>ALT</kbd> + <kbd>Q</kbd> | Close Active Window |
| <kbd>ALT</kbd> + <kbd>F</kbd> | Toggle Window Floating |
| <kbd>ALT</kbd> + <kbd>J</kbd> | Toggle Split (Dwindle layout) |
| <kbd>ALT</kbd> + <kbd>M</kbd> | Exit / Shutdown Menu (`hyprshutdown` or exit) |
| <kbd>ALT</kbd> + <kbd>Shift</kbd> + <kbd>S</kbd> | Region Screenshot (Hyprshot copied to clipboard) |

### Tide-Island Bar & Widget Shortcuts
| Keybinding | Action |
| :--- | :--- |
| <kbd>ALT</kbd> + <kbd>Tab</kbd> | Toggle Workspace Overview |
| <kbd>ALT</kbd> + <kbd>C</kbd> | Toggle Control Center |
| <kbd>ALT</kbd> + <kbd>P</kbd> | Toggle Power Menu |
| <kbd>ALT</kbd> + <kbd>N</kbd> | Toggle Notification Center |
| <kbd>ALT</kbd> + <kbd>W</kbd> | Toggle Wallpaper Picker |
| <kbd>ALT</kbd> + <kbd>/</kbd> | Toggle App Launcher via Tide |
| <kbd>ALT</kbd> + <kbd>V</kbd> | Toggle Clipboard History |
| <kbd>ALT</kbd> + <kbd>O</kbd> | Toggle File Shelf |
| <kbd>ALT</kbd> + <kbd>K</kbd> | Toggle Calendar |
| <kbd>ALT</kbd> + <kbd>T</kbd> | Toggle Timer |
| <kbd>ALT</kbd> + <kbd>Shift</kbd> + <kbd>M</kbd> | Toggle Music Player |
| <kbd>ALT</kbd> + <kbd>→</kbd> / <kbd>←</kbd> | Swipe Tide-Island Panels |
| <kbd>ALT</kbd> + <kbd>↓</kbd> | Show Clock |

### Navigation & Workspaces
| Keybinding | Action |
| :--- | :--- |
| <kbd>ALT</kbd> + <kbd>Left</kbd> / <kbd>Right</kbd> / <kbd>Up</kbd> / <kbd>Down</kbd> | Move focus in direction |
| <kbd>ALT</kbd> + <kbd>1</kbd> - <kbd>9</kbd>, <kbd>0</kbd> | Switch to workspace 1 - 10 |
| <kbd>ALT</kbd> + <kbd>Shift</kbd> + <kbd>1</kbd> - <kbd>9</kbd>, <kbd>0</kbd> | Move active window to workspace 1 - 10 |
| <kbd>ALT</kbd> + <kbd>Scroll Up</kbd> / <kbd>Down</kbd> | Cycle through workspaces |
| <kbd>ALT</kbd> + <kbd>Left Click + Drag</kbd> | Move floating window |
| <kbd>ALT</kbd> + <kbd>Right Click + Drag</kbd> | Resize floating window |

### Media & Hardware Function Keys
- <kbd>XF86AudioRaiseVolume</kbd> / <kbd>LowerVolume</kbd>: Adjust master volume (`wpctl`)
- <kbd>XF86AudioMute</kbd> / <kbd>MicMute</kbd>: Toggle audio / microphone mute (`wpctl`)
- <kbd>XF86MonBrightnessUp</kbd> / <kbd>Down</kbd>: Adjust display brightness (`brightnessctl`)
- <kbd>XF86AudioPlay</kbd> / <kbd>Pause</kbd> / <kbd>Next</kbd> / <kbd>Prev</kbd>: Media playback control (`playerctl`)

---

## 🛡️ Safety & Backups

Before overwriting any user configuration, the script checks for existing files:
- Target paths: `~/.config/hypr`, `~/.config/kitty`, `~/.config/tide-island`, `~/.config/Thunar`, `~/.config/xfce4`, `~/.bashrc`, `~/.bash_profile`, `~/.bash_logout`.
- Any existing item is backed up to a timestamped folder:
  `~/.config/dotfiles_backup_YYYYMMDD_HHMMSS/`
- All script runs produce complete logs saved in `Install-Logs/`.

---

## 🎨 Excluded Dotfiles

Per clean installation principles and your instructions, application caches and private application profiles from the original drive (such as `BraveSoftware`, `Code`, `vesktop`, `go`, and temporary `pulse/cookie`) are intentionally excluded so they do not pollute new installations.

---

## 💡 Troubleshooting

- **Quickshell / Tide-Island**: Tide-Island communicates with Quickshell via IPC socket. Ensure both `quickshell` and `tide-island` are installed from AUR.
- **NVIDIA Users**: If running on an NVIDIA GPU, step 6 (`05-gpu-check.sh`) will assist in configuring the required environment variables:
  ```lua
  hl.env("LIBVA_DRIVER_NAME", "nvidia")
  hl.env("GBM_BACKEND", "nvidia-drm")
  hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
  hl.env("NVD_BACKEND", "direct")
  ```
- **PipeWire Volume**: If volume keys don't work, verify that WirePlumber is running:
  `systemctl --user status wireplumber`

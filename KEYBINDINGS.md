# Hyprland Keybindings Reference

This configuration follows macOS and AeroSpace patterns:
- **Super (⌘)** - System/OS commands (like macOS Command key)
- **Alt (⌥)** - Window management (like AeroSpace)

## System Commands (Super/⌘)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Super + Return` | Open Terminal | Launch WezTerm terminal |
| `Super + Space` | App Launcher | Open Wofi application launcher (like Spotlight) |
| `Super + Q` | Quit Application | Close the active window |
| `Super + W` | Close Window | Alternative close command |
| `Super + Shift + Q` | Quit Hyprland | Exit the window manager |
| `Super + L` | Lock Screen | Lock the session with swaylock |
| `Super + ,` | Preferences | Open Hyprland config in editor |
| `Super + M` | Maximize | Fullscreen mode |
| `Super + H` | Hide | Minimize window |

## Screenshots (macOS-style)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Super + Shift + 3` | Full Screenshot | Capture entire screen to clipboard |
| `Super + Shift + 4` | Area Screenshot | Select area to capture to clipboard |
| `Super + Shift + 5` | Window Screenshot | Capture active window to clipboard |

## Window Management (Alt/⌥)

### Focus Movement

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Alt + H` | Focus Left | Move focus to window on the left |
| `Alt + J` | Focus Down | Move focus to window below |
| `Alt + K` | Focus Up | Move focus to window above |
| `Alt + L` | Focus Right | Move focus to window on the right |
| `Alt + ←` | Focus Left | Alternative with arrow keys |
| `Alt + ↓` | Focus Down | Alternative with arrow keys |
| `Alt + ↑` | Focus Up | Alternative with arrow keys |
| `Alt + →` | Focus Right | Alternative with arrow keys |
| `Alt + Tab` | Cycle Next | Cycle through windows forward |
| `Alt + Shift + Tab` | Cycle Previous | Cycle through windows backward |

### Window Movement

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Alt + Shift + H` | Move Left | Move window to the left |
| `Alt + Shift + J` | Move Down | Move window down |
| `Alt + Shift + K` | Move Up | Move window up |
| `Alt + Shift + L` | Move Right | Move window to the right |

### Window Resizing

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Alt + Ctrl + H` | Resize Left | Decrease width from right edge |
| `Alt + Ctrl + L` | Resize Right | Increase width from right edge |
| `Alt + Ctrl + K` | Resize Up | Decrease height from bottom edge |
| `Alt + Ctrl + J` | Resize Down | Increase height from bottom edge |

### Window States

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Alt + F` | Fullscreen | Toggle fullscreen mode |
| `Alt + V` | Float Toggle | Toggle floating/tiling mode |
| `Alt + P` | Pseudo Tile | Toggle pseudo-tiling |
| `Alt + S` | Split Toggle | Toggle split direction |

## Workspace Management (Alt/⌥)

### Workspace Navigation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Alt + 1-9,0` | Go to Workspace | Switch to workspace 1-10 |
| `Alt + [` | Previous Workspace | Go to previous workspace |
| `Alt + ]` | Next Workspace | Go to next workspace |

### Move Window to Workspace

| Keybinding | Action | Description |
|------------|--------|-------------|
| `Alt + Shift + 1-9,0` | Move to Workspace | Move active window to workspace 1-10 |
| `Alt + Shift + [` | Move to Previous | Move window to previous workspace |
| `Alt + Shift + ]` | Move to Next | Move window to next workspace |

## Special Events

| Event | Action | Description |
|-------|--------|-------------|
| Lid Close | Lock Screen | Automatically locks when laptop lid closes |
| 5 min idle | Lock Screen | Auto-lock after 5 minutes of inactivity |
| 10 min idle | Display Off | Turn off display after 10 minutes |

## Key Differences from Standard Linux WMs

This configuration intentionally differs from typical Linux window managers:

1. **Super for Apps**: Unlike most Linux WMs that use Super for window management, we use it for application/system commands (macOS-style)
2. **Alt for Windows**: Window management is on Alt, following AeroSpace conventions
3. **Vim Keys**: H/J/K/L for directional movement (left/down/up/right)
4. **Bracket Navigation**: Square brackets for workspace navigation
5. **macOS Screenshots**: Cmd+Shift+3/4/5 instead of Print Screen

## Quick Reference Card

```
System & Apps (Super/⌘)
├── Terminal:     Super + Return
├── Launcher:     Super + Space
├── Quit:         Super + Q
└── Lock:         Super + L

Windows (Alt/⌥)
├── Focus:        Alt + H/J/K/L
├── Move:         Alt + Shift + H/J/K/L
├── Resize:       Alt + Ctrl + H/J/K/L
├── Fullscreen:   Alt + F
└── Float:        Alt + V

Workspaces (Alt/⌥)
├── Switch:       Alt + [1-9,0]
├── Move to:      Alt + Shift + [1-9,0]
├── Navigate:     Alt + [ / ]
└── Move & Go:    Alt + Shift + [ / ]

Screenshots (Super/⌘ + Shift)
├── Full:         Super + Shift + 3
├── Area:         Super + Shift + 4
└── Window:       Super + Shift + 5
```

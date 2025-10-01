{ pkgs, theme, ... }:

let
  theme-attrs = (import theme { inherit pkgs; }).config;
  # Helper to remove '#' from hex colors for Hyprland
  rgb = hex: builtins.substring 1 6 hex;

  # Helper to format a Nix list of strings into a Lua table string
  toLuaTable =
    colors:
    let
      quoted = map (c: ''"${c}"'') colors;
    in
    "{ ${pkgs.lib.concatStringsSep ", " quoted} }";

  ansiColors = with theme-attrs.colors; [
    black.lighter
    red
    green
    yellow
    blue
    magenta
    cyan
    white.darker
  ];

  brightColors = with theme-attrs.colors; [
    wood.medium
    red
    green
    yellow
    blue
    magenta
    cyan
    white.base
  ];
in
{
  wayland.windowManager.hyprland.enable = true;

  home.packages = with pkgs; [
    wezterm
    mako
    polkit_gnome
    swaybg
    swww
    wofi
  ];
  fonts.fontconfig.enable = true;

  programs.wofi = {
    enable = true;
    settings = {
      terminal = "wezterm";
      show = "run";
    };
    # Wofi styling with Modus Vivendi colors
    style = ''
      window {
        background-color: ${theme-attrs.colors.background};
        border: 2px solid ${theme-attrs.colors.wood.dark};
        border-radius: 8px;
      }

      #input {
        background-color: ${theme-attrs.colors.black.lighter};
        color: ${theme-attrs.colors.foreground};
        border: none;
        padding: 8px;
      }

      #inner-box {
        background-color: ${theme-attrs.colors.background};
      }

      #outer-box {
        background-color: ${theme-attrs.colors.background};
        padding: 10px;
      }

      #scroll {
        background-color: ${theme-attrs.colors.background};
      }

      #text {
        color: ${theme-attrs.colors.foreground};
      }

      #entry:selected {
        background-color: ${theme-attrs.colors.wood.medium};
      }

      #entry:selected #text {
        color: ${theme-attrs.colors.white.base};
      }
    '';
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        enable_wayland = true,
        color_scheme = "Earthy Mid-Century",
        color_schemes = {
          ["Earthy Mid-Century"] = {
            background = "${theme-attrs.colors.background}",
            foreground = "${theme-attrs.colors.foreground}",
            cursor_bg = "${theme-attrs.colors.cursor}",
            cursor_fg = "${theme-attrs.colors.background}",
            selection_bg = "${theme-attrs.colors.wood.dark}",
            selection_fg = "${theme-attrs.colors.foreground}",
            ansi = ${toLuaTable ansiColors},
            brights = ${toLuaTable brightColors},
          },
        },
      }
    '';
  };

  programs.swaylock = {
    enable = true;
    # Swaylock configuration with Modus Vivendi colors using swaylock-effects
    settings = {
      # Use a solid color background
      color = "${rgb theme-attrs.colors.background}";
      # Or uncomment to use an image
      # image = "/path/to/your/wallpaper.png";
      # --scaling stretch

      indicator = true;
      indicator-radius = 200;
      indicator-thickness = 20;

      inside-color = "${rgb theme-attrs.colors.black.lighter}";
      inside-clear-color = "${rgb theme-attrs.colors.black.lighter}";
      inside-ver-color = "${rgb theme-attrs.colors.black.lighter}";
      inside-wrong-color = "${rgb theme-attrs.colors.black.lighter}";

      line-color = "${rgb theme-attrs.colors.wood.dark}";
      line-clear-color = "${rgb theme-attrs.colors.green}";
      line-ver-color = "${rgb theme-attrs.colors.blue}";
      line-wrong-color = "${rgb theme-attrs.colors.red}";

      ring-color = "${rgb theme-attrs.colors.wood.medium}";
      ring-clear-color = "${rgb theme-attrs.colors.green}";
      ring-ver-color = "${rgb theme-attrs.colors.blue}";
      ring-wrong-color = "${rgb theme-attrs.colors.red}";

      key-hl-color = "${rgb theme-attrs.colors.yellow}";
      separator-color = "00000000"; # Transparent

      text-color = "${rgb theme-attrs.colors.foreground}";
      text-clear-color = "${rgb theme-attrs.colors.foreground}";
      text-ver-color = "${rgb theme-attrs.colors.foreground}";
      text-wrong-color = "${rgb theme-attrs.colors.foreground}";

      effect-blur = "7x5";
      effect-vignette = "0.5:0.5";
    };
  };

  wayland.windowManager.hyprland.settings = {
    "exec-once" = [
      "waybar"
      "/usr/lib/polkit-gnome-authentication-agent-1"
      "${../../scripts/random-wallpaper.sh}"
    ];

    "$mod" = "ALT";

    # Modus Vivendi colors for Hyprland borders
    general = {
      "col.active_border" =
        "rgba(${rgb theme-attrs.colors.red}ff) rgba(${rgb theme-attrs.colors.green}ff) 45deg";
      "col.inactive_border" = "rgba(${rgb theme-attrs.colors.wood.dark}aa)";
      "border_size" = 2;
      "gaps_in" = 5;
      "gaps_out" = 10;
    };

    decoration = {
      rounding = 8;
    };

    bind = [
      "$mod, RETURN, exec, wezterm"
      "$mod, SPACE, exec, wofi --show drun"

      "$mod, Q, killactive,"
      "$mod, M, exit,"
      "$mod, V, togglefloating,"
      "$mod, P, pseudo,"
      "$mod, S, togglesplit,"
      "$mod, F, fullscreen,"

      # Screenshot a window
      "$mod, PRINT, exec, grim -g \"$(hyprctl activewindow -j | jaq -r '.at[0],.at[1],.size[0],.size[1]' | sed 's/\\n/ /g')\" - | wl-copy"
      # Screenshot a selected region
      "$mod SHIFT, PRINT, exec, grim -g \"$(slurp)\" - | wl-copy"

      # Lock screen
      "$mod, ESC, exec, swaylock"

      # Move focus with arrow keys
      "$mod, left, movefocus, l"
      "$mod, right, movefocus, r"
      "$mod, up, movefocus, u"
      "$mod, down, movefocus, d"

      # Switch workspaces with H and L
      "$mod, H, workspace, e-1"
      "$mod, L, workspace, e+1"

      # Move active window to a workspace with numbers
      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      "$mod SHIFT, 6, movetoworkspace, 6"
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"

      # Move active window to next/previous workspace with H and L
      "$mod SHIFT, H, movetoworkspace, e-1"
      "$mod SHIFT, L, movetoworkspace, e+1"

      # Switch workspaces with numbers
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
    ];

    # See https://wiki.hyprland.org/Configuring/Monitors
    monitor = "DP-4,2560x1440@144,auto,1";

    input = {
      kb_layout = "us";
      follow_mouse = 1;
      touchpad.natural_scroll = true;
    };
  };

  wayland.windowManager.hyprland.extraConfig = ''
    env = XCURSOR_THEME,${theme-attrs.cursor.name}
    env = XCURSOR_SIZE,${toString theme-attrs.cursor.size}
    windowrulev2 = fullscreen,class:^(steam_app_.*)$
  '';

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [
          "hyprland/workspaces"
          "hyprland/mode"
        ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "clock"
        ];

        "hyprland/workspaces" = {
          # Use "all-outputs = true;" if you want to see workspaces on all monitors
          # all-outputs = true;
          # Use "on-click = "activate";" to switch workspaces by clicking
          on-click = "activate";
          # Shows special workspaces like "scratchpads"
          # persistent-workspaces = { "*": [1, 2, 3, 4, 5] }; # Uncomment to show all workspaces 1-5
        };

        "hyprland/window" = {
          max-length = 35;
          separate-outputs = true; # Show window titles only on the active monitor
        };

        "clock" = {
          format = " {:%H:%M}";
          tooltip-format = "<big>{:%Y-%m-%d}</big>\n<small>{calendar}</small>";
        };

        "cpu" = {
          format = " {usage}%";
        };

        "memory" = {
          format = " {}%";
        };

        "network" = {
          format-wifi = "  {essid}";
          format-ethernet = " {ifname}";
          format-disconnected = "⚠ Disconnected";
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = "  Muted";
          format-icons = {
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "pavucontrol";
        };
      };
    };
    style = ''
      * {
        border: none;
        font-family: "${theme-attrs.fonts.monospace.family}";
        font-size: ${toString theme-attrs.fonts.monospace.size}px;
        min-height: 0;
      }

      window#waybar {
        background-color: ${theme-attrs.colors.black.lighter};
        border-bottom: 3px solid ${theme-attrs.colors.wood.dark};
        color: ${theme-attrs.colors.foreground};
      }

      #workspaces {
        background-color: ${theme-attrs.colors.background};
        margin: 2px 0px 2px 2px;
        border-radius: 5px;
      }

      #workspaces button {
        padding: 0 8px;
        margin: 2px;
        background-color: transparent;
        color: ${theme-attrs.colors.foreground};
        border-radius: 4px;
        transition: all 0.3s ease;
      }

      #workspaces button:hover {
        background-color: ${theme-attrs.colors.wood.light};
        color: ${theme-attrs.colors.black.base};
      }

      #workspaces button.active {
        background-color: ${theme-attrs.colors.red};
        color: ${theme-attrs.colors.white.base};
      }

      #workspaces button.special {
        background-color: ${theme-attrs.colors.yellow};
        color: ${theme-attrs.colors.background};
      }

      #mode {
        background-color: ${theme-attrs.colors.blue};
        color: ${theme-attrs.colors.background};
        padding: 0 8px;
        margin: 2px 0px;
        border-radius: 5px;
      }

      #window {
        color: ${theme-attrs.colors.foreground};
        background-color: ${theme-attrs.colors.background};
        padding: 0 10px;
        margin: 2px 0px;
        border-radius: 5px;
      }

      #clock, #cpu, #memory, #network, #pulseaudio {
        padding: 0 10px;
        margin: 2px 2px 2px 0px;
        color: ${theme-attrs.colors.foreground};
        background-color: ${theme-attrs.colors.background};
        border-radius: 5px;
      }

      #pulseaudio.muted {
        color: ${theme-attrs.colors.red};
      }
    '';
  };
}

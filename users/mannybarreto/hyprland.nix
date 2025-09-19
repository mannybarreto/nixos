{ pkgs, ... }:

{
  wayland.windowManager.hyprland.enable = true;

  home.packages = with pkgs; [
    bibata-cursors
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
        background-color: #000000;
        border: 2px solid #646464;
        border-radius: 8px;
      }

      #input {
        background-color: #1e1e1e;
        color: #ffffff;
        border: none;
        padding: 8px;
      }

      #inner-box {
        background-color: #000000;
      }

      #outer-box {
        background-color: #000000;
        padding: 10px;
      }

      #scroll {
        background-color: #000000;
      }

      #text {
        color: #989898;
      }

      #entry:selected {
        background-color: #535353;
      }

      #entry:selected #text {
        color: #ffffff;
      }
    '';
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        enable_wayland = true,
        color_scheme = "Modus-Vivendi",
      }
    '';
  };

  programs.swaylock = {
    enable = true;
    # Swaylock configuration with Modus Vivendi colors using swaylock-effects
    settings = {
      # Use a solid color background
      color = "000000";
      # Or uncomment to use an image
      # image = "/path/to/your/wallpaper.png";
      # --scaling stretch

      indicator = true;
      indicator-radius = 200;
      indicator-thickness = 20;

      inside-color = "1e1e1e";
      inside-clear-color = "1e1e1e";
      inside-ver-color = "1e1e1e";
      inside-wrong-color = "1e1e1e";

      line-color = "646464";
      line-clear-color = "44bc44";
      line-ver-color = "2fafff";
      line-wrong-color = "ff5f59";

      ring-color = "303030";
      ring-clear-color = "44bc44";
      ring-ver-color = "2fafff";
      ring-wrong-color = "ff5f59";

      key-hl-color = "c6daff";
      separator-color = "00000000"; # Transparent

      text-color = "ffffff";
      text-clear-color = "ffffff";
      text-ver-color = "ffffff";
      text-wrong-color = "ffffff";

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

    "$mod" = "SUPER";

    # Modus Vivendi colors for Hyprland borders
    general = {
      "col.active_border" = "rgba(47afffff) rgba(00d3d0ff) 45deg";
      "col.inactive_border" = "rgba(646464aa)";
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
      "$mod, J, togglesplit,"
      "$mod, F, fullscreen,"

      # Screenshot a window
      "$mod, PRINT, exec, grim -g \"$(hyprctl activewindow -j | jaq -r '.at[0],.at[1],.size[0],.size[1]' | sed 's/\\n/ /g')\" - | wl-copy"
      # Screenshot a selected region
      "$mod SHIFT, PRINT, exec, grim -g \"$(slurp)\" - | wl-copy"

      # In wayland.windowManager.hyprland.settings.bind
      "$mod, L, exec, swaylock"

      "$mod, L, movefocus, r"
      "$mod, H, movefocus, l"
      "$mod, K, movefocus, u"
      "$mod, J, movefocus, d"

      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"

      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      "$mod SHIFT, 6, movetoworkspace, 6"
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"
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
    env = XCURSOR_THEME,Bibata-Modern-Classic
    env = XCURSOR_SIZE,24
    windowrulev2 = fullscreen,class:^(steam_app_.*)$
  '';

  gtk = {
    enable = true;
    # No official Modus Vivendi GTK theme in nixpkgs.
    # Consider a similar dark theme like 'Adwaita-dark' or 'Dracula'.
    theme = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-icon-theme; # Adwaita is part of this
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };
    font = {
      name = "MesloLGM Nerd Font";
      size = 11;
    };
  };

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
    # Waybar styling with Modus Vivendi colors
    style = ''
      * {
        border: none;
        font-family: "MesloLGM Nerd Font";
        font-size: 14px;
        min-height: 0;
      }

      window#waybar {
        background-color: #000000;
        border-bottom: 2px solid #646464;
        color: #ffffff;
      }

      #workspaces button {
        padding: 0 8px;
        background-color: transparent;
        color: #989898;
        border-radius: 4px;
      }

      #workspaces button.active {
        background-color: #535353;
        color: #ffffff;
      }

      #workspaces button.special {
        background-color: #feacd0;
        color: #000000;
      }

      #mode {
        background-color: #2fafff;
        color: #000000;
        padding: 0 8px;
      }

      #clock, #cpu, #memory, #network, #pulseaudio {
        padding: 0 10px;
        margin: 0 2px;
        color: #c6daff;
      }

      #pulseaudio.muted {
        color: #ff5f59;
      }
    '';
  };
}

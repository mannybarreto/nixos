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
      "show" = "run";
    };
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        enable_wayland = false,
      }
    '';
  };

  wayland.windowManager.hyprland.settings = {
    "exec-once" = [
      "waybar"
      "/usr/lib/polkit-gnome-authentication-agent-1"
      "swaybg -c  '#000000'"
    ];

    "$mod" = "SUPER";

    bind = [
      "$mod, RETURN, exec, wezterm"
      "$mod, SPACE, exec, wofi --show drun"

      "$mod, Q, killactive,"
      "$mod, M, exit,"
      "$mod, V, togglefloating,"
      "$mod, P, pseudo,"
      "$mod, J, togglesplit,"

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
    monitor = ",preferred,auto,1";

    input = {
      kb_layout = "us";
      follow_mouse = 1;
      touchpad.natural_scroll = true;
    };
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
  };

  wayland.windowManager.hyprland.extraConfig = ''
    env = XCURSOR_THEME,Bibata-Modern-Classic
    env = XCURSOR_SIZE,24
    exec-once = ${./scripts/random-wallpaper.sh}
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
          format-muted = " Muted";
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
          font-family: "JetBrainsMono Nerd Font";
          font-size: 14px;
          min-height: 0;
      }

      window#waybar {
          background-color: rgba(29, 32, 41, 0.7); /* Slightly different background for a new look */
          border-bottom: 2px solid rgba(100, 114, 125, 0.5);
          color: #cdd6f4; /* Catppuccin Macchiato Text */
      }

      #workspaces button {
          padding: 0 8px;
          background-color: transparent;
          color: #cdd6f4;
          border-radius: 4px;
      }

      #workspaces button.active {
          background-color: #89b4fa; /* Catppuccin Macchiato Blue */
          color: #1e1e2e; /* Catppuccin Macchiato Base */
      }

      #workspaces button.special {
          background-color: #f38ba8; /* Catppuccin Macchiato Red for special workspace */
      }

      #mode {
          background-color: #f38ba8;
          color: #1e1e2e;
          padding: 0 8px;
      }

      #clock, #cpu, #memory, #network, #pulseaudio {
          padding: 0 10px;
          margin: 0 2px;
      }
    '';
  };
}

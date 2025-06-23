{ pkgs, ... }:

{
  wayland.windowManager.hyprland.enable = true;

  home.packages = with pkgs; [
    bibata-cursors
    wezterm
    mako
    fuzzel
    polkit_gnome
  ];
  fonts.fontconfig.enable = true;

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
      "/usr/lib/polkit-gnome-authentication-agent-1"
    ];

    "$mod" = "SUPER";

    bind = [
      "$mod, RETURN, exec, wezterm"
      "$mod, SPACE, exec, fuzzel"

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

      "$mod, 1, movetoworkspace, 1"
      "$mod, 2, movetoworkspace, 2"
      "$mod, 3, movetoworkspace, 3"
      "$mod, 4, movetoworkspace, 4"
      "$mod, 5, movetoworkspace, 5"
      "$mod, 6, movetoworkspace, 6"
      "$mod, 7, movetoworkspace, 7"
      "$mod, 8, movetoworkspace, 8"
      "$mod, 9, movetoworkspace, 9"
    ];

    # See https://wiki.hyprland.org/Configuring/Monitors
    monitor = ",preferred,auto,1";

   # input = {
    #  kb_layout = "us";
    #  follow_mouse = 1;
    #  touchpad.natural_scroll = true;
   # };

   # gtk = {
  #    enable = true;
    #  theme = {
    #    name = "Bibata-Modern-Classic";
   #     package = pkgs.bibata-cursors;
    #  };
    #  font = {
    #    name = "JetBrainsMono Nerd Font";
   #     size = 14;
  #    };
 #   };

  };
}

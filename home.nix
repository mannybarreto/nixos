{ pkgs, ... }:

{
  home.packages = with pkgs; [
    btop
    chromium
    exactaudiocopy
    gimp3
    grim
    makemkv
    mpv
    nixd
    pamixer
    pavucontrol
    slurp
    wget
    yazi
  ];

  imports = [
    ./hyprland.nix
    ./development.nix
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "yazi.desktop" ];
    };
  };

  xdg.desktopEntries.yazi = {
    name = "Yazi";
    exec = "wezterm start --cwd %f -- yazi"; # Adjust as needed
  };

  programs.home-manager.enable = true;

  home.stateVersion = "25.05";
}

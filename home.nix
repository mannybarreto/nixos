{ pkgs, ... }:

{
  home.packages = with pkgs; [
    btop
    chromium
    git
    gimp3
    mpv
    nixd
    pamixer
    pavucontrol
    vim
    wget
    yazi
    zed-editor
  ];

  imports = [
    ./hyprland.nix
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "25.05";
}

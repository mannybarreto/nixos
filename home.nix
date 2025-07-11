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

  programs.home-manager.enable = true;

  home.stateVersion = "25.05";
}

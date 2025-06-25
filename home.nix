{ pkgs, ... }:

{
  home.packages = with pkgs; [
    btop
    chromium
    exactaudiocopy
    git
    gimp3
    grim
    makemkv
    mpv
    nixd
    pamixer
    pavucontrol
    slurp
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

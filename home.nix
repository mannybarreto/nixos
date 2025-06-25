{ pkgs, ... }:

{
  home.packages = with pkgs; [
    chromium
    vim
    wget
    git
    nixd
    zed-editor
  ];

  imports = [
    ./hyprland.nix
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "25.05";
}

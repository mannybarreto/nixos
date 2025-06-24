{ pkgs, ... }:

{
  home.packages = with pkgs; [
    chromium
    vim
    wget
    git
  ];

  imports = [
    ./hyprland.nix
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "25.05";
}

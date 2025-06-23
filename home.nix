{ pkgs, ... }:

{
  home.packages = with pkgs; [
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

{ pkgs, lib, ... }:

let
  theme = import ../../modules/themes/earthy-mid-century/default.nix { inherit pkgs; };
  colors = theme.config.colors;
in
{
  home.packages = with pkgs; [
    btop
    chromium
    gimp3
    grim
    makemkv
    mpv
    nerd-fonts.jetbrains-mono
    nixd
    pamixer
    pavucontrol
    slurp
    wget
    mc
  ];

  imports = [
    ./hyprland.nix
    ../../modules/home-manager/development.nix
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "mc.desktop" ];
    };
  };

  xdg.desktopEntries.mc = {
    name = "Midnight Commander";
    exec = "mc %f";
    terminal = true;
  };

  programs.mc = {
    enable = true;
  };

  

  programs.home-manager.enable = true;

  home.stateVersion = "25.05";
}

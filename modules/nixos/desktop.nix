{ pkgs, inputs, ... }:

{
  # System wide hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
  };

  # Enable the X11 windowing system
  services.xserver.enable = true;

  services.displayManager.gdm.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };
}

# modules/nixos/godot.nix
{ pkgs, ... }:

{
  # Add system-level dependencies for Godot C++ and Rust development.
  # These are often required for building GDExtensions and godot-rust crates.
  environment.systemPackages = with pkgs; [
    # Build essentials
    pkg-config

    # Libraries for Godot compilation and running
    xorg.libX11
    xorg.libXcursor
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXi
    alsa-lib
    udev
    openssl
    vulkan-loader
  ];
}

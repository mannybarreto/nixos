# modules/home-manager/godot.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Godot Engine with Mono support (for C#)
    # This version is also perfectly suitable for C++ and Rust development.
    godot-mono

    # Rust development environment
    rustup
  ];
}

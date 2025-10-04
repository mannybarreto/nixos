# modules/home-manager/godot.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Godot Engine with Mono support (for C#)
    # This version is also perfectly suitable for C++ and Rust development.
    godot-mono

    # C++ development environment
    clang_17 # C++ compiler
    lld # Linker, often faster than ld
    (symlinkJoin {
      name = "clang-toolchain";
      paths = [ clang_17 lld ];
    })

    # Rust development environment
    rustup
  ];
}

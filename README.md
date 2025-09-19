# nixos-config

This repository contains my personal NixOS configuration, organized in a modular way.

## Configuration Structure

The configuration is broken down into the following directories:

-   `hosts`: Contains the main configuration for each host machine. Each subdirectory corresponds to a different host.
    -   `default`: The default host configuration.
        -   `configuration.nix`: The main entry point for the NixOS configuration.
        -   `hardware-configuration.nix`: Hardware-specific settings for the host.
-   `modules`: Contains reusable modules that can be imported into different configurations.
    -   `home-manager`: Modules related to Home Manager.
    -   `nixos`: Modules related to NixOS system configuration.
-   `users`: Contains user-specific configurations.
    -   `mannybarreto`: Configuration for the `mannybarreto` user.
        -   `home.nix`: The main entry point for the user's Home Manager configuration.
        -   `hyprland.nix`: Specific configuration for the Hyprland window manager.
-   `secrets`: Contains sensitive data that is encrypted with sops.
-   `scripts`: Contains useful scripts.
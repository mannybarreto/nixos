{ pkgs, ... }:

{
  # --- Virtualization ---

  # Enable Podman (container runtime)
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Creates docker alias for podman
    defaultNetwork.settings.dns_enabled = true;
  };

  hardware.nvidia-container-toolkit.enable = true;

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    distrobox
    podman
    nvidia-container-toolkit

    (pkgs.writeShellScriptBin "unreal" ''
      #!/usr/bin/env bash
      distrobox enter unreal -- bash -c '
        cd ~/distrobox/unreal/
        ./unreal.bash
      '
    '')
  ];

  environment.etc."distrobox/distrobox.conf".text = ''
    container_additional_volumes="/nix/store:/nix/store:ro /etc/profiles/per-user:/etc/profiles/per-user:ro /etc/static/profiles/per-user:/etc/static/profiles/per-user:ro /run/opengl-driver:/run/opengl-driver:ro /run/opengl-driver-32:/run/opengl-driver-32:ro"
  '';
}

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/audiophile.nix
    ../../modules/nixos/nfs.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "battlestation"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.groups.secret-readers = { };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  # List services that you want to enable:

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # For bash
  programs.bash.interactiveShellInit = ''
    if [[ -r "${config.sops.secrets.data.path}" ]] && groups | grep -q secret-readers; then
      set -a
      source "${config.sops.secrets.data.path}"
      set +a
    fi
  '';

  # For fish (if enabled)
  programs.fish.interactiveShellInit = ''
    if test -r "${config.sops.secrets.data.path}"; and groups | grep -q secret-readers
      while read -l line
        if string match -q -r '^[^#].*=' $line
          set -l parts (string split -m 1 '=' $line)
          if test (count $parts) -eq 2
            set -gx $parts[1] $parts[2]
          end
        end
      end < "${config.sops.secrets.data.path}"
    end
  '';

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  services.ollama = {
    enable = true;
    acceleration = "cuda";
    loadModels = [
      "gemma3:4b"
      "gemma3:12b"
    ];
  };
}
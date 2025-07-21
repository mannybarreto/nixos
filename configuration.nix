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
    ./gaming.nix
    # ./env-secrets.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with `passwd`.
  users.users.mannybarreto = {
    isNormalUser = true;
    description = "Manny Barreto";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  # List services that you want to enable:

  # System wide hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
  };

  # Enable the X11 windowing system
  services.xserver.enable = true;

  services.displayManager.gdm.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  environment.systemPackages = with pkgs; [
    nfs-utils
  ];

  # --- SOPS ---
  sops.defaultSopsFile = ./secrets/env_vars;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt"; # It's assumed this file is generated and secrets are encrypted for it.
  sops.age.generateKey = false;
  sops.secrets.data = { };

  systemd.services.create-nas-env-file = {
    description = "Create environment file for NAS mounts";
    wantedBy = [ "multi-user.target" ];
    after = [ "sops-nix.service" ];
    before = [
      "mnt-movies.mount"
      "mnt-music.mount"
    ];
    script = ''
      set -euo pipefail
      mkdir -p /run/sysconfig
      echo $(<${config.sops.secrets.data.path}) > /run/sysconfig/nas-env
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # Make secrets available as environment variables in shells
  environment.etc."profile.d/secrets.sh" = {
    mode = "0755";
    text = ''
      if [ -f "/run/sysconfig/nas-env" ]; then
        set -a
        source "/run/sysconfig/nas-env"
        set +a
      fi
    '';
  };

  # --- Mount Network Drives ---
  systemd.mounts = [
    {
      where = "/mnt/movies";
      what = "\${HS_NAS}:/data/Movies";
      type = "nfs";
      options = "defaults,rw,noauto,x-systemd.automount,x-systemd.idle-timeout=600";
      mountConfig = {
        EnvironmentFile = "/run/sysconfig/nas-env";
      };
      requires = [ "create-nas-env-file.service" ];
      after = [ "create-nas-env-file.service" ];
    }
    {
      where = "/mnt/music";
      what = "\${HS_NAS}:/data/Music";
      type = "nfs";
      options = "defaults,rw,noauto,x-systemd.automount,x-systemd.idle-timeout=600";
      mountConfig = {
        EnvironmentFile = "/run/sysconfig/nas-env";
      };
      requires = [ "create-nas-env-file.service" ];
      after = [ "create-nas-env-file.service" ];
    }
  ];

  # --- NFS Firewall Rules ---
  networking.firewall.allowedTCPPorts = [ 2049 ];
  networking.firewall.allowedUDPPorts = [ 2049 ];

  # --- Fish ---
  programs.fish = {
    enable = true;
  };
  users.defaultUserShell = pkgs.fish;

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

  fonts.packages = with pkgs; [
    nerd-fonts.meslo-lg
  ];
  fonts.fontconfig.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}

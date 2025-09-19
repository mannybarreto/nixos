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
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/audiophile.nix
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

  users.groups.secret-readers = { };

  # Define a user account. Don't forget to set a password with `passwd`.
  users.users.mannybarreto = {
    isNormalUser = true;
    description = "Manny Barreto";
    extraGroups = [
      "networkmanager"
      "wheel"
      "secret-readers"
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

  # --- Sops ---
  sops.defaultSopsFile = ../../secrets/env_vars;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = false;

  # Define individual secrets
  sops.secrets.data = {
    group = "secret-readers";
    mode = "0440";
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

  systemd.services."mount-nfs-shares" = {
    description = "Mount NFS shares";
    after = [
      "network-online.target"
      "sops-nix.service"
    ];
    wants = [
      "network-online.target"
      "sops-nix.service"
    ];
    wantedBy = [ "multi-user.target" ]; # Start at boot
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SupplementaryGroups = [ "secret-readers" ];
    };
    path = [
      pkgs.util-linux
      pkgs.nfs-utils
    ];
    script = ''
      source ${config.sops.secrets.data.path}

      # Create mount points if they don't exist
      mkdir -p /mnt/movies /mnt/music

      # Mount the shares
      mount -t nfs -o defaults,rw $HS_NAS:/data/Movies /mnt/movies
      mount -t nfs -o defaults,rw $HS_NAS:/data/Music /mnt/music
    '';
    preStop = ''
      umount /mnt/movies || true
      umount /mnt/music || true
    '';
  };

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

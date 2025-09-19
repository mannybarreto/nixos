{ pkgs, ... }:

{
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

  # --- Sops ---
  sops.defaultSopsFile = ../../secrets/env_vars;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = false;

  # Define individual secrets
  sops.secrets.data = {
    group = "secret-readers";
    mode = "0440";
  };

  # --- Fish ---
  programs.fish = {
    enable = true;
  };
  users.defaultUserShell = pkgs.fish;

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

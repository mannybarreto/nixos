{ pkgs, ... }:

{
  # ... other configuration options

  # 1. Install necessary packages for audiophile ripping
  environment.systemPackages = with pkgs; [
    cmus # Music player

    whipper # The core CD ripper
    cdrdao # A required backend for whipper for TOC analysis
    flac # To ensure the FLAC command-line tools are available

    # Optional but highly recommended for metadata management
    picard # MusicBrainz Picard for post-rip tag perfection
    vorta # A GUI for BorgBackup, perfect for backing up your new library
  ];

  # 2. Configure your optical drive for reliable access
  # This ensures the drive is consistently available at a known location.
  #
  # First, find your drive's device name by running `lsblk` in a terminal.
  # It will likely be /dev/sr0 or /dev/cdrom.

  # Mount your optical drive
  # Replace /dev/sr0 with the actual device name of your optical drive
  # You can find it by running `lsblk` in the terminal
  fileSystems."/media/cdrom" = {
    device = "/dev/sr0";
    fsType = "iso9660";
    options = [
      "ro"
      "user"
      "noauto"
      "nofail"
    ];
  };

  users.users.mannybarreto = {
    # ... other settings like isNormalUser, home, etc.
    extraGroups = [
      "wheel"
      "networkmanager"
      "cdrom"
    ];
  };
}

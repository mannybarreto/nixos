{ pkgs, config, ... }:

{
  environment.systemPackages = with pkgs; [
    nfs-utils
  ];

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
}

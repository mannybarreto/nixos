{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    steam-run
    lutris
    discord-ptb
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
}

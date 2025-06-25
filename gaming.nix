{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    steam-run
    mangohud
    lutris
    discord-ptb
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.gamemode.enable = true;
}

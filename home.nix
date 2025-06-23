{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vim
    wget
    git
  ];

  home.stateVersion = "25.05";
}

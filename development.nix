{ pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    vim
    zed-editor
  ];
}

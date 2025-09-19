{
  config,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    age
    gemini-cli
    git
    sops
    vim
    zed-editor
  ];

  sops = {
    age.keyFile = "/home/${config.home.username}/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets/env_vars;
  };

  programs.fish = {
    enable = true;
  };

}

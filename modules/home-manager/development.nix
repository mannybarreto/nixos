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
    vscode
    zed-editor

    # Build and development tools
    cmake
    ninja
    python3
    nodejs
  ];

  sops = {
    age.keyFile = "/home/${config.home.username}/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets/env_vars;
  };

  programs.fish = {
    enable = true;
  };

  # Configure git for development
  programs.git = {
    enable = true;
  };

}

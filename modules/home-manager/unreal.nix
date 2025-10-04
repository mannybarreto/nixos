{
  config,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    # Essential tools for Unreal Engine development
    git-lfs
    cmake
    ninja
    python3
    nodejs
    unzip
    zip
    wget
    curl

    # Build Tools for UE development
    meson
    autoconf
    automake
    libtool

    # Container integration tools for Unreal development
    distrobox
  ];

  # Configure git-lfs for Unreal Engine assets
  programs.git = {
    lfs.enable = true;
    extraConfig = {
      # Unreal Engine specific git configuration
      core = {
        autocrlf = false;
        filemode = false;
      };
      # Large file handling for Unreal assets
      filter = {
        lfs = {
          clean = "git-lfs clean -- %f";
          smudge = "git-lfs smudge -- %f";
          process = "git-lfs filter-process";
          required = true;
        };
      };
    };
  };

  # Configure environment variables for Unreal Engine development
  home.sessionVariables = {
    # Unreal Engine environment - using actual distrobox installation path
    UE_ENGINE_LOCATION = "$HOME/distrobox/unreal/Linux_Unreal_Engine_5.6.1";
    UE_PROJECTS_DIR = "$HOME/distrobox/unreal/Projects";

    # .NET development for Unreal Engine
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE = "1";
  };

  # Create Unreal Engine development directories
  home.file = {
    # Ensure projects directory exists
    ".local/share/unreal/.keep".text = "";
  };

  # XDG associations for Unreal Engine project files
  xdg.mimeApps.defaultApplications = {
    "application/x-unreal-project" = [ "unreal.desktop" ];
    "application/x-unreal-map" = [ "unreal.desktop" ];
  };

  # Create desktop entry for Unreal Engine launcher
  xdg.desktopEntries.unreal = {
    name = "Unreal Engine";
    comment = "Launch Unreal Engine 5.6.1 in distrobox container";
    exec = "unreal";
    icon = "unreal-engine";
    categories = [
      "Development"
      "Game"
    ];
    terminal = false;
    startupNotify = true;
  };
}

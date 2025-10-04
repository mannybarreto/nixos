{
  config,
  pkgs,
  ...
}:

{
  # Packages for Unreal Engine development
  home.packages = with pkgs; [
    git-lfs # For Unreal Engine assets
  ];

  # Environment variables for Unreal Engine
  home.sessionVariables = {
    UE_ENGINE_LOCATION = "/home/${config.home.username}/distrobox/unreal/Linux_Unreal_Engine_5.6.1";
    UE_PROJECTS_DIR = "/home/${config.home.username}/distrobox/unreal/Projects";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
  };
}
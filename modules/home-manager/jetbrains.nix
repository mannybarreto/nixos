{
  config,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    # JetBrains Rider IDE
    jetbrains.rider

    # C++ Development Tools
    clang
    lldb
    gdb
    cmake
    ninja
    gnumake
    pkg-config

    # .NET Development
    dotnet-sdk_8
    dotnet-runtime_8
    dotnet-aspnetcore_8

    # Build Tools
    meson
    autoconf
    automake
    libtool

    # Performance and Debugging
    valgrind
    perf-tools
    strace
    ltrace

    # Additional Development Utilities
    ripgrep
    fd
    tree
    jq
    xmlstarlet

  ];

  # Configure environment variables for development
  home.sessionVariables = {
    # C++ development
    CC = "clang";
    CXX = "clang++";
  };

  # XDG associations for JetBrains Rider
  xdg.mimeApps.defaultApplications = {
    "text/x-csharp" = [ "jetbrains-rider.desktop" ];
    "text/x-c++src" = [ "jetbrains-rider.desktop" ];
    "text/x-chdr" = [ "jetbrains-rider.desktop" ];
    "application/x-ms-dos-executable" = [ "jetbrains-rider.desktop" ];
  };

  # Create JetBrains Rider desktop entry
  xdg.desktopEntries.jetbrains-rider = {
    name = "JetBrains Rider";
    comment = "Cross-platform .NET IDE";
    exec = "${pkgs.jetbrains.rider}/bin/rider %F";
    icon = "jetbrains-rider";
    categories = [
      "Development"
      "IDE"
    ];
    mimeType = [
      "text/x-csharp"
      "text/x-c++src"
      "text/x-chdr"
    ];
    startupNotify = true;
  };
}

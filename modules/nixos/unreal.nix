{ pkgs, ... }:

let
  containerName = "unreal";
  ueEnginePath = "$HOME/distrobox/unreal/Linux_Unreal_Engine_5.6.1";
  ueProjectsDir = "$HOME/distrobox/unreal/Projects";
in
{
  # --- Virtualization ---
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  hardware.nvidia-container-toolkit.enable = true;

  environment.systemPackages = with pkgs; [
    distrobox
    podman
    nvidia-container-toolkit
    vulkan-loader

    # --- Unreal Engine Launcher ---
    (pkgs.writeShellScriptBin "unreal" ''
      #!/usr/bin/env bash
      echo "Launching Unreal Editor..."
      distrobox enter ${containerName} -- bash -c '
        export SDL_VIDEODRIVER=wayland
        export VK_ICD_FILENAMES=/run/host/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
        export LD_LIBRARY_PATH=/run/host/run/opengl-driver/lib:$LD_LIBRARY_PATH
        cd ${ueEnginePath}/Engine/Binaries/Linux/
        ./UnrealEditor -vulkan "$@"
      ' -- "$@"
    '')

    # --- JetBrains Rider Launcher for Unreal ---
    (pkgs.writeShellScriptBin "unreal-rider" ''
      #!/usr/bin/env bash
      echo "Launching JetBrains Rider for Unreal Engine..."
      # Environment is set via home-manager, this just launches the binary
      exec rider "$@"
    '')

    # --- Unreal Build Helper ---
    (pkgs.writeShellScriptBin "unreal-build" ''
      #!/usr/bin/env bash
      set -euo pipefail
      show_help() {
          echo "Unreal Engine Build Helper"
          echo "Usage: $0 [command] [project.uproject] [options]"
          echo "Commands:"
          echo "  build [config] [platform]  - Build project (Default: Development Linux)"
          echo "  generate                   - Generate project files"
          echo "  clean                      - Clean project"
      }

      if [ -z "$2" ]; then
          show_help
          exit 1
      fi

      PROJECT_FILE="$2"
      if [ ! -f "$PROJECT_FILE" ]; then
          echo "Error: Project file not found at '$PROJECT_FILE'"
          show_help
          exit 1
      fi
      PROJECT_NAME=$(basename "$PROJECT_FILE" .uproject)
      PROJECT_DIR=$(dirname "$PROJECT_FILE")

      case "''${1:-help}" in
          "build")
              CONFIG="''${3:-Development}"
              PLATFORM="''${4:-Linux}"
              echo "Building $PROJECT_NAME ($CONFIG/$PLATFORM)..."
              distrobox enter ${containerName} -- bash -c "
                  cd $PROJECT_DIR
                  ${ueEnginePath}/Engine/Build/BatchFiles/Linux/Build.sh \
                      $PROJECT_NAME $PLATFORM $CONFIG -project=\\"$PROJECT_FILE\\" -progress
              "
              ;;
          "generate")
              echo "Generating project files for $PROJECT_NAME..."
              distrobox enter ${containerName} -- bash -c "
                  ${ueEnginePath}/Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool \
                      -projectfiles -project=\\"$PROJECT_FILE\\" -game -rocket -progress
              "
              ;;
          "clean")
              echo "Cleaning project: $PROJECT_NAME"
              rm -rf "$PROJECT_DIR/Binaries" "$PROJECT_DIR/Intermediate" "$PROJECT_DIR/.vs" "$PROJECT_DIR"/*.sln
              echo "Project cleaned."
              ;;
          *)
              show_help
              ;;
      esac
    '')

    # --- Unreal Debug Helper ---
    (pkgs.writeShellScriptBin "unreal-debug" ''
      #!/usr/bin/env bash
      set -euo pipefail
      show_help() {
          echo "Unreal Engine Debug Helper"
          echo "Usage: $0 [command] [project.uproject]"
          echo "Commands:"
          echo "  launch  - Launch project with GDB"
          echo "  attach  - Attach GDB to running UnrealEditor process"
      }

      case "''${1:-help}" in
          "launch")
              PROJECT_FILE="$2"
              if [ ! -f "$PROJECT_FILE" ]; then echo "Error: Project file not found."; exit 1; fi
              echo "Launching $PROJECT_FILE with GDB..."
              distrobox enter ${containerName} -- bash -c "
                  export SDL_VIDEODRIVER=wayland
                  export VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
                          export LD_LIBRARY_PATH=/run/opengl-driver/lib:$LD_LIBRARY_PATH                  gdb --args ${ueEnginePath}/Engine/Binaries/Linux/UnrealEditor \\"$PROJECT_FILE\\" -vulkan
              "
              ;;
          "attach")
              echo "Attaching GDB to UnrealEditor process..."
              distrobox enter ${containerName} -- bash -c '
                  PID=$(pgrep UnrealEditor | head -n 1)
                  if [ -z "$PID" ]; then
                      echo "UnrealEditor process not found."
                      exit 1
                  fi
                  echo "Attaching to PID: $PID"
                  gdb -p $PID
              '
              ;;
          *)
              show_help
              ;;
      esac
    '')
  ];

  environment.etc."distrobox/distrobox.conf".text = ''
    container_additional_volumes="/nix/store:/nix/store:ro /etc/profiles/per-user:/etc/profiles/per-user:ro /etc/static/profiles/per-user:/etc/static/profiles/per-user:ro /run/opengl-driver:/run/opengl-driver:ro /run/opengl-driver-32:/run/opengl-driver-32:ro"
  '';
}

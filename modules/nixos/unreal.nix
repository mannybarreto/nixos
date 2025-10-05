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

      # Ensure projects directory exists
      mkdir -p "${ueProjectsDir}"

      distrobox enter ${containerName} -- bash -c "
        export SDL_VIDEODRIVER=x11
        export VK_ICD_FILENAMES=/run/host/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
        export LD_LIBRARY_PATH=/run/host/run/opengl-driver/lib:\$LD_LIBRARY_PATH

        # Set Unreal Engine paths to use distrobox directories
        export UE_INSTALL_LOCATION='${ueEnginePath}'
        export UNREAL_ENGINE_PATH='${ueEnginePath}'

        # Configure default directories for Unreal
        mkdir -p \"\$HOME/distrobox/unreal/UnrealEngine\"
        mkdir -p \"\$HOME/distrobox/unreal/Library\"

        # Set environment to redirect Unreal's default paths
        export UE_USER_PROJECT_DIR='${ueProjectsDir}'
        export UE_USER_LIBRARY_DIR=\"\$HOME/distrobox/unreal/Library\"
        export UE_USER_LOG_DIR=\"\$HOME/distrobox/unreal/UnrealEngine/Logs\"
        export UE_USER_SAVED_DIR=\"\$HOME/distrobox/unreal/UnrealEngine/Saved\"

        cd '${ueEnginePath}/Engine/Binaries/Linux/'
        ./UnrealEditor -vulkan \"\$@\"
      " -- "$@"
    '')

    # --- JetBrains Rider Launcher for Unreal ---
    (pkgs.writeShellScriptBin "unreal-rider" ''
      #!/usr/bin/env bash
      set -euo pipefail

      show_help() {
          echo "Unreal Rider - JetBrains Rider launcher for Unreal Engine projects"
          echo "Usage: $0 [project.uproject|solution.sln] [options]"
          echo ""
          echo "This script handles project file generation through distrobox before launching Rider."
          echo ""
          echo "Options:"
          echo "  --generate-only    Only generate project files, don't launch Rider"
          echo "  --help             Show this help message"
      }

      # Parse arguments
      PROJECT_FILE=""
      GENERATE_ONLY=false

      for arg in "$@"; do
          case "$arg" in
              --help|-h)
                  show_help
                  exit 0
                  ;;
              --generate-only)
                  GENERATE_ONLY=true
                  ;;
              *.uproject|*.sln)
                  PROJECT_FILE="$arg"
                  ;;
          esac
      done

      # If a .uproject file was provided, generate project files first
      if [[ -n "$PROJECT_FILE" ]] && [[ "$PROJECT_FILE" == *.uproject ]]; then
          if [[ ! -f "$PROJECT_FILE" ]]; then
              echo "Error: Project file not found: $PROJECT_FILE"
              exit 1
          fi

          echo "Generating project files for $PROJECT_FILE..."

          # Get absolute path to project file
          PROJECT_FILE_ABS=$(realpath "$PROJECT_FILE")
          PROJECT_DIR=$(dirname "$PROJECT_FILE_ABS")
          PROJECT_NAME=$(basename "$PROJECT_FILE_ABS" .uproject)

          # Generate project files inside distrobox
          distrobox enter ${containerName} -- bash -c "
              cd '${ueEnginePath}'
              if [[ -f 'Engine/Build/BatchFiles/Linux/GenerateProjectFiles.sh' ]]; then
                  ./Engine/Build/BatchFiles/Linux/GenerateProjectFiles.sh \
                      -Rider -Automated -OnlyPrimaryProjectFile -Minimize -NoMutex \
                      -Log=/tmp/UBT_GPF_$$.txt \
                      '$PROJECT_FILE_ABS'
              else
                  echo 'Error: GenerateProjectFiles.sh not found in Unreal Engine directory'
                  exit 1
              fi
          "

          if [[ $? -ne 0 ]]; then
              echo "Error: Failed to generate project files"
              exit 1
          fi

          echo "Project files generated successfully"

          # Update PROJECT_FILE to the generated .sln file
          SOLUTION_FILE="$PROJECT_DIR/$PROJECT_NAME.sln"
          if [[ -f "$SOLUTION_FILE" ]]; then
              PROJECT_FILE="$SOLUTION_FILE"
          else
              echo "Warning: Expected solution file not found at $SOLUTION_FILE"
          fi
      fi

      # Exit if only generating
      if [[ "$GENERATE_ONLY" == "true" ]]; then
          exit 0
      fi

      # Set up environment for Rider
      export UE_ENGINE_LOCATION="${ueEnginePath}"
      export UE_PROJECTS_DIR="${ueProjectsDir}"

      # Launch Rider
      echo "Launching JetBrains Rider..."
      if [[ -n "$PROJECT_FILE" ]]; then
          exec rider "$PROJECT_FILE"
      else
          exec rider "$@"
      fi
    '')

    # --- GenerateProjectFiles wrapper for Rider ---
    (pkgs.writeShellScriptBin "GenerateProjectFiles.sh" ''
      #!/usr/bin/env bash
      # This wrapper allows Rider to call GenerateProjectFiles.sh through distrobox

      # Pass all arguments to the actual GenerateProjectFiles.sh inside distrobox
      exec distrobox enter ${containerName} -- bash -c "
          cd '${ueEnginePath}'
          ./Engine/Build/BatchFiles/Linux/GenerateProjectFiles.sh $*
      "
    '')

    # --- Rider Configuration Helper for Unreal Engine ---
    (pkgs.writeShellScriptBin "rider-configure-unreal" ''
      #!/usr/bin/env bash
      set -euo pipefail

      echo "Configuring JetBrains Rider for Unreal Engine development..."

      # Find Rider config directory
      RIDER_CONFIG_DIR="$HOME/.config/JetBrains"
      RIDER_DIRS=($(find "$RIDER_CONFIG_DIR" -maxdepth 1 -name "Rider*" -type d 2>/dev/null | sort -V))

      if [ ''${#RIDER_DIRS[@]} -eq 0 ]; then
          echo "Error: No Rider configuration directory found."
          echo "Please run Rider at least once before running this script."
          exit 1
      fi

      # Use the latest Rider version
      RIDER_DIR="''${RIDER_DIRS[-1]}"
      echo "Using Rider configuration: $RIDER_DIR"

      # Create options directory
      mkdir -p "$RIDER_DIR/options"

      # Configure Unreal Engine paths
      cat > "$RIDER_DIR/options/unreal-engine.xml" << EOF
      <application>
        <component name="UnrealEngineSettings">
          <option name="engineRootPath" value="${ueEnginePath}" />
          <option name="generateProjectFilesPath" value="$(which GenerateProjectFiles.sh)" />
          <option name="unrealBuildToolPath" value="${ueEnginePath}/Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.dll" />
        </component>
      </application>
      EOF

      # Set up code style for Unreal Engine
      cat > "$RIDER_DIR/options/codeStyleSettings.xml" << EOF
      <application>
        <component name="CodeStyleSettingsManager">
          <option name="PER_PROJECT_SETTINGS">
            <value>
              <option name="LINE_SEPARATOR" value="&#10;" />
              <option name="RIGHT_MARGIN" value="120" />
              <CppCodeStyleSettings>
                <option name="INDENT_PREPROCESSOR_DIRECTIVES" value="2" />
                <option name="INDENT_VISIBILITY_SPECIFIERS" value="false" />
                <option name="NAMESPACE_INDENTATION" value="All" />
              </CppCodeStyleSettings>
              <Indentation>
                <option name="USE_TAB_CHARACTER" value="true" />
                <option name="TAB_SIZE" value="4" />
              </Indentation>
            </value>
          </option>
        </component>
      </application>
      EOF

      echo "✓ Rider configuration complete!"
      echo ""
      echo "To use Rider with Unreal Engine projects:"
      echo "1. Open a .uproject file with: unreal-rider MyGame.uproject"
      echo "2. Or generate project files first: unreal-rider --generate-only MyGame.uproject"
      echo "3. Then open the generated .sln file in Rider"
      echo ""
      echo "Note: The GenerateProjectFiles.sh wrapper is now available system-wide"
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
                  export SDL_VIDEODRIVER=x11
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

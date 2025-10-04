#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration for existing setup
CONTAINER_NAME="unreal"
UE_ENGINE_PATH="$HOME/distrobox/unreal/Linux_Unreal_Engine_5.6.1"
UE_PROJECTS_DIR="$HOME/distrobox/unreal/Projects"
RIDER_CONFIG_DIR="$HOME/.config/JetBrains"
RIDER_PLUGINS_DIR="$HOME/.local/share/JetBrains"

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check if distrobox container exists
    if ! distrobox list | grep -q "$CONTAINER_NAME"; then
        log_error "Distrobox container '$CONTAINER_NAME' not found"
        return 1
    fi

    # Check if Unreal Engine is installed
    if [ ! -d "$UE_ENGINE_PATH" ]; then
        log_error "Unreal Engine not found at: $UE_ENGINE_PATH"
        return 1
    fi

    # Check if Rider is available
    if ! command -v rider &> /dev/null; then
        log_error "JetBrains Rider not found. Please ensure it's installed in your NixOS configuration."
        return 1
    fi

    log_success "All prerequisites met"
}

install_rider_plugins() {
    log_info "Installing essential Rider plugins for Unreal Engine development..."

    # Create plugins directory
    mkdir -p "$RIDER_PLUGINS_DIR"

    # List of essential plugins for Unreal development
    local plugins=(
        "com.jetbrains.rider.cpp"
        "com.jetbrains.rider.unity"
        "org.intellij.plugins.markdown"
        "com.intellij.uiDesigner"
    )

    log_info "Essential plugins for Unreal development:"
    for plugin in "${plugins[@]}"; do
        echo "  - $plugin"
    done

    log_warning "Note: Plugins must be installed manually through Rider's plugin manager"
    log_info "Go to File -> Settings -> Plugins and install the above plugins"
}

configure_rider_settings() {
    log_info "Configuring Rider settings for Unreal Engine development..."

    # Find the latest Rider version directory
    local rider_versions=($(find "$RIDER_CONFIG_DIR" -maxdepth 1 -name "Rider*" -type d 2>/dev/null | sort -V))

    if [ ${#rider_versions[@]} -eq 0 ]; then
        log_warning "No Rider configuration directory found. Rider may need to be run once first."
        return 0
    fi

    local rider_config="${rider_versions[-1]}"
    log_info "Using Rider configuration directory: $rider_config"

    # Create options directory
    mkdir -p "$rider_config/options"

    # Configure editor settings
    cat > "$rider_config/options/editor.xml" << 'EOF'
<application>
  <component name="EditorSettings">
    <option name="USE_SOFT_WRAPS" value="true" />
    <option name="SOFT_WRAP_FILE_MASKS" value="*.md; *.txt; *.rst; *.adoc" />
    <option name="SHOW_WHITESPACES" value="true" />
    <option name="SHOW_LEADING_WHITESPACES" value="true" />
    <option name="SHOW_INNER_WHITESPACES" value="true" />
    <option name="SHOW_TRAILING_WHITESPACES" value="true" />
    <option name="IS_WHITESPACES_SHOWN" value="true" />
    <option name="IS_LEADING_WHITESPACES_SHOWN" value="true" />
    <option name="IS_INNER_WHITESPACES_SHOWN" value="true" />
    <option name="IS_TRAILING_WHITESPACES_SHOWN" value="true" />
    <option name="IS_ALL_SOFTWRAPS_SHOWN" value="true" />
    <option name="STRIP_TRAILING_SPACES" value="Modified" />
    <option name="IS_ENSURE_NEWLINE_AT_EOF" value="true" />
    <option name="SHOW_BREADCRUMBS" value="true" />
  </component>
</application>
EOF

    # Configure C++ settings for Unreal Engine
    cat > "$rider_config/options/cpp.xml" << EOF
<application>
  <component name="CppCodeStyleSettings">
    <option name="ALIGN_MULTILINE_PARAMETERS" value="true" />
    <option name="ALIGN_MULTILINE_PARAMETERS_IN_CALLS" value="true" />
    <option name="CALL_PARAMETERS_WRAP" value="5" />
    <option name="METHOD_PARAMETERS_WRAP" value="5" />
    <option name="EXTENDS_LIST_WRAP" value="5" />
    <option name="EXTENDS_KEYWORD_WRAP" value="1" />
    <option name="METHOD_CALL_CHAIN_WRAP" value="5" />
    <option name="PARENTHESES_EXPRESSION_LPAREN_WRAP" value="false" />
    <option name="PARENTHESES_EXPRESSION_RPAREN_WRAP" value="false" />
    <option name="BINARY_OPERATION_WRAP" value="5" />
    <option name="BINARY_OPERATION_SIGN_ON_NEXT_LINE" value="true" />
    <option name="TERNARY_OPERATION_WRAP" value="5" />
    <option name="TERNARY_OPERATION_SIGNS_ON_NEXT_LINE" value="true" />
    <option name="KEEP_SIMPLE_METHODS_IN_ONE_LINE" value="true" />
    <option name="KEEP_SIMPLE_CLASSES_IN_ONE_LINE" value="true" />
    <option name="KEEP_MULTIPLE_EXPRESSIONS_IN_ONE_LINE" value="false" />
    <option name="FOR_STATEMENT_WRAP" value="5" />
    <option name="ARRAY_INITIALIZER_WRAP" value="5" />
    <option name="ASSIGNMENT_WRAP" value="1" />
    <option name="PLACE_ASSIGNMENT_SIGN_ON_NEXT_LINE" value="false" />
    <option name="WRAP_COMMENTS" value="false" />
    <option name="IF_BRACE_FORCE" value="3" />
    <option name="DOWHILE_BRACE_FORCE" value="3" />
    <option name="WHILE_BRACE_FORCE" value="3" />
    <option name="FOR_BRACE_FORCE" value="3" />
    <option name="WRAP_LONG_LINES" value="false" />
    <option name="SPACE_AROUND_ASSIGNMENT_OPERATORS" value="true" />
    <option name="SPACE_AROUND_LOGICAL_OPERATORS" value="true" />
    <option name="SPACE_AROUND_EQUALITY_OPERATORS" value="true" />
    <option name="SPACE_AROUND_RELATIONAL_OPERATORS" value="true" />
    <option name="SPACE_AROUND_BITWISE_OPERATORS" value="true" />
    <option name="SPACE_AROUND_ADDITIVE_OPERATORS" value="true" />
    <option name="SPACE_AROUND_MULTIPLICATIVE_OPERATORS" value="true" />
    <option name="SPACE_AROUND_SHIFT_OPERATORS" value="true" />
    <option name="SPACE_AROUND_UNARY_OPERATOR" value="false" />
    <option name="SPACE_AFTER_COMMA" value="true" />
    <option name="SPACE_AFTER_SEMICOLON" value="true" />
    <option name="SPACE_BEFORE_CLASS_LBRACE" value="true" />
    <option name="SPACE_BEFORE_METHOD_LBRACE" value="true" />
    <option name="SPACE_BEFORE_IF_LBRACE" value="true" />
    <option name="SPACE_BEFORE_ELSE_LBRACE" value="true" />
    <option name="SPACE_BEFORE_WHILE_LBRACE" value="true" />
    <option name="SPACE_BEFORE_FOR_LBRACE" value="true" />
    <option name="SPACE_BEFORE_DO_LBRACE" value="true" />
    <option name="SPACE_BEFORE_SWITCH_LBRACE" value="true" />
    <option name="SPACE_BEFORE_TRY_LBRACE" value="true" />
    <option name="SPACE_BEFORE_CATCH_LBRACE" value="true" />
    <option name="SPACE_BEFORE_WHILE_KEYWORD" value="true" />
    <option name="SPACE_BEFORE_ELSE_KEYWORD" value="true" />
    <option name="SPACE_BEFORE_CATCH_KEYWORD" value="true" />
  </component>
</application>
EOF

    # Configure project settings for Unreal Engine
    cat > "$rider_config/options/project.default.xml" << EOF
<application>
  <component name="ProjectManager">
    <defaultProject>
      <component name="UnrealProjectSettings">
        <option name="engineLocation" value="$UE_ENGINE_PATH" />
        <option name="projectsLocation" value="$UE_PROJECTS_DIR" />
      </component>
    </defaultProject>
  </component>
</application>
EOF

    log_success "Rider settings configured"
}

setup_unreal_project_templates() {
    log_info "Setting up Unreal Engine project templates..."

    local templates_dir="$RIDER_CONFIG_DIR/templates"
    mkdir -p "$templates_dir"

    # Create C++ Actor template
    cat > "$templates_dir/UnrealActor.cpp" << 'EOF'
#include "${NAME}.h"

A${NAME}::A${NAME}()
{
    PrimaryActorTick.bCanEverTick = true;
}

void A${NAME}::BeginPlay()
{
    Super::BeginPlay();
}

void A${NAME}::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
}
EOF

    cat > "$templates_dir/UnrealActor.h" << 'EOF'
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "${NAME}.generated.h"

UCLASS()
class ${UPPER_PROJECT_NAME}_API A${NAME} : public AActor
{
    GENERATED_BODY()

public:
    A${NAME}();

protected:
    virtual void BeginPlay() override;

public:
    virtual void Tick(float DeltaTime) override;
};
EOF

    # Create Blueprint Component template
    cat > "$templates_dir/UnrealComponent.h" << 'EOF'
#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "${NAME}.generated.h"

UCLASS( ClassGroup=(Custom), meta=(BlueprintSpawnableComponent) )
class ${UPPER_PROJECT_NAME}_API U${NAME} : public UActorComponent
{
    GENERATED_BODY()

public:
    U${NAME}();

protected:
    virtual void BeginPlay() override;

public:
    virtual void TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) override;
};
EOF

    cat > "$templates_dir/UnrealComponent.cpp" << 'EOF'
#include "${NAME}.h"

U${NAME}::U${NAME}()
{
    PrimaryComponentTick.bCanEverTick = true;
}

void U${NAME}::BeginPlay()
{
    Super::BeginPlay();
}

void U${NAME}::TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction)
{
    Super::TickComponent(DeltaTime, TickType, ThisTickFunction);
}
EOF

    log_success "Unreal Engine project templates created"
}

create_rider_launch_script() {
    log_info "Creating enhanced Rider launch script..."

    local script_path="$HOME/.local/bin/unreal-rider"
    mkdir -p "$(dirname "$script_path")"

    cat > "$script_path" << EOF
#!/usr/bin/env bash

# Enhanced Unreal Rider launcher
set -euo pipefail

# Unreal Engine environment
export UE_ENGINE_LOCATION="$UE_ENGINE_PATH"
export UE_PROJECTS_DIR="$UE_PROJECTS_DIR"
export PATH="\$PATH:$UE_ENGINE_PATH/Engine/Binaries/Linux"

# .NET environment
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

# Graphics environment (same as unreal.bash)
export SDL_VIDEODRIVER=wayland
export VK_ICD_FILENAMES=/run/host/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
export LD_LIBRARY_PATH=/run/host/run/opengl-driver/lib:\$LD_LIBRARY_PATH

# Function to launch Rider in distrobox
launch_rider_distrobox() {
    echo "Launching Rider in distrobox environment..."
    distrobox enter $CONTAINER_NAME -- bash -c "
        export UE_ENGINE_LOCATION=$UE_ENGINE_PATH
        export UE_PROJECTS_DIR=$UE_PROJECTS_DIR
        export PATH=\\\$PATH:$UE_ENGINE_PATH/Engine/Binaries/Linux
        export DOTNET_CLI_TELEMETRY_OPTOUT=1
        export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
        export SDL_VIDEODRIVER=wayland
        export VK_ICD_FILENAMES=/run/host/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
        export LD_LIBRARY_PATH=/run/host/run/opengl-driver/lib:\\\$LD_LIBRARY_PATH

        # Install Rider if not present in container
        if ! command -v rider &> /dev/null; then
            echo 'Rider not found in container. Installing...'
            # You can add installation logic here or use the host version
            echo 'Using host Rider installation'
        fi

        cd \\\$UE_PROJECTS_DIR
        rider \\\$@
    " -- "\$@"
}

# Function to launch Rider on host
launch_rider_host() {
    echo "Launching Rider on host system..."
    cd "$UE_PROJECTS_DIR"
    rider "\$@"
}

# Main logic
case "\${1:-}" in
    "--host")
        shift
        launch_rider_host "\$@"
        ;;
    "--distrobox"|"--container")
        shift
        launch_rider_distrobox "\$@"
        ;;
    "--help"|"-h")
        echo "Unreal Rider Launcher"
        echo "Usage: \$0 [options] [project_file]"
        echo ""
        echo "Options:"
        echo "  --host        Launch Rider on host system (default)"
        echo "  --distrobox   Launch Rider in distrobox container"
        echo "  --container   Alias for --distrobox"
        echo "  --help        Show this help"
        echo ""
        echo "Examples:"
        echo "  \$0                           # Launch Rider with default settings"
        echo "  \$0 MyProject.sln            # Open specific solution"
        echo "  \$0 --distrobox MyGame.uproject  # Open UE project in container"
        ;;
    *)
        # Default to host launch
        launch_rider_host "\$@"
        ;;
esac
EOF

    chmod +x "$script_path"
    log_success "Enhanced Rider launch script created at: $script_path"
}

create_desktop_entry() {
    log_info "Creating desktop entry for Unreal Rider..."

    local desktop_file="$HOME/.local/share/applications/unreal-rider.desktop"
    mkdir -p "$(dirname "$desktop_file")"

    cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Unreal Rider
GenericName=Unreal Engine IDE
Comment=JetBrains Rider configured for Unreal Engine development
Exec=$HOME/.local/bin/unreal-rider %F
Icon=jetbrains-rider
StartupNotify=true
NoDisplay=false
Categories=Development;IDE;
MimeType=application/x-rider-project;text/x-csharp;text/x-c++src;text/x-chdr;application/x-ms-dos-executable;
Actions=HostMode;ContainerMode;

[Desktop Action HostMode]
Name=Launch on Host
Exec=$HOME/.local/bin/unreal-rider --host %F

[Desktop Action ContainerMode]
Name=Launch in Container
Exec=$HOME/.local/bin/unreal-rider --distrobox %F
EOF

    log_success "Desktop entry created"
}

setup_build_configuration() {
    log_info "Setting up build configuration for Unreal Engine projects..."

    # Create a build script that can be used from Rider
    local build_script="$HOME/.local/bin/unreal-build"

    cat > "$build_script" << EOF
#!/usr/bin/env bash

# Unreal Engine build helper script
set -euo pipefail

UE_ENGINE="$UE_ENGINE_PATH"
PROJECTS_DIR="$UE_PROJECTS_DIR"

show_help() {
    echo "Unreal Engine Build Helper"
    echo "Usage: \$0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  build [project.uproject] [config] [platform]  # Build project"
    echo "  generate [project.uproject]                   # Generate project files"
    echo "  clean [project.uproject]                      # Clean project"
    echo "  help                                          # Show this help"
    echo ""
    echo "Config: Development (default), Debug, Shipping"
    echo "Platform: Linux (default), Win64"
    echo ""
    echo "Examples:"
    echo "  \$0 build MyGame.uproject"
    echo "  \$0 build MyGame.uproject Debug Linux"
    echo "  \$0 generate MyGame.uproject"
}

build_project() {
    local project_file="\$1"
    local config="\${2:-Development}"
    local platform="\${3:-Linux}"

    if [ ! -f "\$project_file" ]; then
        echo "Project file not found: \$project_file"
        return 1
    fi

    local project_name=\$(basename "\$project_file" .uproject)

    echo "Building \$project_name (\$config/\$platform)..."

    distrobox enter $CONTAINER_NAME -- bash -c "
        cd \$(dirname \$project_file)
        \$UE_ENGINE/Engine/Build/BatchFiles/Linux/Build.sh \\
            \$project_name \\
            \$platform \\
            \$config \\
            -project=\$project_file \\
            -progress
    "
}

generate_project_files() {
    local project_file="\$1"

    if [ ! -f "\$project_file" ]; then
        echo "Project file not found: \$project_file"
        return 1
    fi

    echo "Generating project files for \$project_file..."

    distrobox enter $CONTAINER_NAME -- bash -c "
        \$UE_ENGINE/Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool \\
            -projectfiles \\
            -project=\$project_file \\
            -game \\
            -rocket \\
            -progress
    "
}

clean_project() {
    local project_file="\$1"

    if [ ! -f "\$project_file" ]; then
        echo "Project file not found: \$project_file"
        return 1
    fi

    local project_dir=\$(dirname "\$project_file")

    echo "Cleaning project..."

    # Remove common build directories
    rm -rf "\$project_dir/Binaries"
    rm -rf "\$project_dir/Intermediate"
    rm -rf "\$project_dir/.vs"
    rm -f "\$project_dir"/*.sln

    echo "Project cleaned"
}

# Main command handling
case "\${1:-help}" in
    "build")
        shift
        build_project "\$@"
        ;;
    "generate")
        shift
        generate_project_files "\$@"
        ;;
    "clean")
        shift
        clean_project "\$@"
        ;;
    "help"|*)
        show_help
        ;;
esac
EOF

    chmod +x "$build_script"
    log_success "Build configuration script created at: $build_script"
}

configure_debugging() {
    log_info "Setting up debugging configuration..."

    # Create debugging helper script
    local debug_script="$HOME/.local/bin/unreal-debug"

    cat > "$debug_script" << EOF
#!/usr/bin/env bash

# Unreal Engine debugging helper
set -euo pipefail

UE_ENGINE="$UE_ENGINE_PATH"

show_help() {
    echo "Unreal Engine Debug Helper"
    echo "Usage: \$0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  attach [process_name]  # Attach debugger to running process"
    echo "  launch [project]       # Launch project with debugger"
    echo "  symbols [project]      # Generate debug symbols"
    echo "  help                   # Show this help"
}

attach_debugger() {
    local process_name="\${1:-UnrealEditor}"

    echo "Attempting to attach debugger to: \$process_name"

    distrobox enter $CONTAINER_NAME -- bash -c "
        # Find the process ID
        local pid=\\\$(pgrep \$process_name | head -1)

        if [ -z \"\\\$pid\" ]; then
            echo \"Process \$process_name not found\"
            return 1
        fi

        echo \"Attaching to PID: \\\$pid\"
        gdb -p \\\$pid
    "
}

launch_with_debugger() {
    local project="\$1"

    if [ ! -f "\$project" ]; then
        echo "Project file not found: \$project"
        return 1
    fi

    echo "Launching \$project with debugger..."

    distrobox enter $CONTAINER_NAME -- bash -c "
        cd \$(dirname \$project)
        export SDL_VIDEODRIVER=wayland
        export VK_ICD_FILENAMES=/run/host/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
        export LD_LIBRARY_PATH=/run/host/run/opengl-driver/lib:\\\$LD_LIBRARY_PATH

        gdb --args \$UE_ENGINE/Engine/Binaries/Linux/UnrealEditor \$project -vulkan
    "
}

generate_symbols() {
    local project="\$1"

    if [ ! -f "\$project" ]; then
        echo "Project file not found: \$project"
        return 1
    fi

    local project_name=\$(basename "\$project" .uproject)

    echo "Generating debug symbols for \$project_name..."

    distrobox enter $CONTAINER_NAME -- bash -c "
        cd \$(dirname \$project)
        \$UE_ENGINE/Engine/Build/BatchFiles/Linux/Build.sh \\
            \$project_name \\
            Linux \\
            Debug \\
            -project=\$project \\
            -progress
    "
}

# Main command handling
case "\${1:-help}" in
    "attach")
        shift
        attach_debugger "\$@"
        ;;
    "launch")
        shift
        launch_with_debugger "\$@"
        ;;
    "symbols")
        shift
        generate_symbols "\$@"
        ;;
    "help"|*)
        show_help
        ;;
esac
EOF

    chmod +x "$debug_script"
    log_success "Debugging helper script created at: $debug_script"
}

install_rider_in_container() {
    log_info "Installing development tools in distrobox container..."

    distrobox enter "$CONTAINER_NAME" -- bash -c '
        # Update package lists
        sudo apt update

        # Install essential development tools
        sudo apt install -y \
            build-essential \
            clang \
            lldb \
            gdb \
            cmake \
            ninja-build \
            git \
            git-lfs \
            curl \
            wget \
            unzip \
            python3 \
            python3-pip \
            nodejs \
            npm \
            mono-devel \
            ca-certificates \
            gnupg \
            software-properties-common

        # Install .NET SDK if not present
        if ! command -v dotnet &> /dev/null; then
            wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
            sudo dpkg -i packages-microsoft-prod.deb
            rm packages-microsoft-prod.deb
            sudo apt update
            sudo apt install -y dotnet-sdk-8.0
        fi

        # Setup git-lfs
        git lfs install

        echo "Development tools installation complete!"
    '

    log_success "Development tools installed in container"
}

show_completion_message() {
    log_success "Rider configuration for Unreal Engine complete!"
    echo
    log_info "Configuration summary:"
    echo "• Unreal Engine: $UE_ENGINE_PATH"
    echo "• Projects directory: $UE_PROJECTS_DIR"
    echo "• Container: $CONTAINER_NAME"
    echo
    log_info "Available commands:"
    echo "• unreal-rider          : Launch Rider with UE support"
    echo "• unreal-build          : Build UE projects"
    echo "• unreal-debug          : Debug UE projects"
    echo "• unreal                : Launch Unreal Editor (existing)"
    echo
    log_info "Usage examples:"
    echo "• unreal-rider --host                    : Launch Rider on host"
    echo "• unreal-rider --distrobox               : Launch Rider in container"
    echo "• unreal-rider MyGame.uproject           : Open specific project"
    echo "• unreal-build build MyGame.uproject     : Build project"
    echo "• unreal-debug launch MyGame.uproject    : Debug project"
    echo
    log_warning "Important notes:"
    echo "• Make sure to install Rider plugins manually (C++, Unity support)"
    echo "• First launch of Rider may take longer due to indexing"
    echo "• Use 'distrobox enter unreal' to access the development container directly"
    echo "• The container includes all necessary build tools and dependencies"
    echo
    log_info "Next steps:"
    echo "1. Run 'unreal-rider' to launch JetBrains Rider"
    echo "2. Install recommended plugins through Rider's plugin manager"
    echo "3. Create or open an Unreal Engine project"
    echo "4. Configure project-specific build settings as needed"
}

main() {
    log_info "Configuring JetBrains Rider for Unreal Engine development..."
    echo

    check_prerequisites
    install_rider_plugins
    configure_rider_settings
    setup_unreal_project_templates
    create_rider_launch_script
    create_desktop_entry
    setup_build_configuration
    configure_debugging
    install_rider_in_container
    show_completion_message
}

# Run main function
main "$@"

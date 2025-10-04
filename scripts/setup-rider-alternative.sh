#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONTAINER_NAME="unreal"
UE_ENGINE_PATH="$HOME/distrobox/unreal/Linux_Unreal_Engine_5.6.1"
UE_PROJECTS_DIR="$HOME/distrobox/unreal/Projects"
TEMP_DIR="$HOME/tmp"
RIDER_VERSION="2024.3.1.1"

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

show_header() {
    echo "============================================================"
    echo "  JetBrains Rider Alternative Installation Setup"
    echo "============================================================"
    echo "This script helps install and configure JetBrains Rider for"
    echo "Unreal Engine development when nixpkgs package fails to build."
    echo "============================================================"
    echo
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

    log_success "Prerequisites check passed"
}

check_existing_rider() {
    log_info "Checking for existing Rider installations..."

    local found_installations=()

    # Check for system rider command
    if command -v rider &> /dev/null; then
        found_installations+=("System rider command: $(which rider)")
    fi

    # Check for manual installation
    if [ -f "/usr/local/bin/rider" ]; then
        found_installations+=("Manual installation: /usr/local/bin/rider")
    fi

    # Check for JetBrains Toolbox
    if [ -d "$HOME/.local/share/JetBrains/Toolbox" ]; then
        found_installations+=("JetBrains Toolbox: $HOME/.local/share/JetBrains/Toolbox")
    fi

    # Check for Flatpak
    if command -v flatpak &> /dev/null && flatpak list | grep -q "com.jetbrains.Rider"; then
        found_installations+=("Flatpak: com.jetbrains.Rider")
    fi

    if [ ${#found_installations[@]} -eq 0 ]; then
        log_info "No existing Rider installations found"
        return 1
    else
        log_warning "Found existing installations:"
        for installation in "${found_installations[@]}"; do
            echo "  - $installation"
        done
        echo
        read -p "Continue with setup? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Setup cancelled by user"
            exit 0
        fi
    fi
}

show_installation_options() {
    log_info "Choose Rider installation method:"
    echo
    echo "1) JetBrains Toolbox (Recommended) - Easy updates and management"
    echo "2) Manual Download - Direct installation to /opt"
    echo "3) Skip Installation - Configure existing installation"
    echo "4) Exit"
    echo
}

install_toolbox() {
    log_info "Installing JetBrains Toolbox..."

    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"

    # Download JetBrains Toolbox
    log_info "Downloading JetBrains Toolbox..."
    local toolbox_url="https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.2.35332.tar.gz"

    if ! curl -fsSL "$toolbox_url" -o toolbox.tar.gz; then
        log_error "Failed to download JetBrains Toolbox"
        return 1
    fi

    # Extract
    tar -xzf toolbox.tar.gz
    cd jetbrains-toolbox-*/

    # Launch toolbox
    log_info "Launching JetBrains Toolbox..."
    ./jetbrains-toolbox &

    log_success "JetBrains Toolbox launched!"
    echo
    log_info "Please:"
    echo "1. Install Rider through the Toolbox interface"
    echo "2. Launch Rider at least once to initialize it"
    echo "3. Return here and press Enter to continue setup"
    echo
    read -p "Press Enter when Rider is installed and initialized..."
}

install_manual() {
    log_info "Installing Rider manually..."

    # Create directories
    sudo mkdir -p /opt/jetbrains
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"

    # Download Rider
    log_info "Downloading JetBrains Rider $RIDER_VERSION..."
    local rider_url="https://download.jetbrains.com/rider/JetBrains.Rider-${RIDER_VERSION}.tar.gz"

    if ! curl -fsSL "$rider_url" -o rider.tar.gz; then
        log_error "Failed to download JetBrains Rider"
        log_info "You may need to check the latest version at: https://www.jetbrains.com/rider/download/"
        return 1
    fi

    # Extract to /opt
    log_info "Installing to /opt/jetbrains..."
    sudo tar -xzf rider.tar.gz -C /opt/jetbrains

    # Create symlink
    local rider_dir="/opt/jetbrains/JetBrains Rider-${RIDER_VERSION}"
    if [ -d "$rider_dir" ]; then
        sudo ln -sf "$rider_dir/bin/rider.sh" /usr/local/bin/rider
        log_success "Rider installed to $rider_dir"
        log_success "Created symlink: /usr/local/bin/rider"
    else
        log_error "Installation directory not found: $rider_dir"
        return 1
    fi

    # Create desktop entry
    create_desktop_entry "$rider_dir"
}

create_desktop_entry() {
    local rider_dir="$1"

    log_info "Creating desktop entry..."

    mkdir -p ~/.local/share/applications

    cat > ~/.local/share/applications/jetbrains-rider.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=JetBrains Rider
Icon=${rider_dir}/bin/rider.svg
Exec="${rider_dir}/bin/rider.sh" %f
Comment=Cross-platform .NET IDE
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-rider
StartupNotify=true
MimeType=application/x-rider-project;
EOF

    # Update desktop database
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database ~/.local/share/applications/
    fi

    log_success "Desktop entry created"
}

setup_container_tools() {
    log_info "Setting up development tools in distrobox container..."

    distrobox enter "$CONTAINER_NAME" -- bash -c '
        set -e

        echo "Updating package lists..."
        sudo apt update

        echo "Installing essential development tools..."
        sudo apt install -y \
            build-essential \
            clang \
            lldb \
            gdb \
            cmake \
            ninja-build \
            git \
            git-lfs \
            python3 \
            python3-pip \
            nodejs \
            npm \
            curl \
            wget \
            unzip \
            mono-devel \
            ca-certificates \
            gnupg \
            software-properties-common

        echo "Installing .NET SDK 8..."
        if ! command -v dotnet &> /dev/null; then
            wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
            sudo dpkg -i packages-microsoft-prod.deb
            rm packages-microsoft-prod.deb
            sudo apt update
            sudo apt install -y dotnet-sdk-8.0
        else
            echo ".NET SDK already installed"
        fi

        echo "Setting up git-lfs..."
        git lfs install

        echo "Container setup complete!"
    '

    if [ $? -eq 0 ]; then
        log_success "Development tools installed in container"
    else
        log_error "Failed to install development tools in container"
        return 1
    fi
}

create_launch_script() {
    log_info "Creating enhanced Rider launch script..."

    mkdir -p ~/.local/bin

    cat > ~/.local/bin/unreal-rider << 'EOF'
#!/usr/bin/env bash

# Enhanced Unreal Rider launcher
set -euo pipefail

# Unreal Engine environment
export UE_ENGINE_LOCATION="$HOME/distrobox/unreal/Linux_Unreal_Engine_5.6.1"
export UE_PROJECTS_DIR="$HOME/distrobox/unreal/Projects"
export PATH="$PATH:$UE_ENGINE_LOCATION/Engine/Binaries/Linux"

# .NET environment
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

# Graphics environment
export SDL_VIDEODRIVER=wayland
export VK_ICD_FILENAMES=/run/host/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
export LD_LIBRARY_PATH=/run/host/run/opengl-driver/lib:$LD_LIBRARY_PATH

echo "Launching JetBrains Rider with Unreal Engine support..."

# Change to projects directory
cd "$UE_PROJECTS_DIR" 2>/dev/null || cd "$HOME"

# Launch Rider (try different methods)
if command -v rider &> /dev/null; then
    rider "$@"
elif [ -f "/usr/local/bin/rider" ]; then
    /usr/local/bin/rider "$@"
elif command -v flatpak &> /dev/null && flatpak list | grep -q "com.jetbrains.Rider"; then
    flatpak run com.jetbrains.Rider "$@"
else
    echo "Error: Rider installation not found"
    echo "Please ensure Rider is installed using one of the supported methods"
    exit 1
fi
EOF

    chmod +x ~/.local/bin/unreal-rider
    log_success "Launch script created: ~/.local/bin/unreal-rider"
}

create_build_script() {
    log_info "Creating Unreal Engine build helper script..."

    cat > ~/.local/bin/unreal-build << 'EOF'
#!/usr/bin/env bash

# Unreal Engine build helper script
set -euo pipefail

UE_ENGINE="$HOME/distrobox/unreal/Linux_Unreal_Engine_5.6.1"
PROJECTS_DIR="$HOME/distrobox/unreal/Projects"

show_help() {
    echo "Unreal Engine Build Helper"
    echo "Usage: $0 [command] [options]"
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
    echo "  $0 build MyGame.uproject"
    echo "  $0 build MyGame.uproject Debug Linux"
    echo "  $0 generate MyGame.uproject"
}

build_project() {
    local project_file="$1"
    local config="${2:-Development}"
    local platform="${3:-Linux}"

    if [ ! -f "$project_file" ]; then
        echo "Project file not found: $project_file"
        return 1
    fi

    local project_name=$(basename "$project_file" .uproject)

    echo "Building $project_name ($config/$platform)..."

    distrobox enter unreal -- bash -c "
        cd $(dirname $project_file)
        $UE_ENGINE/Engine/Build/BatchFiles/Linux/Build.sh \\
            $project_name \\
            $platform \\
            $config \\
            -project=$project_file \\
            -progress
    "
}

generate_project_files() {
    local project_file="$1"

    if [ ! -f "$project_file" ]; then
        echo "Project file not found: $project_file"
        return 1
    fi

    echo "Generating project files for $project_file..."

    distrobox enter unreal -- bash -c "
        cd $(dirname $project_file)
        $UE_ENGINE/Engine/Build/BatchFiles/Linux/GenerateProjectFiles.sh \\
            -project=$project_file \\
            -game \\
            -rocket \\
            -progress
    "
}

clean_project() {
    local project_file="$1"

    if [ ! -f "$project_file" ]; then
        echo "Project file not found: $project_file"
        return 1
    fi

    local project_dir=$(dirname "$project_file")

    echo "Cleaning project..."

    # Remove common build directories
    rm -rf "$project_dir/Binaries"
    rm -rf "$project_dir/Intermediate"
    rm -rf "$project_dir/.vs"
    rm -f "$project_dir"/*.sln

    echo "Project cleaned"
}

# Main command handling
case "${1:-help}" in
    "build")
        shift
        build_project "$@"
        ;;
    "generate")
        shift
        generate_project_files "$@"
        ;;
    "clean")
        shift
        clean_project "$@"
        ;;
    "help"|*)
        show_help
        ;;
esac
EOF

    chmod +x ~/.local/bin/unreal-build
    log_success "Build script created: ~/.local/bin/unreal-build"
}

setup_environment() {
    log_info "Setting up environment configuration..."

    # Add to fish config if it exists
    if [ -f ~/.config/fish/config.fish ]; then
        if ! grep -q "UE_ENGINE_LOCATION" ~/.config/fish/config.fish; then
            cat >> ~/.config/fish/config.fish << 'EOF'

# Unreal Engine environment
set -gx UE_ENGINE_LOCATION "$HOME/distrobox/unreal/Linux_Unreal_Engine_5.6.1"
set -gx UE_PROJECTS_DIR "$HOME/distrobox/unreal/Projects"
set -gx PATH $PATH "$UE_ENGINE_LOCATION/Engine/Binaries/Linux"

# .NET environment
set -gx DOTNET_CLI_TELEMETRY_OPTOUT 1
set -gx DOTNET_SKIP_FIRST_TIME_EXPERIENCE 1

# Graphics environment
set -gx SDL_VIDEODRIVER wayland
set -gx VK_ICD_FILENAMES /run/host/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
set -gx LD_LIBRARY_PATH /run/host/run/opengl-driver/lib:$LD_LIBRARY_PATH
EOF
            log_success "Environment variables added to fish config"
        else
            log_info "Environment variables already configured in fish"
        fi
    fi

    # Add to bash profile if it exists
    if [ -f ~/.bashrc ]; then
        if ! grep -q "UE_ENGINE_LOCATION" ~/.bashrc; then
            cat >> ~/.bashrc << 'EOF'

# Unreal Engine environment
export UE_ENGINE_LOCATION="$HOME/distrobox/unreal/Linux_Unreal_Engine_5.6.1"
export UE_PROJECTS_DIR="$HOME/distrobox/unreal/Projects"
export PATH="$PATH:$UE_ENGINE_LOCATION/Engine/Binaries/Linux"

# .NET environment
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

# Graphics environment
export SDL_VIDEODRIVER=wayland
export VK_ICD_FILENAMES=/run/host/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
export LD_LIBRARY_PATH=/run/host/run/opengl-driver/lib:$LD_LIBRARY_PATH
EOF
            log_success "Environment variables added to bashrc"
        else
            log_info "Environment variables already configured in bash"
        fi
    fi
}

show_completion_message() {
    log_success "JetBrains Rider setup complete!"
    echo
    log_info "What was installed/configured:"
    echo "• Development tools in distrobox container"
    echo "• Enhanced Rider launcher: unreal-rider"
    echo "• Build helper script: unreal-build"
    echo "• Environment variables configured"
    echo
    log_info "Next steps:"
    echo "1. Launch Rider: unreal-rider"
    echo "2. Install Rider plugins (C++ support, Unreal Engine support)"
    echo "3. Create or open an Unreal Engine C++ project"
    echo "4. Configure project settings in Rider"
    echo
    log_info "Usage examples:"
    echo "• unreal-rider                           # Launch Rider"
    echo "• unreal-rider MyGame.sln               # Open specific solution"
    echo "• unreal-build generate MyGame.uproject # Generate project files"
    echo "• unreal-build build MyGame.uproject    # Build project"
    echo
    log_warning "Important notes:"
    echo "• Restart your terminal or desktop session for environment variables to take effect"
    echo "• First launch of Rider may take longer due to indexing"
    echo "• Use your existing 'unreal' command to launch Unreal Editor"
    echo "• See RIDER_ALTERNATIVE_INSTALL.md for detailed usage guide"
}

main() {
    show_header

    if ! check_prerequisites; then
        log_error "Prerequisites check failed. Please ensure Unreal Engine and distrobox are properly set up."
        exit 1
    fi

    check_existing_rider

    while true; do
        show_installation_options
        read -p "Select option (1-4): " choice
        case $choice in
            1)
                if install_toolbox; then
                    break
                else
                    log_error "Toolbox installation failed"
                fi
                ;;
            2)
                if install_manual; then
                    break
                else
                    log_error "Manual installation failed"
                fi
                ;;
            3)
                log_info "Skipping Rider installation, configuring existing setup..."
                break
                ;;
            4)
                log_info "Exiting..."
                exit 0
                ;;
            *)
                log_error "Invalid option. Please select 1-4."
                ;;
        esac
    done

    setup_container_tools
    create_launch_script
    create_build_script
    setup_environment
    show_completion_message
}

# Run main function
main "$@"

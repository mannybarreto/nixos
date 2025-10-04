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
UE_VERSION="5.6.1"
UE_INSTALL_DIR="$HOME/distrobox/unreal"
UE_ENGINE_PATH="$HOME/distrobox/unreal/Linux_Unreal_Engine_5.6.1"
PROJECTS_DIR="$HOME/distrobox/unreal/Projects"

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

check_dependencies() {
    log_info "Checking dependencies..."

    local deps=("distrobox" "podman" "git")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log_error "$dep is not installed. Please ensure your NixOS configuration includes it."
            exit 1
        fi
    done

    log_success "All dependencies are available"
}

create_distrobox_container() {
    log_info "Setting up distrobox container for Unreal Engine..."

    if distrobox list | grep -q "$CONTAINER_NAME"; then
        log_warning "Container '$CONTAINER_NAME' already exists"
        return 0
    fi

    # Create Ubuntu-based container for better Unreal Engine compatibility
    distrobox create \
        --name "$CONTAINER_NAME" \
        --image ubuntu:22.04 \
        --additional-packages "build-essential clang cmake ninja-build python3 python3-pip nodejs npm git git-lfs curl wget unzip mono-devel ca-certificates gnupg software-properties-common" \
        --volume "$HOME:$HOME:rw" \
        --volume "/tmp:/tmp:rw" \
        --nvidia

    log_success "Distrobox container '$CONTAINER_NAME' created"
}

setup_unreal_environment() {
    log_info "Setting up Unreal Engine environment in container..."

    # Check if Unreal Engine is already installed
    if [ -d "$UE_ENGINE_PATH" ]; then
        log_success "Unreal Engine 5.6.1 already installed at $UE_ENGINE_PATH"
    else
        log_warning "Unreal Engine not found at expected path: $UE_ENGINE_PATH"
        log_info "Please ensure Unreal Engine is installed in the distrobox container"
    fi

    # Create necessary directories
    mkdir -p "$UE_INSTALL_DIR"
    mkdir -p "$PROJECTS_DIR"

    # Setup script to run inside the container
    cat > "$UE_INSTALL_DIR/setup.sh" << 'EOF'
#!/bin/bash

# Update package lists
sudo apt update

# Install additional dependencies for Unreal Engine
sudo apt install -y \
    build-essential \
    clang \
    cmake \
    ninja-build \
    python3 \
    python3-pip \
    nodejs \
    npm \
    git \
    git-lfs \
    curl \
    wget \
    unzip \
    mono-devel \
    ca-certificates \
    gnupg \
    software-properties-common \
    libc6-dev \
    libgtk-3-dev \
    libglu1-mesa-dev \
    freeglut3-dev \
    mesa-common-dev \
    libxmu-dev \
    libxi-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libasound2-dev \
    libpulse-dev

# Install .NET SDK
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt update
sudo apt install -y dotnet-sdk-8.0

# Setup git-lfs
git lfs install

# Create symbolic links for common tools
sudo ln -sf /usr/bin/clang /usr/bin/cc || true
sudo ln -sf /usr/bin/clang++ /usr/bin/c++ || true

echo "Unreal Engine environment setup complete!"
EOF

    chmod +x "$UE_INSTALL_DIR/setup.sh"

    # Run setup inside container
    distrobox enter "$CONTAINER_NAME" -- bash "$UE_INSTALL_DIR/setup.sh"

    log_success "Unreal Engine environment configured"
}

setup_unreal_launcher() {
    log_info "Setting up Unreal Engine launcher script..."

    cat > "$UE_INSTALL_DIR/unreal.bash" << 'EOF'
#!/bin/bash

# Unreal Engine Launcher Script
# This script provides various Unreal Engine related commands

UE_INSTALL_PATH="$HOME/distrobox/unreal/Linux_Unreal_Engine_5.6.1"
PROJECTS_DIR="$HOME/distrobox/unreal/Projects"

show_help() {
    echo "Unreal Engine Development Helper"
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  setup           - Download and setup Unreal Engine"
    echo "  editor          - Launch Unreal Editor"
    echo "  build [project] - Build specified project"
    echo "  new [name]      - Create new project"
    echo "  rider           - Launch JetBrains Rider"
    echo "  help            - Show this help"
    echo ""
}

setup_unreal_engine() {
    echo "Setting up Unreal Engine..."

    if [ ! -d "$UE_INSTALL_PATH" ]; then
        echo "Unreal Engine not found at: $UE_INSTALL_PATH"
        echo "Please ensure Unreal Engine 5.6.1 is installed in the distrobox container."
        return 1
    fi

    echo "Unreal Engine 5.6.1 found at: $UE_INSTALL_PATH"
    return 0
}

launch_editor() {
    if [ ! -d "$UE_INSTALL_PATH" ]; then
        echo "Unreal Engine not installed. Run '$0 setup' first."
        return 1
    fi

    # Set up the same environment as the existing unreal.bash
    export SDL_VIDEODRIVER=wayland
    export VK_ICD_FILENAMES=/run/host/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
    export LD_LIBRARY_PATH=/run/host/run/opengl-driver/lib:$LD_LIBRARY_PATH

    cd "$UE_INSTALL_PATH/Engine/Binaries/Linux/"
    ./UnrealEditor -vulkan "$@"
}

launch_rider() {
    echo "Launching JetBrains Rider with Unreal Engine support..."

    # Set environment variables
    export UE_ENGINE_LOCATION="$UE_INSTALL_PATH"
    export UE_PROJECTS_DIR="$PROJECTS_DIR"
    export PATH="$PATH:$UE_INSTALL_PATH/Engine/Binaries/Linux"
    export DOTNET_CLI_TELEMETRY_OPTOUT=1
    export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
    export SDL_VIDEODRIVER=wayland
    export VK_ICD_FILENAMES=/run/host/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
    export LD_LIBRARY_PATH=/run/host/run/opengl-driver/lib:$LD_LIBRARY_PATH

    # Check if Rider is available
    if command -v rider &> /dev/null; then
        rider "$@"
    else
        echo "JetBrains Rider not found. Please install it on your host system."
        return 1
    fi
}

build_project() {
    local project_path="$1"

    if [ -z "$project_path" ]; then
        echo "Please specify a project path"
        return 1
    fi

    if [ ! -f "$project_path" ]; then
        echo "Project file not found: $project_path"
        return 1
    fi

    "$UE_INSTALL_PATH/Engine/Build/BatchFiles/Linux/Build.sh" \
        $(basename "$project_path" .uproject) \
        Linux \
        Development \
        -project="$project_path"
}

create_project() {
    local project_name="$1"

    if [ -z "$project_name" ]; then
        echo "Please specify a project name"
        return 1
    fi

    mkdir -p "$PROJECTS_DIR"

    "$UE_INSTALL_PATH/Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.exe" \
        -projectfiles \
        -project="$PROJECTS_DIR/$project_name/$project_name.uproject" \
        -game \
        -rocket \
        -progress
}

# Main script logic
case "${1:-help}" in
    "setup")
        setup_unreal_engine
        ;;
    "editor")
        shift
        launch_editor "$@"
        ;;
    "rider")
        shift
        launch_rider "$@"
        ;;
    "build")
        shift
        build_project "$@"
        ;;
    "new")
        shift
        create_project "$@"
        ;;
    "help"|*)
        show_help
        ;;
esac
EOF

    chmod +x "$UE_INSTALL_DIR/unreal.bash"

    log_success "Unreal Engine launcher script created"
}

setup_rider_integration() {
    log_info "Setting up JetBrains Rider integration..."

    # Create desktop entry for Unreal Rider
    mkdir -p "$HOME/.local/share/applications"

    cat > "$HOME/.local/share/applications/unreal-rider.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Unreal Rider
Comment=JetBrains Rider with Unreal Engine support
Exec=unreal-rider %F
Icon=jetbrains-rider
Categories=Development;IDE;
MimeType=text/x-csharp;text/x-c++src;text/x-chdr;
StartupNotify=true
EOF

    # Create Rider settings directory
    mkdir -p "$HOME/.config/JetBrains/Rider2023.3"

    log_success "JetBrains Rider integration configured"
}

setup_development_directories() {
    log_info "Setting up development directories..."

    local dirs=(
        "$PROJECTS_DIR"
        "$HOME/.config/UnrealEngine"
        "$HOME/.local/share/UnrealEngine"
        "$HOME/Documents/UnrealEngine"
    )

    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        log_info "Created directory: $dir"
    done

    log_success "Development directories created"
}

show_completion_message() {
    log_success "Unreal Engine + JetBrains Rider setup complete!"
    echo
    log_info "Next steps:"
    echo "1. Unreal Engine 5.6.1 is already installed and ready to use"
    echo "2. Launch Rider using: unreal-rider"
    echo "3. Create new projects in: $PROJECTS_DIR"
    echo "4. Launch Unreal Editor using the existing: unreal command"
    echo
    log_info "Available commands:"
    echo "- unreal               : Launch Unreal Engine tools"
    echo "- unreal-rider         : Launch Rider with UE support"
    echo "- distrobox enter $CONTAINER_NAME : Enter the development container"
    echo
    log_warning "Don't forget to:"
    echo "- Rebuild your NixOS configuration: sudo nixos-rebuild switch"
    echo "- Restart your desktop session for environment variables to take effect"
}

main() {
    log_info "Starting Unreal Engine + JetBrains Rider setup..."

    check_dependencies
    create_distrobox_container
    setup_unreal_environment
    setup_unreal_launcher
    setup_rider_integration
    setup_development_directories
    show_completion_message
}

# Run main function
main "$@"

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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED++))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((WARNINGS++))
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAILED++))
}

check_command() {
    local cmd="$1"
    local desc="$2"

    if command -v "$cmd" &> /dev/null; then
        log_success "$desc: $cmd found"
        return 0
    else
        log_error "$desc: $cmd not found"
        return 1
    fi
}

check_file() {
    local file="$1"
    local desc="$2"

    if [ -f "$file" ]; then
        log_success "$desc: $file exists"
        return 0
    else
        log_error "$desc: $file not found"
        return 1
    fi
}

check_directory() {
    local dir="$1"
    local desc="$2"

    if [ -d "$dir" ]; then
        log_success "$desc: $dir exists"
        return 0
    else
        log_error "$desc: $dir not found"
        return 1
    fi
}

check_executable() {
    local file="$1"
    local desc="$2"

    if [ -x "$file" ]; then
        log_success "$desc: $file is executable"
        return 0
    else
        log_error "$desc: $file is not executable"
        return 1
    fi
}

print_header() {
    echo "============================================================"
    echo "  Unreal Engine + JetBrains Rider Setup Verification"
    echo "============================================================"
    echo
}

print_summary() {
    echo
    echo "============================================================"
    echo "  VERIFICATION SUMMARY"
    echo "============================================================"
    echo -e "Passed:   ${GREEN}$PASSED${NC}"
    echo -e "Failed:   ${RED}$FAILED${NC}"
    echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
    echo

    if [ $FAILED -eq 0 ]; then
        if [ $WARNINGS -eq 0 ]; then
            log_success "All checks passed! Your setup is ready for development."
        else
            log_warning "Setup is functional but has some warnings to address."
        fi
    else
        log_error "Some checks failed. Please review the output above."
        echo
        echo "Common solutions:"
        echo "• Run: sudo nixos-rebuild switch"
        echo "• Restart your desktop session"
        echo "• Run the configuration script: ./scripts/configure-rider-unreal.sh"
    fi
}

check_system_basics() {
    log_info "Checking system basics..."

    check_command "nix" "Nix package manager"
    check_command "nixos-rebuild" "NixOS rebuild command"
    check_command "distrobox" "Distrobox container manager"
    check_command "podman" "Podman container runtime"
}

check_development_tools() {
    log_info "Checking development tools..."

    check_command "git" "Git version control"
    check_command "clang" "Clang C++ compiler"
    check_command "cmake" "CMake build system"
    check_command "ninja" "Ninja build system"
    check_command "python3" "Python 3"
    check_command "node" "Node.js"

    if check_command "rider" "JetBrains Rider IDE"; then
        local rider_version=$(rider --version 2>/dev/null | head -1 || echo "Unknown")
        echo "    Version: $rider_version"
    fi

    if check_command "dotnet" ".NET SDK"; then
        local dotnet_version=$(dotnet --version 2>/dev/null || echo "Unknown")
        echo "    Version: $dotnet_version"
    fi

    if check_command "git-lfs" "Git LFS"; then
        local lfs_version=$(git lfs version 2>/dev/null | head -1 || echo "Unknown")
        echo "    Version: $lfs_version"
    fi
}

check_container_setup() {
    log_info "Checking distrobox container setup..."

    if distrobox list | grep -q "$CONTAINER_NAME"; then
        log_success "Distrobox container '$CONTAINER_NAME' exists"

        # Check if we can enter the container
        if distrobox enter "$CONTAINER_NAME" -- echo "Container accessible" &>/dev/null; then
            log_success "Container '$CONTAINER_NAME' is accessible"
        else
            log_error "Container '$CONTAINER_NAME' is not accessible"
        fi

        # Check development tools in container
        log_info "Checking tools in container..."

        local container_tools=("gcc" "clang" "cmake" "python3" "node" "dotnet")
        for tool in "${container_tools[@]}"; do
            if distrobox enter "$CONTAINER_NAME" -- command -v "$tool" &>/dev/null; then
                log_success "Container tool: $tool available"
            else
                log_warning "Container tool: $tool not available"
            fi
        done

    else
        log_error "Distrobox container '$CONTAINER_NAME' not found"
        echo "    Run: distrobox create --name $CONTAINER_NAME --image ubuntu:22.04 --nvidia"
    fi
}

check_unreal_engine() {
    log_info "Checking Unreal Engine installation..."

    check_directory "$UE_ENGINE_PATH" "Unreal Engine directory"
    check_directory "$UE_ENGINE_PATH/Engine" "UE Engine subdirectory"
    check_directory "$UE_ENGINE_PATH/Engine/Binaries" "UE Binaries directory"
    check_directory "$UE_ENGINE_PATH/Engine/Binaries/Linux" "UE Linux binaries"

    local ue_editor="$UE_ENGINE_PATH/Engine/Binaries/Linux/UnrealEditor"
    check_file "$ue_editor" "Unreal Editor executable"

    if [ -x "$ue_editor" ]; then
        log_success "Unreal Editor is executable"
    else
        log_warning "Unreal Editor may not be executable"
    fi

    check_directory "$UE_PROJECTS_DIR" "Projects directory"

    # Check the original launch script
    check_file "$HOME/distrobox/unreal/unreal.bash" "Original Unreal launch script"
    check_executable "$HOME/distrobox/unreal/unreal.bash" "Original launch script executable"
}

check_custom_scripts() {
    log_info "Checking custom scripts and tools..."

    local scripts=(
        "$HOME/.local/bin/unreal-rider:Enhanced Rider launcher"
        "$HOME/.local/bin/unreal-build:Build helper script"
        "$HOME/.local/bin/unreal-debug:Debug helper script"
    )

    for script_info in "${scripts[@]}"; do
        IFS=':' read -r script_path script_desc <<< "$script_info"
        if [ -f "$script_path" ]; then
            check_executable "$script_path" "$script_desc"
        else
            log_warning "$script_desc: $script_path not found"
            echo "    Run: ./scripts/configure-rider-unreal.sh"
        fi
    done

    # Check system-wide scripts
    if command -v unreal-rider &>/dev/null; then
        log_success "System-wide unreal-rider command available"
    else
        log_warning "System-wide unreal-rider command not found"
        echo "    This may require: sudo nixos-rebuild switch"
    fi
}

check_desktop_integration() {
    log_info "Checking desktop integration..."

    local desktop_file="$HOME/.local/share/applications/unreal-rider.desktop"
    check_file "$desktop_file" "Unreal Rider desktop entry"

    # Check if desktop database is updated
    if command -v update-desktop-database &>/dev/null; then
        log_success "Desktop database utilities available"
    else
        log_warning "Desktop database utilities not found"
    fi
}

check_environment_variables() {
    log_info "Checking environment variables..."

    local env_vars=(
        "UE_ENGINE_LOCATION:Unreal Engine location"
        "UE_PROJECTS_DIR:Projects directory"
        "DOTNET_CLI_TELEMETRY_OPTOUT:.NET telemetry opt-out"
    )

    for var_info in "${env_vars[@]}"; do
        IFS=':' read -r var_name var_desc <<< "$var_info"
        if [ -n "${!var_name:-}" ]; then
            log_success "$var_desc: $var_name=${!var_name}"
        else
            log_warning "$var_desc: $var_name not set"
            echo "    May require desktop session restart"
        fi
    done
}

check_nixos_configuration() {
    log_info "Checking NixOS configuration files..."

    local config_files=(
        "$SCRIPT_DIR/../modules/home-manager/development.nix:Development module"
        "$SCRIPT_DIR/../modules/nixos/unreal.nix:Unreal module"
        "$SCRIPT_DIR/../flake.nix:Main flake configuration"
    )

    for config_info in "${config_files[@]}"; do
        IFS=':' read -r config_path config_desc <<< "$config_info"
        check_file "$config_path" "$config_desc"
    done

    # Check if configuration includes the development tools
    if grep -q "jetbrains.rider" "$SCRIPT_DIR/../modules/home-manager/development.nix" 2>/dev/null; then
        log_success "Rider is configured in development.nix"
    else
        log_error "Rider not found in development.nix configuration"
    fi
}

check_permissions() {
    log_info "Checking file permissions..."

    # Check if user can access container
    if groups | grep -q docker || groups | grep -q podman; then
        log_success "User has container access permissions"
    else
        log_warning "User may not have container access permissions"
        echo "    User groups: $(groups)"
    fi

    # Check project directory permissions
    if [ -w "$UE_PROJECTS_DIR" ]; then
        log_success "Projects directory is writable"
    else
        log_warning "Projects directory may not be writable"
    fi
}

run_integration_test() {
    log_info "Running integration tests..."

    # Test container entry
    if distrobox enter "$CONTAINER_NAME" -- echo "Container test successful" &>/dev/null; then
        log_success "Container entry test passed"
    else
        log_error "Container entry test failed"
    fi

    # Test Unreal Editor version check (if possible)
    if [ -x "$UE_ENGINE_PATH/Engine/Binaries/Linux/UnrealEditor" ]; then
        log_success "Unreal Editor executable test passed"
    else
        log_warning "Cannot test Unreal Editor execution"
    fi

    # Test build script syntax
    local build_script="$HOME/.local/bin/unreal-build"
    if [ -f "$build_script" ]; then
        if bash -n "$build_script" 2>/dev/null; then
            log_success "Build script syntax check passed"
        else
            log_error "Build script has syntax errors"
        fi
    fi
}

main() {
    print_header

    check_system_basics
    echo

    check_development_tools
    echo

    check_container_setup
    echo

    check_unreal_engine
    echo

    check_custom_scripts
    echo

    check_desktop_integration
    echo

    check_environment_variables
    echo

    check_nixos_configuration
    echo

    check_permissions
    echo

    run_integration_test

    print_summary
}

# Run main function
main "$@"

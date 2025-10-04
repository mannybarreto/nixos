#!/usr/bin/env bash

set -o pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONTAINER_NAME="unreal"
UE_ENGINE_PATH_EXPECTED="$HOME/distrobox/unreal/Linux_Unreal_Engine_5.6.1"
UE_PROJECTS_DIR_EXPECTED="$HOME/distrobox/unreal/Projects"
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
        log_success "$desc: '$cmd' found in PATH"
        return 0
    else
        log_error "$desc: '$cmd' not found in PATH"
        return 1
    fi
}

check_directory() {
    local dir="$1"
    local desc="$2"
    if [ -d "$dir" ]; then
        log_success "$desc: '$dir' exists"
        return 0
    else
        log_error "$desc: '$dir' not found"
        return 1
    fi
}

print_header() {
    echo "============================================================"
    echo "  Declarative Unreal Engine + Rider Verification"
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
        log_success "All checks passed! Your declarative setup is ready."
    else
        log_error "Some checks failed. Review the output above."
        echo "Common solutions:"
        echo "• Run: sudo nixos-rebuild switch"
        echo "• Restart your desktop session (logout/login)"
        echo "• Ensure the 'unreal' distrobox container is running."
    fi
}

# --- Verification Steps ---

check_nixos_tools() {
    log_info "Checking Nix-managed host tools..."
    check_command "rider" "JetBrains Rider IDE"
    check_command "git-lfs" "Git LFS"
    check_command "unreal" "Unreal Editor launcher"
    check_command "unreal-rider" "Unreal Rider launcher"
    check_command "unreal-build" "Unreal build helper"
    check_command "unreal-debug" "Unreal debug helper"
}

check_environment_variables() {
    log_info "Checking Nix-managed environment variables..."
    local vars_ok=true
    if [ -n "${UE_ENGINE_LOCATION:-}" ] && [ "$UE_ENGINE_LOCATION" == "$UE_ENGINE_PATH_EXPECTED" ]; then
        log_success "UE_ENGINE_LOCATION is set correctly"
    else
        log_error "UE_ENGINE_LOCATION is incorrect or not set"
        echo "  Expected: $UE_ENGINE_PATH_EXPECTED"
        echo "  Got: ${UE_ENGINE_LOCATION:-Not set}"
        vars_ok=false
    fi

    if [ -n "${UE_PROJECTS_DIR:-}" ] && [ "$UE_PROJECTS_DIR" == "$UE_PROJECTS_DIR_EXPECTED" ]; then
        log_success "UE_PROJECTS_DIR is set correctly"
    else
        log_error "UE_PROJECTS_DIR is incorrect or not set"
        echo "  Expected: $UE_PROJECTS_DIR_EXPECTED"
        echo "  Got: ${UE_PROJECTS_DIR:-Not set}"
        vars_ok=false
    fi

    if [ "$vars_ok" = false ]; then
        log_warning "Environment variables may require a desktop session restart."
    fi
}

check_unreal_setup() {
    log_info "Checking Unreal Engine directories..."
    check_directory "$UE_ENGINE_PATH_EXPECTED" "Unreal Engine directory"
    check_directory "$UE_PROJECTS_DIR_EXPECTED" "Unreal Projects directory"
}

check_container_setup() {
    log_info "Checking distrobox container setup..."
    if distrobox list | grep -q "$CONTAINER_NAME"; then
        log_success "Distrobox container '$CONTAINER_NAME' exists"
    else
        log_error "Distrobox container '$CONTAINER_NAME' not found"
        return 1
    fi

    log_info "Checking tools within the '$CONTAINER_NAME' container..."
    local container_tools=("clang" "cmake" "dotnet")
    for tool in "${container_tools[@]}"; do
        if distrobox enter "$CONTAINER_NAME" -- bash -c "command -v '$tool'" &>/dev/null; then
            log_success "Container tool: '$tool' is available"
        else
            log_warning "Container tool: '$tool' not found. You may need to install it."
            echo "  Run: distrobox enter $CONTAINER_NAME -- sudo apt install $tool"
        fi
    done
}

main() {
    print_header
    check_nixos_tools
    echo
    check_environment_variables
    echo
    check_unreal_setup
    echo
    check_container_setup
    print_summary
}

main "$@"

# JetBrains Rider + Unreal Engine 5.6.1 Setup Guide

This guide explains how to set up JetBrains Rider for Unreal Engine development on your NixOS system with the existing distrobox container setup.

## Overview

Your NixOS configuration has been enhanced with:

- **JetBrains Rider IDE** - Full-featured C++ and C# development environment
- **Unreal Engine Integration** - Seamless integration with your existing UE 5.6.1 installation
- **Development Tools** - Complete C++/.NET toolchain for Unreal development
- **Build System Integration** - Automated build and debugging tools
- **Containerized Development** - Leverages your existing distrobox setup

## Current Setup

### Existing Installation
- **Unreal Engine**: `~/distrobox/unreal/Linux_Unreal_Engine_5.6.1/`
- **Projects Directory**: `~/distrobox/unreal/Projects/`
- **Container**: `unreal` (Ubuntu 22.04 based)
- **Launch Script**: `~/distrobox/unreal/unreal.bash`

### What's Being Added
- JetBrains Rider IDE with Unreal Engine support
- C++ development tools (Clang, GDB, LLDB)
- .NET SDK 8.0 for Blueprint scripting
- Git LFS for asset management
- Build automation scripts
- Debugging integration

## Installation Steps

### 1. Update Your NixOS Configuration

The development tools have been added to your `modules/home-manager/development.nix`. Apply the changes:

```bash
# Navigate to your nixos-config directory
cd ~/nixos-config

# Rebuild your system configuration
sudo nixos-rebuild switch

# Restart your desktop session (or reboot) for environment variables to take effect
```

### 2. Run the Configuration Scripts

Execute the setup scripts to configure Rider and development environment:

```bash
# Make scripts executable (if not already done)
chmod +x scripts/setup-unreal-rider.sh scripts/configure-rider-unreal.sh

# Run the enhanced Rider configuration
./scripts/configure-rider-unreal.sh
```

This script will:
- Verify your existing Unreal Engine installation
- Install development tools in the distrobox container
- Configure Rider settings for Unreal development
- Create launch scripts and desktop entries
- Set up build and debugging helpers

### 3. Verify Installation

Check that everything is installed correctly:

```bash
# Verify Rider is available
which rider

# Check distrobox container
distrobox list

# Verify Unreal Engine installation
ls ~/distrobox/unreal/Linux_Unreal_Engine_5.6.1/Engine/Binaries/Linux/

# Test the enhanced launcher
unreal-rider --help
```

## Usage

### Launching JetBrains Rider

You have several options for launching Rider:

#### Option 1: Enhanced Launcher (Recommended)
```bash
# Launch with Unreal Engine environment configured
unreal-rider

# Launch on host system (default)
unreal-rider --host

# Launch in distrobox container
unreal-rider --distrobox

# Open specific project
unreal-rider MyGame.uproject
```

#### Option 2: Desktop Entry
- Search for "Unreal Rider" in your application launcher
- Right-click for host/container launch options

#### Option 3: System-wide Script
```bash
# Use the system-wide launcher created in your NixOS config
unreal-rider
```

### Creating Your First Project

1. **Launch Unreal Editor** (existing command):
   ```bash
   unreal
   ```

2. **Create a new C++ project** in the Unreal Editor
   - Choose "Games" → "Third Person" (or your preferred template)
   - Select "C++" (not Blueprint)
   - Set project location to: `~/distrobox/unreal/Projects/YourProjectName`

3. **Generate project files** for Rider:
   ```bash
   unreal-build generate ~/distrobox/unreal/Projects/YourProjectName/YourProjectName.uproject
   ```

4. **Open in Rider**:
   ```bash
   unreal-rider ~/distrobox/unreal/Projects/YourProjectName/YourProjectName.sln
   ```

### Building Projects

Use the integrated build system:

```bash
# Build project (Development configuration)
unreal-build build MyGame.uproject

# Build with specific configuration
unreal-build build MyGame.uproject Debug Linux

# Clean project
unreal-build clean MyGame.uproject

# Regenerate project files
unreal-build generate MyGame.uproject
```

### Debugging

Debug your Unreal projects:

```bash
# Launch project with debugger
unreal-debug launch MyGame.uproject

# Attach to running Unreal Editor
unreal-debug attach UnrealEditor

# Generate debug symbols
unreal-debug symbols MyGame.uproject
```

## Development Workflow

### 1. Typical Development Session

```bash
# Start development container
distrobox enter unreal

# Launch Unreal Editor for design work
unreal

# In another terminal: Launch Rider for code development
unreal-rider --distrobox MyGame.sln

# Build and test
unreal-build build MyGame.uproject
```

### 2. Working with Git and Large Files

Your setup includes Git LFS for handling Unreal Engine assets:

```bash
# Initialize Git LFS in your project (if not already done)
cd ~/distrobox/unreal/Projects/MyGame
git lfs install
git lfs track "*.uasset"
git lfs track "*.umap"
git lfs track "*.fbx"
git lfs track "*.png"
git lfs track "*.jpg"
git add .gitattributes
```

### 3. Rider Configuration

First-time Rider setup:
1. Open Rider
2. Install recommended plugins:
   - C++ language support
   - Unity support (helpful for similar workflows)
   - Markdown support
3. Configure project settings:
   - Set Unreal Engine path: `~/distrobox/unreal/Linux_Unreal_Engine_5.6.1`
   - Configure build tools path
   - Set up code style (Epic Games C++ style guide)

## Troubleshooting

### Common Issues

#### Rider Won't Start
```bash
# Check if Rider is properly installed
nix-env -q | grep rider

# If missing, rebuild your configuration
sudo nixos-rebuild switch
```

#### Build Failures
```bash
# Ensure all development tools are installed in container
distrobox enter unreal
sudo apt update && sudo apt upgrade

# Verify .NET SDK installation
dotnet --version

# Check Unreal Engine installation
ls ~/distrobox/unreal/Linux_Unreal_Engine_5.6.1/Engine/Build/BatchFiles/Linux/
```

#### Graphics Issues
Your existing `unreal.bash` already handles graphics properly. If issues persist:
```bash
# Verify graphics drivers in container
distrobox enter unreal
nvidia-smi  # Should show GPU information
```

#### Container Issues
```bash
# Recreate container if needed
distrobox rm unreal
distrobox create --name unreal --image ubuntu:22.04 --nvidia

# Re-run setup
./scripts/configure-rider-unreal.sh
```

### Environment Variables

Key environment variables set by the configuration:
- `UE_ENGINE_LOCATION`: Path to Unreal Engine installation
- `UE_PROJECTS_DIR`: Path to projects directory
- `DOTNET_CLI_TELEMETRY_OPTOUT`: Disable .NET telemetry
- `SDL_VIDEODRIVER`: Graphics driver configuration
- `VK_ICD_FILENAMES`: Vulkan driver configuration

## Advanced Usage

### Custom Build Configurations

Create custom build scripts in `~/distrobox/unreal/Projects/`:

```bash
# Example: Custom build script for CI/CD
cat > build-production.sh << 'EOF'
#!/bin/bash
unreal-build build MyGame.uproject Shipping Linux
unreal-build package MyGame.uproject Shipping Linux
EOF
```

### Integration with Version Control

For team development:
1. Use Git LFS for binary assets
2. Exclude generated files in `.gitignore`:
   ```
   Binaries/
   Intermediate/
   DerivedDataCache/
   .vs/
   *.sln
   ```

### Performance Optimization

- Use ccache for faster C++ compilation
- Configure sufficient RAM for large projects
- Use SSD storage for better I/O performance

## File Locations Reference

### Configuration Files
- NixOS config: `~/nixos-config/modules/home-manager/development.nix`
- Unreal module: `~/nixos-config/modules/nixos/unreal.nix`
- Setup scripts: `~/nixos-config/scripts/`

### Runtime Locations
- Rider config: `~/.config/JetBrains/`
- Launch scripts: `~/.local/bin/unreal-*`
- Desktop entries: `~/.local/share/applications/`
- Projects: `~/distrobox/unreal/Projects/`

### Container Locations
- Unreal Engine: `/home/mannybarreto/distrobox/unreal/Linux_Unreal_Engine_5.6.1/`
- Development tools: `/usr/bin/`, `/usr/local/bin/`
- .NET SDK: `/usr/share/dotnet/`

## Next Steps

1. **Install Rider Plugins**: Open Rider and install C++ support, Unreal Engine plugin if available
2. **Create First Project**: Follow the project creation workflow above
3. **Configure Team Settings**: Set up shared code style, build configurations
4. **Explore Advanced Features**: Blueprint integration, profiling tools, asset management

## Support

- **NixOS Configuration**: Check `~/nixos-config/` for all configuration files
- **Unreal Engine Documentation**: [Unreal Engine Documentation](https://docs.unrealengine.com/)
- **JetBrains Rider**: [Rider Documentation](https://www.jetbrains.com/help/rider/)
- **Distrobox**: [Distrobox Documentation](https://github.com/89luca89/distrobox)

## Updates

To update your setup:
1. Update NixOS packages: `sudo nixos-rebuild switch`
2. Update container packages: `distrobox enter unreal -- sudo apt update && sudo apt upgrade`
3. Update Unreal Engine: Download new version and update paths in configuration

---

*Last updated: November 2024*
*Compatible with: NixOS, Unreal Engine 5.6.1, JetBrains Rider 2023.3+*
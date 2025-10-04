# JetBrains Rider Alternative Installation Guide

Due to current build issues with the JetBrains Rider package in nixpkgs (JDK build failures), here are alternative methods to install and configure Rider for Unreal Engine development on your NixOS system.

## Problem Summary

The current nixpkgs package for JetBrains Rider is failing to build due to issues with the JetBrains JDK build process. This is a temporary upstream issue that will likely be resolved in future nixpkgs updates.

## Alternative Installation Methods

### Method 1: JetBrains Toolbox (Recommended)

This is the most straightforward approach and matches JetBrains' recommended installation method.

#### Step 1: Install JetBrains Toolbox

```bash
# Create a temporary directory
mkdir -p ~/tmp && cd ~/tmp

# Download JetBrains Toolbox
curl -fsSL https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.2.35332.tar.gz -o toolbox.tar.gz

# Extract and install
tar -xzf toolbox.tar.gz
cd jetbrains-toolbox-*/

# Run the installer
./jetbrains-toolbox
```

The Toolbox will install to `~/.local/share/JetBrains/Toolbox` and create desktop entries automatically.

#### Step 2: Install Rider through Toolbox

1. Open JetBrains Toolbox
2. Find "Rider" in the list
3. Click "Install"
4. Launch Rider once installed

### Method 2: Direct Download and Manual Installation

#### Step 1: Download Rider

```bash
# Create installation directory
sudo mkdir -p /opt/jetbrains
cd ~/tmp

# Download latest Rider (check JetBrains website for current version)
curl -fsSL "https://download.jetbrains.com/rider/JetBrains.Rider-2024.3.1.1.tar.gz" -o rider.tar.gz

# Extract to /opt
sudo tar -xzf rider.tar.gz -C /opt/jetbrains

# Create symlink for easy access
sudo ln -sf /opt/jetbrains/JetBrains\ Rider-*/bin/rider.sh /usr/local/bin/rider
```

#### Step 2: Create Desktop Entry

```bash
# Create desktop entry
mkdir -p ~/.local/share/applications

cat > ~/.local/share/applications/jetbrains-rider.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=JetBrains Rider
Icon=/opt/jetbrains/JetBrains Rider-2024.3.1.1/bin/rider.svg
Exec="/opt/jetbrains/JetBrains Rider-2024.3.1.1/bin/rider.sh" %f
Comment=Cross-platform .NET IDE
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-rider
StartupNotify=true
MimeType=application/x-rider-project;
EOF

# Update desktop database
update-desktop-database ~/.local/share/applications/
```

### Method 3: Using Nix User Environment (Alternative Package)

Sometimes different package versions work when the main one doesn't:

```bash
# Try installing from unstable or a different channel
nix-env -iA nixpkgs.jetbrains.rider

# Or try a specific version if available
nix-shell -p jetbrains.rider --run rider
```

### Method 4: Flatpak Installation

If you have Flatpak enabled:

```bash
# Install Rider via Flatpak
flatpak install flathub com.jetbrains.Rider

# Launch
flatpak run com.jetbrains.Rider
```

## Post-Installation Configuration

### 1. Install Development Tools in Distrobox

Since Rider will need access to build tools, install them in your Unreal Engine container:

```bash
# Enter your Unreal Engine container
distrobox enter unreal

# Install essential development tools
sudo apt update && sudo apt install -y \
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
    unzip

# Install .NET SDK 8
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt update
sudo apt install -y dotnet-sdk-8.0

# Setup git-lfs
git lfs install

# Exit container
exit
```

### 2. Configure Environment Variables

Add these to your shell configuration (`~/.config/fish/config.fish` or `~/.bashrc`):

```bash
# Unreal Engine environment
export UE_ENGINE_LOCATION="$HOME/distrobox/unreal/Linux_Unreal_Engine_5.6.1"
export UE_PROJECTS_DIR="$HOME/distrobox/unreal/Projects"
export PATH="$PATH:$UE_ENGINE_LOCATION/Engine/Binaries/Linux"

# .NET environment
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

# Graphics environment (for containerized development)
export SDL_VIDEODRIVER=wayland
export VK_ICD_FILENAMES=/run/host/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
export LD_LIBRARY_PATH=/run/host/run/opengl-driver/lib:$LD_LIBRARY_PATH
```

### 3. Create Enhanced Launch Script

Create `~/.local/bin/unreal-rider`:

```bash
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

# Launch Rider (adjust path based on your installation method)
if command -v rider &> /dev/null; then
    rider "$@"
elif [ -f "/usr/local/bin/rider" ]; then
    /usr/local/bin/rider "$@"
elif command -v flatpak &> /dev/null && flatpak list | grep -q "com.jetbrains.Rider"; then
    flatpak run com.jetbrains.Rider "$@"
else
    echo "Error: Rider installation not found"
    echo "Please ensure Rider is installed using one of the methods above"
    exit 1
fi
```

Make it executable:

```bash
chmod +x ~/.local/bin/unreal-rider
```

### 4. Configure Build and Debug Scripts

Install the build and debug helper scripts:

```bash
# Run the configuration script to set up additional tools
cd ~/nixos-config
./scripts/configure-rider-unreal.sh
```

## Rider Configuration for Unreal Engine

### First-Time Setup

1. **Launch Rider**:
   ```bash
   unreal-rider
   ```

2. **Install Essential Plugins**:
   - Go to `File → Settings → Plugins`
   - Install these plugins:
     - C++ language support
     - Unreal Engine support (if available)
     - Markdown support

3. **Configure Project Settings**:
   - Set Unreal Engine path: `~/distrobox/unreal/Linux_Unreal_Engine_5.6.1`
   - Configure toolchain paths:
     - CMake: `/usr/bin/cmake` (in container)
     - Debugger: `/usr/bin/gdb` (in container)

### Creating Your First Project

1. **Create Unreal Project**:
   ```bash
   # Launch Unreal Editor
   unreal
   
   # Create a new C++ project
   # Choose "Games" → "Third Person" template
   # Select "C++" (not Blueprint Only)
   # Set location: ~/distrobox/unreal/Projects/YourGameName
   ```

2. **Generate Project Files**:
   ```bash
   # Enter the container
   distrobox enter unreal
   
   # Navigate to your project
   cd ~/distrobox/unreal/Projects/YourGameName
   
   # Generate project files
   ~/distrobox/unreal/Linux_Unreal_Engine_5.6.1/Engine/Build/BatchFiles/Linux/GenerateProjectFiles.sh -project="YourGameName.uproject" -game -rocket -progress
   
   # Exit container
   exit
   ```

3. **Open in Rider**:
   ```bash
   unreal-rider ~/distrobox/unreal/Projects/YourGameName/YourGameName.sln
   ```

## Usage Examples

### Development Workflow

```bash
# 1. Start your development session
distrobox enter unreal

# 2. Launch Unreal Editor (in container)
cd ~/distrobox/unreal/
./unreal.bash

# 3. In another terminal, launch Rider (on host)
unreal-rider

# 4. Open your project solution file
# File → Open → ~/distrobox/unreal/Projects/YourGame/YourGame.sln
```

### Building Projects

```bash
# Build from command line
distrobox enter unreal -- bash -c "
    cd ~/distrobox/unreal/Projects/YourGame
    ~/distrobox/unreal/Linux_Unreal_Engine_5.6.1/Engine/Build/BatchFiles/Linux/Build.sh \
        YourGame Linux Development -project=YourGame.uproject
"
```

### Debugging

1. **Launch with Debugger**:
   ```bash
   distrobox enter unreal -- bash -c "
       cd ~/distrobox/unreal/Projects/YourGame
       gdb --args ~/distrobox/unreal/Linux_Unreal_Engine_5.6.1/Engine/Binaries/Linux/UnrealEditor YourGame.uproject
   "
   ```

2. **Attach to Running Process**:
   - In Rider: `Run → Attach to Process`
   - Select the UnrealEditor process

## Troubleshooting

### Common Issues

1. **Rider Can't Find Unreal Engine**:
   - Verify environment variables are set
   - Check that `$UE_ENGINE_LOCATION` points to the correct path
   - Restart your desktop session after setting environment variables

2. **Build Failures**:
   - Ensure all development tools are installed in the distrobox container
   - Verify .NET SDK is properly installed: `distrobox enter unreal -- dotnet --version`
   - Check that project files are properly generated

3. **Graphics Issues**:
   - Your existing `unreal.bash` script handles graphics properly
   - For Rider integration, ensure environment variables are properly set
   - Use the enhanced launch script provided above

4. **Container Access Issues**:
   - Ensure your user is in the correct groups: `groups`
   - Verify distrobox container is running: `distrobox list`
   - Test container access: `distrobox enter unreal`

### Performance Optimization

1. **Increase Memory**:
   - For large projects, increase Rider's memory allocation
   - Go to `Help → Change Memory Settings`

2. **Exclude Directories**:
   - Exclude build directories from indexing:
     - `Binaries/`
     - `Intermediate/`
     - `DerivedDataCache/`

3. **Use SSD Storage**:
   - Ensure projects are stored on SSD for better performance

## Future Updates

### When nixpkgs Rider is Fixed

Once the JetBrains Rider package in nixpkgs is working again:

1. **Uninstall Manual Installation**:
   ```bash
   # If using manual installation
   sudo rm -rf /opt/jetbrains/JetBrains\ Rider-*
   sudo rm /usr/local/bin/rider
   
   # Remove desktop entry
   rm ~/.local/share/applications/jetbrains-rider.desktop
   ```

2. **Update NixOS Configuration**:
   ```bash
   cd ~/nixos-config
   # Add jetbrains.rider back to modules/home-manager/development.nix
   sudo nixos-rebuild switch --flake .#battlestation
   ```

3. **Use System-wide Installation**:
   The system-wide Rider installation will then be available and properly integrated with your NixOS configuration.

## Verification

Run the verification script to check your setup:

```bash
cd ~/nixos-config
./scripts/verify-setup.sh
```

This will check all components of your development environment and provide guidance on any issues.

---

*This guide provides a workaround for the current nixpkgs Rider build issues. It maintains full functionality while using alternative installation methods.*
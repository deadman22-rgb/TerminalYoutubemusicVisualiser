#!/bin/bash

# Terminal Music Visualizer Installer
# This script installs all dependencies and sets up the application

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Terminal Music Visualizer Installer${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if running on Arch Linux
if [ -f /etc/arch-release ]; then
    echo -e "${GREEN}✓ Arch Linux detected${NC}"
else
    echo -e "${RED}✗ This installer is designed for Arch Linux${NC}"
    echo -e "${YELLOW}You can still proceed, but some steps might fail${NC}"
    read -p "Continue anyway? (y/n): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        echo "Installation aborted."
        exit 1
    fi
fi

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo -e "${BLUE}Installing from:${NC} $SCRIPT_DIR"

# Function to check if a package is installed
is_installed() {
    pacman -Q "$1" &> /dev/null
}

# Install dependencies from pacman
echo -e "\n${BLUE}Installing dependencies from pacman...${NC}"
DEPS=("tmux" "cava" "playerctl" "python-pillow" "kitty")
MISSING=()

for pkg in "${DEPS[@]}"; do
    if is_installed "$pkg"; then
        echo -e "${GREEN}✓ $pkg is already installed${NC}"
    else
        MISSING+=("$pkg")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo -e "${YELLOW}The following packages will be installed:${NC} ${MISSING[*]}"
    sudo pacman -S --needed --noconfirm "${MISSING[@]}" || {
        echo -e "${RED}Failed to install packages.${NC} Please install them manually:"
        echo "sudo pacman -S ${MISSING[*]}"
        exit 1
    }
fi

# Install youtube-music-bin from AUR using yay if not installed
echo -e "\n${BLUE}Checking for YouTube Music...${NC}"
if ! is_installed "youtube-music-bin"; then
    echo -e "${YELLOW}YouTube Music is not installed. Trying to install from AUR...${NC}"
    
    # Check if yay is installed
    if ! command -v yay &> /dev/null; then
        echo -e "${RED}yay is not installed.${NC} It's required to install AUR packages."
        echo -e "Would you like to install yay? (y/n): "
        read install_yay
        if [[ "$install_yay" == "y" || "$install_yay" == "Y" ]]; then
            echo -e "${BLUE}Installing yay...${NC}"
            sudo pacman -S --needed git base-devel
            git clone https://aur.archlinux.org/yay.git /tmp/yay
            cd /tmp/yay
            makepkg -si --noconfirm
            cd "$SCRIPT_DIR"
        else
            echo -e "${YELLOW}Skipping YouTube Music installation.${NC}"
        fi
    fi
    
    if command -v yay &> /dev/null; then
        echo -e "${BLUE}Installing YouTube Music from AUR...${NC}"
        yay -S youtube-music-bin --noconfirm || {
            echo -e "${RED}Failed to install YouTube Music.${NC} You can install it manually:"
            echo "yay -S youtube-music-bin"
        }
    fi
else
    echo -e "${GREEN}✓ YouTube Music is already installed${NC}"
fi

# Set executable permissions
echo -e "\n${BLUE}Setting executable permissions...${NC}"
chmod +x "$SCRIPT_DIR/cavayt.sh"
chmod +x "$SCRIPT_DIR/get_cover.py"
echo -e "${GREEN}✓ Script permissions set${NC}"

# Create desktop entry
echo -e "\n${BLUE}Creating desktop entry...${NC}"
DESKTOP_FILE="$HOME/.local/share/applications/terminal-music-viz.desktop"
mkdir -p "$HOME/.local/share/applications"

cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Type=Application
Name=Terminal Music Visualizer
Comment=Audio visualization with album art in terminal
Exec=kitty -o allow_remote_control=yes -e $SCRIPT_DIR/cavayt.sh
Icon=multimedia-volume-control
Terminal=false
Categories=AudioVideo;Audio;Music;
Keywords=music;visualizer;audio;
EOF

chmod +x "$DESKTOP_FILE"
echo -e "${GREEN}✓ Desktop entry created at:${NC} $DESKTOP_FILE"

# Create a launcher script in the project folder
echo -e "\n${BLUE}Creating launcher script...${NC}"
LAUNCHER="$SCRIPT_DIR/launch-visualizer.sh"

cat > "$LAUNCHER" << EOF
#!/bin/bash
kitty -o allow_remote_control=yes -e $SCRIPT_DIR/cavayt.sh
EOF

chmod +x "$LAUNCHER"
echo -e "${GREEN}✓ Launcher script created at:${NC} $LAUNCHER"

echo -e "\n${GREEN}Installation complete!${NC}"
echo -e "${BLUE}You can now:${NC}"
echo -e "  • Double-click ${YELLOW}launch-visualizer.sh${NC} to start the visualizer"
echo -e "  • Launch from your applications menu"
echo -e "  • Run directly with: ${YELLOW}kitty -o allow_remote_control=yes -e $SCRIPT_DIR/cavayt.sh${NC}"
echo -e "\n${BLUE}Enjoy your music!${NC}" 
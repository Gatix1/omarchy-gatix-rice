#!/bin/bash

# --- VARIABLES ---
CONFIG_DIR="$HOME/.config"
SOURCE_CONFIG_PATH="./config_files" # Assumes your config directories are inside a folder named 'config_files' in the same directory as this script.

# --- FUNCTIONS ---

setup_network_manager() {
    echo "## 🌐 Starting NetworkManager/gazelle-tui Setup"

    # 1. Install NetworkManager and gazelle-tui
    echo "### 1. Installing NetworkManager and gazelle-tui"
    # Install NetworkManager, wpa_supplicant backend, and base-devel for AUR helper
    sudo pacman -S --noconfirm networkmanager wpa_supplicant base-devel

    # --- AUR Installation Check (Assuming 'yay' is used) ---
    if ! command -v yay &> /dev/null
    then
        echo "AUR helper 'yay' not found. Installing it now..."
        # Install yay
        (
            cd /tmp || exit
            git clone https://aur.archlinux.org/yay.git
            cd yay || exit
            makepkg -si --noconfirm
        )
    fi

    # Install gazelle-tui from the AUR
    echo "Installing gazelle-tui from AUR..."
    yay -S --noconfirm gazelle-tui

    echo "Installation complete."

    # 2. Disable iwd and systemd-networkd
    echo "### 2. Disabling iwd and systemd-networkd"
    sudo systemctl stop iwd systemd-networkd
    sudo systemctl disable iwd systemd-networkd

    echo "iwd and systemd-networkd stopped and disabled."

    # 3. Enable and Start NetworkManager
    echo "### 3. Enabling and starting NetworkManager"
    sudo systemctl enable NetworkManager
    sudo systemctl start NetworkManager

    echo "NetworkManager enabled and started."
    echo "## 🌐 NetworkManager setup finished."
}

copy_config_files() {
    echo "## ⚙️ Copying Configuration Files to $CONFIG_DIR"

    # Create the .config directory if it doesn't exist
    mkdir -p "$CONFIG_DIR"

    declare -a configs=("hypr" "omarchy" "waybar")

    for dir in "${configs[@]}"; do
        SOURCE="$SOURCE_CONFIG_PATH/$dir"
        DESTINATION="$CONFIG_DIR/$dir"

        if [ -d "$SOURCE" ]; then
            echo "Copying $dir configuration (replacing existing files)..."
            # Use 'cp -r' for directories and '-f' to force overwrite
            cp -rf "$SOURCE" "$CONFIG_DIR/"
            if [ $? -eq 0 ]; then
                echo "✅ Successfully copied $dir."
            else
                echo "❌ Failed to copy $dir."
            fi
        else
            echo "⚠️ Source directory not found: $SOURCE. Skipping $dir."
        fi
    done

    echo "## ⚙️ Configuration file copying finished."
}

# --- MAIN SCRIPT EXECUTION ---

echo "===================================================="
echo " Starting Gatix dotfiles installation."
echo "⚠️ WARNING: Please backup your dotfiles before proceeding if you care about not loosing them cause they will get replaced." 
echo "===================================================="

# Step 1: Copy all configuration directories
copy_config_files

# Step 2: Run the Network Manager setup
setup_network_manager

# --- FINISH ---
echo " "
echo "################################################################"
echo "### INSTALLATION AND SETUP COMPLETE.                         ###"
echo "### It is MANDATORY to REBOOT to ensure NetworkManager loads.###"
echo "################################################################"
echo " "

read -r -p "Do you want to reboot now? (y/N): " response
case "$response" in
    [yY][eE][sS]|[yY])
        sudo reboot
        ;;
    *)
        echo "Please reboot manually to complete the system switch."
        ;;
esac

#!/bin/bash

# --- Configuration ---
# Set the desired width and height for floating windows (in pixels)
NORMAL_WIDTH=800
NORMAL_HEIGHT=600

# Set the maximum bounds for the random position (e.g., 90% of screen size)
MAX_X_PERCENT=50
MAX_Y_PERCENT=50 # Keep Y lower to avoid hitting the bottom Waybar

# Function to resize and reposition all floating windows on the active workspace
randomly_position_all_floating_windows() {
    # Get the address of the currently active workspace
    ACTIVE_ID=$(hyprctl activeworkspace -j | jq -r '.id')

    # Get a list of all client addresses (window IDs) that are floating on the active workspace
    hyprctl clients -j | \
    jq -r ".[] | select(.workspace.id==$ACTIVE_ID and .floating==true) | .address" | \
    while read -r ADDRESS; do
        
        # 1. Generate a random X percentage (0 to MAX_X_PERCENT)
        RANDOM_X=$(( RANDOM % MAX_X_PERCENT ))
        # 2. Generate a random Y percentage (0 to MAX_Y_PERCENT)
        RANDOM_Y=$(( RANDOM % MAX_Y_PERCENT ))
        
        # Format the position string
        RANDOM_POS="${RANDOM_X}% ${RANDOM_Y}%"
        
        # 3. Focus the window to target it with dispatch commands
        hyprctl dispatch focuswindow address:$ADDRESS
        
        # 4. Resize the window to a normal size
        hyprctl dispatch resizeactive exact $NORMAL_WIDTH $NORMAL_HEIGHT
        
        # 5. Move the window to the random position
        hyprctl dispatch moveactive exact $RANDOM_POS
    done
}

# --- Main Toggle Logic ---

# Find the 'allfloat' state of the focused workspace
IS_FLOAT=$(hyprctl workspaces -j | jq -r '.[] | select(.focused==true) | .properties.allfloat // false')

if [ "$IS_FLOAT" = "true" ]; then
    # Mode is currently 'FLOAT', so turn it OFF (Tiled mode)
    hyprctl dispatch workspaceopt allfloat false
    echo "tiled"
else
    # Mode is currently 'TILED', so turn it ON (Floating-Only mode)
    hyprctl dispatch workspaceopt allfloat
    
    # Run the resize and random positioning function
    randomly_position_all_floating_windows
    
    echo "float"
fi

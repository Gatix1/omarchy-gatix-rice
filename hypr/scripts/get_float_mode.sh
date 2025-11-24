#!/bin/bash

# Check for required utilities
if ! command -v hyprctl &> /dev/null
then
    echo "Error: 'hyprctl' command not found. Please ensure Hyprland is running and hyprctl is in your PATH." >&2
    exit 1
fi

if ! command -v jq &> /dev/null
then
    echo "Error: 'jq' command not found. Please install the jq JSON processor." >&2
    exit 1
fi

# 1. Get the current workspace ID
# We get the list of active workspaces and extract the ID of the one currently focused.
CURRENT_WORKSPACE_ID=$(hyprctl activeworkspace -j | jq -r '.id')

# 2. Query all clients, filter for the current workspace, and check for floating status
# hyprctl clients -j: Get a JSON array of all windows/clients.
# jq:
#   .[] | select(.workspace.id == $CURRENT_WORKSPACE_ID): Selects clients on the current workspace.
#   select(.floating == true): Filters the selection to only clients where the 'floating' property is true.
#   -r 'true': If any match is found, output the string 'true'.
FLOATING_CLIENTS_FOUND=$(
    hyprctl clients -j | jq -r --argjson WID "$CURRENT_WORKSPACE_ID" '
        [
            .[] 
            | select(.workspace.id == $WID) 
            | select(.floating == true)
        ] 
        | length
    '
)

# 3. Check the result and exit
if [ "$FLOATING_CLIENTS_FOUND" -gt 0 ]; then
    echo '{"text": " ", "class": "float-mode"}'
else
    echo '{"text": "󱇙 ", "class": "tiled-mode"}'
fi

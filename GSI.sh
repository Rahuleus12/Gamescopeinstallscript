#!/bin/bash

# Terminal GUI for GSI-CLI.sh script
# This script provides a user-friendly interface for the GSI-CLI.sh script

# Check if dialog is installed
if ! command -v dialog &> /dev/null; then
    echo "dialog is not installed. Installing..."
    if command -v apt &> /dev/null; then
        sudo apt install -y dialog
    elif command -v yum &> /dev/null; then
        sudo yum install -y dialog
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm dialog
    else
        echo "Could not install dialog. Please install it manually and try again."
        exit 1
    fi
fi

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "curl is not installed. Installing..."
    if command -v apt &> /dev/null; then
        sudo apt install -y curl
    elif command -v yum &> /dev/null; then
        sudo yum install -y curl
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm curl
    else
        echo "Could not install curl. Please install it manually and try again."
        exit 1
    fi
fi

# Check if GSI-CLI.sh exists
if [ ! -f "./GSI-CLI.sh" ]; then
    dialog --title "Error" --msgbox "GSI-CLI.sh script not found in the current directory.\nPlease make sure you're running this script from the same directory as GSI-CLI.sh." 8 60
    exit 1
fi

# Make sure GSI-CLI.sh is executable
chmod +x ./GSI-CLI.sh

# Function to display the main menu
show_main_menu() {
    dialog --clear --title "GSI: Gamescope Installer" \
        --menu "What would you like to do today?" 15 60 5 \
        1 "Install Gamescope" \
        2 "Install Specific Version Gamescope" \
        3 "Update Gamescope" \
        4 "Delete Gamescope" \
        5 "Exit" 2>&1 >/dev/tty
}

# Function to get sudo password
get_sudo_password() {
    PASSWORD=$(dialog --title "Sudo Authentication" --passwordbox "This operation requires sudo privileges.\nPlease enter your password:" 10 60 2>&1 >/dev/tty)
    echo "$PASSWORD"
}

# Function to run a script with auto-yes and sudo support
run_script() {
    local script_name=$1
    local action_name=$2
    
    # Get sudo password
    PASSWORD=$(get_sudo_password)
    if [ -z "$PASSWORD" ]; then
        dialog --msgbox "No password provided. Operation cancelled." 5 50
        return
    fi
    
    # Create progress dialog
    dialog --title "$action_name" --infobox "Starting $action_name...\nThis may take a while." 5 50
    sleep 1
    
    # Create a temporary script that will handle the sudo password and auto-yes
    TEMP_SCRIPT=$(mktemp)
    PASS_SCRIPT="${TEMP_SCRIPT}.pass"
    
    # Create the main script
    cat > "$TEMP_SCRIPT" << EOF
#!/bin/bash
# Export the sudo password to avoid multiple prompts
export SUDO_ASKPASS="$PASS_SCRIPT"

# Change to Scripts directory
cd Scripts

# Run the script with automatic yes to all prompts
yes | sudo -A ./${script_name}.sh

# Clean up
rm -f "$PASS_SCRIPT"
EOF
    
    # Create the password script - fixing the syntax error
    cat > "$PASS_SCRIPT" << EOF
#!/bin/bash
echo "$PASSWORD"
EOF
    
    # Make both scripts executable
    chmod +x "$TEMP_SCRIPT" "$PASS_SCRIPT"
    
    # Run the script and capture output
    OUTPUT=$(bash "$TEMP_SCRIPT" 2>&1)
    EXIT_CODE=$?
    
    # Clean up
    rm -f "$TEMP_SCRIPT" "$PASS_SCRIPT"
    
    # Display the output
    if [ $EXIT_CODE -eq 0 ]; then
        dialog --title "Success" --msgbox "$action_name completed successfully!" 6 50
    else
        dialog --title "Error" --msgbox "Error during $action_name.\n\n$OUTPUT" 15 70
    fi
}

# Function to get Gamescope versions from GitHub
get_gamescope_versions() {
    # Create a temporary file to store the versions
    TEMP_FILE=$(mktemp)
    
    # Show progress dialog
    dialog --title "Fetching Versions" --infobox "Fetching Gamescope versions from GitHub...\nPlease wait." 5 50
    
    # Fetch the tags from GitHub
    curl -s "https://api.github.com/repos/ValveSoftware/gamescope/tags" | \
    grep -E '"name"|"sha"' | \
    sed -E 's/.*"name": "([^"]+)".*/\1/; s/.*"sha": "([^"]+)".*/\1/' > "$TEMP_FILE"
    
    # Check if we got any versions
    if [ ! -s "$TEMP_FILE" ]; then
        dialog --msgbox "Failed to fetch Gamescope versions from GitHub.\nPlease check your internet connection and try again." 7 60
        rm -f "$TEMP_FILE"
        return 1
    fi
    
    # Parse the versions and create menu options
    MENU_OPTIONS=()
    VERSION=""
    HASH=""
    COUNT=1
    
    while read -r line; do
        if [ -z "$VERSION" ]; then
            VERSION="$line"
        else
            HASH="$line"
            MENU_OPTIONS+=("$COUNT" "$VERSION ($HASH)")
            VERSION=""
            HASH=""
            COUNT=$((COUNT+1))
        fi
    done < "$TEMP_FILE"
    
    # Add option for manual hash entry
    MENU_OPTIONS+=("M" "Enter hash manually")
    
    # Clean up
    rm -f "$TEMP_FILE"
    
    # Return success
    return 0
}

# Function to install specific version with hash input
install_specific_version() {
    # Get versions from GitHub
    if ! get_gamescope_versions; then
        # If fetching versions failed, fall back to manual entry
        COMMIT_HASH=$(dialog --title "Specific Version Installation" --inputbox "Enter the commit hash from the official GitHub repository:" 8 60 "" 2>&1 >/dev/tty)
        
        if [ -z "$COMMIT_HASH" ]; then
            dialog --msgbox "No commit hash provided. Installation cancelled." 5 50
            return
        fi
    else
        # Show version selection menu
        VERSION_CHOICE=$(dialog --title "Select Gamescope Version" --menu "Choose a version to install:" 20 70 15 "${MENU_OPTIONS[@]}" 2>&1 >/dev/tty)
        
        if [ -z "$VERSION_CHOICE" ]; then
            dialog --msgbox "No version selected. Installation cancelled." 5 50
            return
        fi
        
        if [ "$VERSION_CHOICE" = "M" ]; then
            # Manual hash entry
            COMMIT_HASH=$(dialog --title "Specific Version Installation" --inputbox "Enter the commit hash from the official GitHub repository:" 8 60 "" 2>&1 >/dev/tty)
            
            if [ -z "$COMMIT_HASH" ]; then
                dialog --msgbox "No commit hash provided. Installation cancelled." 5 50
                return
            fi
        else
            # Extract hash from selected version
            SELECTED_VERSION="${MENU_OPTIONS[$((VERSION_CHOICE*2-1))]}"
            COMMIT_HASH=$(echo "$SELECTED_VERSION" | sed -E 's/.*\(([a-f0-9]+)\).*/\1/')
            
            dialog --title "Selected Version" --msgbox "Selected version: ${SELECTED_VERSION}\nCommit hash: $COMMIT_HASH" 7 60
        fi
    fi
    
    # Get sudo password
    PASSWORD=$(get_sudo_password)
    if [ -z "$PASSWORD" ]; then
        dialog --msgbox "No password provided. Installation cancelled." 5 50
        return
    fi
    
    # Create progress dialog
    dialog --title "Specific Version Installation" --infobox "Starting installation of specific version...\nThis may take a while." 5 60
    sleep 1
    
    # Create a temporary script that will handle the sudo password, hash, and auto-yes
    TEMP_SCRIPT=$(mktemp)
    PASS_SCRIPT="${TEMP_SCRIPT}.pass"
    
    # Create the main script
    cat > "$TEMP_SCRIPT" << EOF
#!/bin/bash
# Export the sudo password to avoid multiple prompts
export SUDO_ASKPASS="$PASS_SCRIPT"

# Change to Scripts directory
cd Scripts

# Export the commit hash for the script to use
export COMMIT_HASH="$COMMIT_HASH"

# Run the script with automatic yes to all prompts
yes | sudo -A -E ./gamespec.sh

# Clean up
rm -f "$PASS_SCRIPT"
EOF
    
    # Create the password script - fixing the syntax error
    cat > "$PASS_SCRIPT" << EOF
#!/bin/bash
echo "$PASSWORD"
EOF
    
    # Make both scripts executable
    chmod +x "$TEMP_SCRIPT" "$PASS_SCRIPT"
    
    # Run the script and capture output
    OUTPUT=$(bash "$TEMP_SCRIPT" 2>&1)
    EXIT_CODE=$?
    
    # Clean up
    rm -f "$TEMP_SCRIPT" "$PASS_SCRIPT"
    
    # Display the output
    if [ $EXIT_CODE -eq 0 ]; then
        dialog --title "Success" --msgbox "Specific version installation completed successfully!" 6 60
    else
        dialog --title "Error" --msgbox "Error during specific version installation.\n\n$OUTPUT" 15 70
    fi
}

# Main loop
while true; do
    choice=$(show_main_menu)
    
    case $choice in
        1) run_script "gameinst" "Gamescope Installation" ;;
        2) install_specific_version ;;
        3) run_script "gameup" "Gamescope Update" ;;
        4) run_script "gamedel" "Gamescope Deletion" ;;
        5|"") clear; echo "Exiting Gamescope Installer"; exit 0 ;;
    esac
done 

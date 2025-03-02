#!/bin/bash

# Check if COMMIT_HASH is already set (passed from GSI-CLI.sh)
if [ -z "$COMMIT_HASH" ]; then
    # If not set, ask the user for input
    read -p "Enter the commit hash from the official GitHub repository: " id
    echo "Using commit hash: $id"

else
    # Use the hash passed from GSI-CLI.sh
    id="$COMMIT_HASH"
    echo "Using commit hash: $id"
fi

git clone https://github.com/ValveSoftware/gamescope;
cd gamescope;
git checkout $id;
meson setup --wipe
git submodule update --init;
meson setup build/;
ninja -C build/;
meson install -C build/ --skip-subprojects;


#id="db245f3";
#echo "Enter the hash of the gamescope version you wish to install (available from Gamescope Github)";
#read id;
#git clone https://github.com/ValveSoftware/gamescope;
#cd gamescope;
#git checkout $id;
#git submodule update --init;
#meson setup build/;
#ninja -C build/;
#meson install -C build/ --skip-subprojects;

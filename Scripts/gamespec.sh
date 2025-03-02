#!/bin/bash

# Check if COMMIT_HASH is already set (passed from GSI-CLI.sh)
if [ -z "$COMMIT_HASH" ]; then
    # If not set, ask the user for input
    read -p "Enter the commit hash from the official GitHub repository: " id
else
    # Use the hash passed from GSI-CLI.sh
    id="$COMMIT_HASH"
    echo "$id" >> hashHistory.txt
    echo "Using commit hash: $id"
fi

git clone https://github.com/ValveSoftware/gamescope;
cd gamescope;
git checkout $id;
git submodule update --init;
meson setup build/;
ninja -C build/;
meson install -C build/ --skip-subprojects;

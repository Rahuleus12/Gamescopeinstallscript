#!/bin/bash
id="db245f3";
echo "Enter the hash of the gamescope version you wish to install (available from Gamescope Github)";
read id;
git clone https://github.com/ValveSoftware/gamescope;
cd gamescope;
git checkout $id;
git submodule update --init;
meson setup build/;
ninja -C build/;
meson install -C build/ --skip-subprojects;

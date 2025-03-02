#!/bin/bash
cd gamescope
sudo ninja -C build/ uninstall
cd ..
sudo rm -rf gamescope

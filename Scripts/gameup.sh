#!/bin/bash
cd gamescope
git submodule update --init
meson setup build/
ninja -C build/
#install line
meson install -C build/ --skip-subprojects

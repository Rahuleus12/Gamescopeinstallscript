#!/bin/bash
id= db245f3
git clone https://github.com/ValveSoftware/gamescope
cd gamescope
git checkout $id  # replace <commit_hash> with the relevant commit from above
git submodule update --init
meson setup build/
ninja -C build/
meson install -C build/ --skip-subprojects

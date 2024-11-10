#!/bin/bash
echo "What Would you like to do today?
1.Install Gamscope
2.Install Specific Version Gamscope (requires hash from the official github)
Requires older versions of Gamescope
3.Update Gamscope
4.Delete Gamescope";

read -p "Enter the number: " g;

if [ $g -eq 1 ]; then
    cd Scripts;
    ./gameinst.sh

elif [ $g -eq 2 ]; then
    cd Scripts;
    ./gamespec.sh

elif [ $g -eq 3 ]; then
    cd Scripts;
    ./gameup.sh

elif [ $g -eq 4 ]; then
    cd Scripts;
    ./gamedel.sh

else
echo "incorrect input"
fi

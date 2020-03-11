#!/bin/bash

# 1. Copy shell scripts to bin for better accessibility.
echo
echo "Need password to move some shell scripts into your bin folder, which is a folder always in your path."
echo "This will allow access to each shell script without having to enter in the path. You need this convenience in your life."
sudo cp ~/circle/shell/start_analysis.sh  /bin/
sudo cp ~/circle/shell/finish_analysis.sh /bin/
echo
echo "Great. Now you can just type in, for example, 'start_analysis.sh <date> <username>' without referencing the path to the script file."
echo "Good job."
echo

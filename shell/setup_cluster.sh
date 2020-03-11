#!/bin/bash

# Run on cluster. 

# 1. Make bin folder and add all shell scripts for easy access.
mkdir ~/bin
for file in ~/circle/shell/*; do # Add all shell scripts to bin
	cp $file ~/bin/
done

# 2. Add that bin file to path
cp ~/circle/shell/.bash_profile ~/ # This file denotes the path to the bin that we will add to the user's default path
source ~/.bash_profile # Activate changes

# 3. Make folders for data and move all measureCam files there
mkdir /om2/user/$USER/data/
mkdir /om2/user/$USER/data/circle_data_cluster/
for file in ~/patch/measure/*; do
	cp $file /om2/user/$USER/data/circle_data_cluster/
done

# 4. Make log folder to store analysis logs (i.e. the files containing MATLAB output for each tracking job).
mkdir ~/log/

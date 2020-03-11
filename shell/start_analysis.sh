#!/bin/bash

# $1 is the name of your folder that's on the desktop on the behavior rigs (must be the same across all)
# $2 is date/name of folder to process

cams=( 5 6 7 8)

# 1. Remount hard drive if it was disconnected from the computer recently.
PROCEED="n"
echo "Remount? (y/n)"
read PROCEED
if [ $PROCEED == "y" ]; then
        sudo umount /mnt/x
        sudo rmdir /mnt/x
        sudo mkdir /mnt/x
        sudo mount -t drvfs X: /mnt/x
fi

# 2. Download .avi files from behavior computers.
PROCEED="n"
echo "Download .avi files from behavior rig? (y/n)"
read PROCEED
if [ $PROCEED == "y" ]; then
        # check computers 5-8 for the video folders and download them.
        for cam in "${cams[@]}"; do
                scp -r files@flv-b${cam}.mit.edu:C:/users/flave/desktop/$1/$2 /mnt/x/experiments/
        done
fi

# 3. Select rings locally using GUI
#PROCEED="n"
#echo "Get rings? (y/n)"
#read PROCEED
#if [ $PROCEED == "y" ]; then
#        mat_versions=(/mnt/c/"Program Files"/MATLAB/*)
#        num_versions=${#mat_versions[@]}
#        let latest_version_index=$num_versions-1
#        latest_version_path=${mat_versions[$latest_version_index]}
#        latest_version=${latest_version_path##*/}
#        /mnt/c/"Program Files"/MATLAB/$latest_version/bin/matlab.exe -r "addpath(genpath('\\\\wsl$\\Ubuntu\\home\\$USER\\circle\\matlab)), getRings('$2'), quit"
#
#        PROCEED="n"
#        while [ $PROCEED != "y" ]
#        do
#                echo "Got rings? (y/n)"
#                read PROCEED
#        done
#fi

# 4. Copy over folders containing video files and new fields.mat files
echo "Copying $2 to cluster"
rsync -arv -P /mnt/x/circle_data_local/$1 $USER@openmind.mit.edu:/om2/user/$USER/data/circle_data_cluster

#!/bin/bash

date=$1

for folder in /mnt/x/circle_data_local/$date/*; do
	prefix=${folder##*/}
	scp $USER@openmind.mit.edu:/om2/user/$USER/data/circle_data_cluster/$date/$prefix/${prefix}.linkedTracks.mat $folder
done

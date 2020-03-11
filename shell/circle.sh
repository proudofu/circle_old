#!/bin/bash

date=$1

# Loop through .avi files and submit processing jobs
for vidfolder in /om2/user/$USER/data/circle_data_cluster/$date/*; do
        cp ~/circle/measure/1504_730_2304_2300.Ring.mat $vidfolder/$(basename $vidfolder).Ring.mat # copy generic ring to folder
	sbatch ~/circle/shell/subcircle.sh $vidfolder
done

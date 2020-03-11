#!/bin/bash

date=$1

# Loop through .avi files and submit processing jobs
for vidfolder in /om2/user/$USER/data/circle_data_cluster/$date/*; do
        sbatch ~/circle/shell/subcircle.sh $vidfolder
done

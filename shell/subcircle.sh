#!/bin/bash
#
#SBATCH --output=/home/%u/log/subcircle_%j.txt
#SBATCH -n1
#SBATCH --job-name=subcircle_j%
#SBATCH --nodes=1
#SBATCH --mem=40000
#SBATCH --time=100:00:00

# $1: Name of video
vidfolder=$1
date=${vidfolder%-*}
echo $vidfolder
echo $date

# Load matlab and launch tracker command.
module add mit/matlab/2014a
matlab -nodisplay -r "addpath(genpath('/home/$USER/circle')), addpath(genpath('/om2/user/$USER/data/circle_data_cluster')), TrackerAutomatedScript2('/om2/user/$USER/data/circle_data_cluster/$date/$vidfolder/${vidfolder}.avi', 'scale', '/home/$USER/circle/measure/measureCam.avi', 'NumWorms', [30, 80]), exit;"

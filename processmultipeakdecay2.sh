#!/bin/bash
#
#SBATCH --output=/om/user/kmaher/log/circle_%j.txt
#SBATCH -n1
#SBATCH --error=/om/user/kmaher/log/circle_%j.err
#SBATCH --job-name=circle_j%
#SBATCH --nodes=1
#SBATCH --mem=40000
#SBATCH --time=40:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kmaher@mit.edu

# $1: Name of video
# $2: Cam number

module add mit/matlab/2014a
matlab -nodisplay -r "addpath(genpath('/om/user/kmaher/scripts/matlab/circle/MATLAB')), TrackerAutomatedScript2('20190410_ASH_05_35_Cam6.avi', 'scale', '20190410_measureCam6.avi', 'NumWorms', [30, 80]), exit;" 


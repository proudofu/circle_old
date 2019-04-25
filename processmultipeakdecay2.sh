#!/bin/bash
#
#SBATCH --output=04072019_mod1ser4_multiramp_prestarved_cam2_vid1.out
#SBATCH -n1
#SBATCH --error=04072019_mod1ser4_multiramp_prestarved_cam2_vid1.err
#SBATCH --job-name=04072019_mod1ser4_multiramp_prestarved_cam2_vid1
#SBATCH --nodes=1
#SBATCH --mem=50000
#SBATCH --time=40:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ijnwab@mit.edu
module add mit/matlab/2014a
matlab -nodisplay -r "disp('Starting...'), addpath(genpath('/om/user/ijnwab/Matlab')), TrackerAutomatedScript2('04072019_mod1ser4_multiramp_prestarved_cam2_vid1.avi', 'scale', 'measureCam2.avi', 'NumWorms', [10, 500]), exit;" 


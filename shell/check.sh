#!/bin/bash

date=$1

echo
echo "_______________________________________________________________________________________________"
echo "Videos with processed linkedTracks:"
echo
for vidfolder in /om2/user/$USER/data/circle_data_cluster/$date/*; do
	if [ -e $vidfolder/*linkedTracks* ]; then
		echo ${vidfolder##*/}
	fi
done
echo "_______________________________________________________________________________________________"
echo "Videos without processed linkedTracks:"
echo
for vidfolder in /om2/user/$USER/data/circle_data_cluster/$date/*; do
	if [ ! -e $vidfolder/*linkedTracks* ]; then
		echo "${vidfolder##*/}"
	fi
done
echo
echo

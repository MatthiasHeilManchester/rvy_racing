#! /bin/bash

# Just one command line argument
if [ $# -ne 1 ]; then
 echo "Please specify the race series"
 exit 1
fi



# Name of race series
race_series=$1

# Script should be run from home directory
home_dir=`pwd`
if [ ! -e master_race_data ]; then
    echo "ERROR: Script ought to be run from home directory, so that"
    echo "directory master_race_data is available as ./master_race_data."
    echo "You are in $home_dir"
    exit 1
fi

# Does race series even exist?
if [ ! -e master_race_data/$race_series ]; then
    echo "ERROR: Race series master_race_data/$race_series doesn't exist!"
    exit 1
fi
echo " "
echo "==========================================================================="
echo " "
echo "(Re-)processing all completed races up series : "$race_series
cd master_race_data/$race_series
for dir in `ls -d race*`; do
#    echo $dir;
    cd $dir;
    ../../../bin/process_race_outcome.bash
    cd ..
done;





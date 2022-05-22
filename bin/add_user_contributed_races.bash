#!/bin/bash


# Just one command line argument
if [ $# -ne 1 ]; then
 echo "Please specify the race series"
 echo "You are in"`pwd` 
 exit 1
fi

echo "hello shite from add_user_contributed_races.bash"`date` >> ../user_uploaded_data/shite.txt

exit

# Name of race series
race_series=$1

# Script is run from html
if [ ! -e ../master_race_data/$race_series ]; then
    echo "ERROR: Script ought to be run from one directory below home directory, so that"
    echo "directory $race_series is available as ../master_race_data/$race_series."
    echo "You are in"`pwd` > shite.txt
    exit 1
fi

echo "yay -- all hunky dory" > shite.txt


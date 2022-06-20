#! /bin/bash

# Script should be run from home directory
home_dir=`pwd`
if [ ! -e master_race_data ]; then
    echo "ERROR: Script ought to be run from home directory, so that"
    echo "directory master_race_data is available as ./master_race_data."
    echo "You are in $home_dir"
    exit 1
fi

cd master_race_data
tar cfz ../transfer_data/master_race_data.tar.gz *

cd ../contributed_race_data
tar cfz ../transfer_data/contributed_race_data.tar.gz *



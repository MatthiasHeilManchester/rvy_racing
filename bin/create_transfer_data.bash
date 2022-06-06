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
tar cvfz ../transfer_data/master_race_data.tar.gz *


# hierher:
# - do same with contributed race data but get rid of all the generated stuff in there. tmp download directories can be created on the fly and they're emotied anyway.
# - also check if all download directories in generated_race_data are actually needed/used.

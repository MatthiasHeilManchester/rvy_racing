#! /bin/bash

#---------------------------------------------------------
# Process race outcome for all races in specified series
#---------------------------------------------------------

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
    echo -e "\033[0;31mERROR:\033[0m Script ought to be run from home directory, so that"
    echo "directory master_race_data is available as ./master_race_data."
    echo "You are in $home_dir"
    exit 1
fi

# Does race series even exist?
if [ ! -e master_race_data/$race_series ]; then
    echo -e "\033[0;31mERROR:\033[0m Race series master_race_data/$race_series doesn't exist!"
    exit 1
fi

# Has it been staged?
if [ ! -e generated_race_data/$race_series ]; then
    echo -e "\033[0;31mERROR:\033[0m Race series generated_race_data/$race_series doesn't exist; race probably hasn't been staged!"
    exit 1
fi


echo " "
echo "==========================================================================="
echo " "
echo "(Re-)processing all completed races up series : "$race_series
cd generated_race_data/$race_series
for dir in `ls -d race*`; do
    echo " "
    echo "--------------------------------------------------------"
    echo " " 
    echo "Doing: " $dir
    cd $dir
    ../../../bin/process_race_outcome.bash
    cd ..
done

echo "Done. now run "
echo " "
echo "    bin/create_overall_league_table.bash "
echo " " 




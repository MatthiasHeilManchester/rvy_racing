#! /bin/bash

#--------------------------------------------------------
# Script to prune selected race in specified race series
# and shuffle all the others into place
#--------------------------------------------------------

#  Exactly two command line arguments
if [ $# -ne 2 ]; then
 echo "Please specify the race series and number of the race to be pruned."
 exit 1
fi
  
# Be verbose for debugging?
verbose_debug=1

# Name of race series
race_series=$1

# Race number
race_number_to_be_pruned=$2

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

race_dir_to_be_pruned="race"`echo $race_number_to_be_pruned | awk '{printf "%05d\n",$1}'`
if [ ! -e master_race_data/$race_series/$race_dir_to_be_pruned ]; then
    echo -e "\033[0;31mERROR:\033[0m Race master_race_data/$race_series/$race_dir_to_be_pruned doesn't exist!"
    exit 1
fi

# Does contributed race series even exist?
if [ ! -e contributed_race_data/$race_series ]; then
    echo -e "\033[0;31mERROR:\033[0m Race series contributed_race_data/$race_series doesn't exist!"
    exit 1
fi

contributed_race_dir_to_be_pruned="race"`echo $race_number_to_be_pruned | awk '{printf "%05d\n",$1}'`
if [ ! -e contributed_race_data/$race_series/$race_dir_to_be_pruned ]; then
    echo -e "\033[0;31mERROR:\033[0m Race contributed_race_data/$race_series/$race_dir_to_be_pruned doesn't exist!"
    exit 1
fi

echo "About to prune: "
echo "   master_race_data/"$race_series"/"$race_dir_to_be_pruned
echo "   contributed_race_data/"$race_series"/"$race_dir_to_be_pruned
echo "and then shift the other directories downwards."
echo " " 
read -p "Press enter to continue"


# Check if lock File exists, if not create it and set trap on exit
# but first check if we even have write permission here!
orig_dir=`pwd`
cd generated_race_data
rm -f .date.dat
date --utc > .date.dat
if [ ! -e .date.dat ]; then
    echo -e "\033[0;31mERROR:\033[0m Don't appear to have write permission in "`pwd`
    echo "Locking is likely to fail..."
fi
rm -f .date.dat

# Check is lock File exists, if not create it and set trap on exit
lock_file_name=`pwd`"/global_lock_file.lock"
if { set -C; 2>/dev/null > $lock_file_name; }; then
    trap "rm -f $lock_file_name" EXIT
else
    echo "prune selected race script found lock file in: "
    echo " "
    echo "   "$lock_file_name
    echo " "
    echo "Bailing out."
    exit 1
fi
cd $orig_dir
echo "Orig dur: " $orig_dir
big_dir_list="master_race_data/"$race_series" contributed_race_data/"$race_series
for big_dir in `echo $big_dir_list`; do
    cd $big_dir
    ndir=`find . -type d -name 'race?????' | wc -w`
    echo "ndir = "$ndir    
    current_dir_number=1
    while [ $current_dir_number -le $ndir ]; do
        echo "race dir number = "$current_dir_number
        old_dir="race"`echo $current_dir_number | awk '{printf "%05d\n",$1}'`
        if [ $current_dir_number -eq $race_number_to_be_pruned ]; then            
            echo "Deleting race dir: "$current_dir_dir_number" : "$old_dir
            rm -rf $old_dir
        elif [ $current_dir_number -lt $race_number_to_be_pruned ]; then           
            echo "Not moving race dir: "$current_dir_dir_number" : "$old_dir
        elif [ $current_dir_number -gt $race_number_to_be_pruned ]; then     
            let new_dir_number=$current_dir_number-1
            new_dir="race"`echo $new_dir_number | awk '{printf "%05d\n",$1}'`
            echo "Moving race dir: "$current_dir_number" : "$old_dir" to "$new_dir
            mv $old_dir $new_dir
        else
            echo "Never get here"
            exit 1
        fi
        ((current_dir_number++))
    done
    cd $orig_dir
done


echo " "
echo "Done. Please re-stage/process the races, running either"
echo " "
echo "  bin/bolshy_process_races.bash "$race_series
echo " "
echo "or"
echo " " 
echo "  bin/bolshy_stage_races.bash "$race_series"
echo " " 


exit



echo " "
echo "==========================================================================="
echo " "
echo "Bolshily setting up series : "$race_series


# Create log file
date_string=`date --utc | sed 's/ /_/g'`
log_file="bolshy_logs/bolshy_stage_races_"$date_string".log"
echo "log file: "$log_file

# Stage 'em
echo " "  > $log_file
echo "##############################################################"  >> $log_file
echo " " >> $log_file
echo "Calling stage_official_races from bolshy_stage_races.bash" >> $log_file
echo " " >> $log_file
echo "##############################################################" >> $log_file
echo " " >> $log_file
bin/stage_official_races.bash $race_series >> $log_file
echo " " >> $log_file
echo "##############################################################" >> $log_file
echo " " >> $log_file
echo "Done calling stage_official_races from bolshy_stage_races.bash" >> $log_file
echo " " >> $log_file
echo "##############################################################" >> $log_file
echo " " >> $log_file

# Publish 'em
echo " " >> $log_file
echo "##############################################################"  >> $log_file
echo " " >> $log_file
echo "Calling publish_webpages.bash from bolshy_stage_races.bash" >> $log_file
echo " " >> $log_file
echo "##############################################################" >> $log_file
echo " " >> $log_file
bin/publish_webpages.bash >> $log_file
echo " " >> $log_file
echo "##############################################################" >> $log_file
echo " " >> $log_file
echo "Done publish_webpages.bash from bolshy_stage_races.bash" >> $log_file
echo " " >> $log_file
echo "##############################################################" >> $log_file
echo " " >> $log_file

echo "Done the lot, ending up with updated webpages!"
echo " " 
echo "Log file: "
echo " "
echo "          "$log_file
echo " "
echo " " 

exit 0

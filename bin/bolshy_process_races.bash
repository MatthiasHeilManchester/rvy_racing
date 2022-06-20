
#! /bin/bash


# Just one command line argument
if [ $# -ne 1 ]; then
 echo "Please specify the race series"
 exit 1
fi

# Be verbose for debugging?
verbose_debug=1

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


# Check if lock File exists, if not create it and set trap on exit
# but first check if we even have write permission here!
orig_dir=`pwd`
cd generated_race_data
rm -f .date.dat
date > .date.dat
if [ ! -e .date.dat ]; then
    echo "ERROR: Don't appear to have write permission in "`pwd`
    echo "Locking is likely to fail..."
fi
rm -f .date.dat

# Check is lock File exists, if not create it and set trap on exit
lock_file_name=`pwd`"/global_lock_file.lock"
if { set -C; 2>/dev/null > $lock_file_name; }; then
    trap "rm -f $lock_file_name" EXIT
else
    echo "bolshy stage races script found lock file in: "
    echo " "
    echo "   "$lock_file_name
    echo " "
    echo "Bailing out."
    exit 1
fi
cd $orig_dir


echo " "
echo "==========================================================================="
echo " "
echo "Bolshily processing races in series : "$race_series


# Create log file
date_string=`date --utc | sed 's/ /_/g'`
log_file="bolshy_logs/bolshy_process_races_"$date_string".log"
echo "log file: "$log_file

orig_dir=`pwd`
cd generated_race_data/$race_series
rm -f *.log
cd $orig_dir



# Stage 'em
echo " "  > $log_file
echo "##############################################################"  >> $log_file
echo " " >> $log_file
echo "Calling stage_official_races from bolshy_process_races.bash" >> $log_file
echo " " >> $log_file
echo "##############################################################" >> $log_file
echo " " >> $log_file
bin/stage_official_races.bash $race_series >> $log_file
echo " " >> $log_file
echo "##############################################################" >> $log_file
echo " " >> $log_file
echo "Done calling stage_official_races from bolshy_process_races.bash" >> $log_file
echo " " >> $log_file
echo "##############################################################" >> $log_file
echo " " >> $log_file


# Process race by race
echo " " >> $log_file
echo "##############################################################"  >> $log_file
echo " " >> $log_file
echo "Calling /process_race_outcome_for_all_races_in_series from bolshy_process_races.bash" >> $log_file
echo " " >> $log_file
echo "##############################################################" >> $log_file
echo " " >> $log_file
bin/process_race_outcome_for_all_races_in_series.bash $race_series >> $log_file
echo " " >> $log_file
echo "##############################################################" >> $log_file
echo " " >> $log_file
echo "Done process_race_outcome_for_all_races_in_series from bolshy_process_races.bash" >> $log_file
echo " " >> $log_file
echo "##############################################################" >> $log_file
echo " " >> $log_file


# Create league table
echo " " >> $log_file
echo "##############################################################"  >> $log_file
echo " " >> $log_file
echo "Calling create_overall_league_table.bash from bolshy_process_races.bash" >> $log_file
echo " " >> $log_file
echo "##############################################################" >> $log_file
echo " " >> $log_file
bin/create_overall_league_table.bash $race_series >> $log_file
echo " " >> $log_file
echo "##############################################################" >> $log_file
echo " " >> $log_file
echo "Done create_overall_league_table.bash from bolshy_process_races.bash" >> $log_file
echo " " >> $log_file
echo "##############################################################" >> $log_file
echo " " >> $log_file



# Publish 'em
echo " " >> $log_file
echo "##############################################################"  >> $log_file
echo " " >> $log_file
echo "Calling publish_webpages.bash from bolshy_process_races.bash" >> $log_file
echo " " >> $log_file
echo "##############################################################" >> $log_file
echo " " >> $log_file
bin/publish_webpages.bash >> $log_file
echo " " >> $log_file
echo "##############################################################" >> $log_file
echo " " >> $log_file
echo "Done publish_webpages.bash from bolshy_process_races.bash" >> $log_file
echo " " >> $log_file
echo "##############################################################" >> $log_file
echo " " >> $log_file



echo " " 
echo "Done the lot, ending with updated webpages!"
echo " "
echo "Log file: "
echo " "
echo "          $ $log_file
echo " "
echo " " 

exit 0

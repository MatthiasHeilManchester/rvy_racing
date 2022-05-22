#!/bin/bash


# Five command line arguments
if [ $# -ne 5 ]; then
 echo "Five args: race_series race_url route_id race_number race_date_string"
 exit 1
fi

# Convert input params to sensible numbers
race_series=$1
race_url=$2
route_id=$3
race_number=$4
race_date_string=$5

echo "TEMPORARILY DESCENDING INTO HTML DIRECTORY"
cd html


# Script should be run from one level below home dir (because it's ususally
# called from php script in html directory
home_dir=`pwd`
if [ ! -e ../master_race_data ]; then
    echo "ERROR: Script ought to be run one level below home directory, so that"
    echo "directory master_race_data is available as ../master_race_data."
    echo "You are in $home_dir"
    exit 1
fi


echo $race_series >> ../user_uploaded_data/shitte.txt
echo $race_url >> ../user_uploaded_data/shitte.txt
echo $route_id >> ../user_uploaded_data/shitte.txt
echo $race_number >> ../user_uploaded_data/shitte.txt
echo $race_date_string >> ../user_uploaded_data/shitte.txt



# check that required data exists as official race series and race
master_series_dir=../master_race_data/$race_series
if [ ! -e $master_series_dir ]; then
    echo "Race series "$master_race_series" doesn't exist."
    echo "Can't contribute user race!"
    exit 1
fi
master_race_dir=../master_race_data/$race_series/race`echo $race_number | awk '{printf "%05d\n",$1}'`
if [ ! -e $master_race_dir ]; then
    echo "Official race doesn't exist : "$master_race_dir
    echo "Can't contribute user race!"
    exit 1
fi

# Create corresponding directories for contributed race
series_dir=../contributed_race_data/$race_series
if [ ! -e $series_dir ]; then
    echo "Race series dir for contributed race of series "$race_series" doesn't exist yet: "$series_dir
    mkdir $series_dir
else
    echo "Race series dir for contributed race of series "$race_series" already exists: "$series_dir
    ls -l $series_dir
fi
race_dir=../contributed_race_data/$race_series/race`echo $race_number | awk '{printf "%05d\n",$1}'`
if [ ! -e $race_dir ]; then
    echo "Race dir doesn't exist yet: "$race_dir
    mkdir $race_dir
else
    echo "Race dir already exists: "$race_dir
    ls -l $race_dir
fi


# Go to race directory and check things out
cd $race_dir
if [ ! -e  contributed_race.dat ]; then
    echo $race_url > contributed_race.dat
else
    existing_url_list=`cat  contributed_race.dat`
    for existing_url in `echo $existing_url`; do
        echo "Existing url: "$existing_url
        if [ $race_url == $existing_url ]; then
            echo "New race url "$race_url" is the same as existing race url "$existing_url
            echo "Skipping"
            exit
        else
            echo "New race url "$race_url" differs from existing race url "$existing_url
        fi
    done
fi

#- download race html file to check if it exists and check consistency (route id and date)


# Get route id from first official race and compare against this
# echo $route_id >> ../user_uploaded_data/shitte.txt

# Get race date string from first official race and compare against this
# and against the version from 
# echo $race_date_string >> ../user_uploaded_data/shitte.txt


# If all tests pass add this to the list of user-contributed races in contributed_race_data.dat
#echo $race_url >> ../user_uploaded_data/shitte.txt




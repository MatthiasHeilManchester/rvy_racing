#! /bin/bash

# Create a new race in the race series directory
if [ ! -e ../../master_race_data ] || [ ! -e user_list.txt  ]; then
    echo "You're in the wrong directory. This is supposed to be run in the "
    echo "race series directory, e.g. in "
    echo " "
    echo "      master_race_data/fake_commute"
    echo " "
    echo "which must contain the file "
    echo " "
    echo "      user_list.txt"
    echo " "
    echo "You are in:"
    echo " "
    echo "       "`pwd`
    echo " "
    echo "which contains:"
    echo " "
    ls -l
    echo " "
    exit 1
fi

# Create the next race (assuming existing ones are already numbered
# race?????
existing_race_list=`find . -name 'race[0-9][0-9][0-9][0-9][0-9]' -type d | sort`
next_race_number=0;
count=1
if [ "$existing_race_list" == "" ]; then
    next_race_number=00001
else
    echo "have races: " $existing_race_list
    for race in `echo $existing_race_list`; do
        let count=$count+1
        test_race_number=`echo $count | awk '{printf "%05d\n",$1}'`
        next_race_number=`echo $race | awk '{printf "%05d\n",(substr($1,7,5)+1)}'`
        if [ $test_race_number -ne $next_race_number ]; then
            echo "ERROR: Directory " $race " is not enumerated consistently!"
            exit 1
        fi
    done
fi

new_dir=race$next_race_number
if [ -e $new_dir ]; then
    echo "ERROR: Race directory "$new_dir" already exists."
    exit 1
fi
mkdir $new_dir
cd $new_dir
echo " "
echo "============================================================="
echo "I'm opening the new official_race.dat for you."
echo "Add the URLs of the (sub)-races (for different timezones)."
echo "============================================================="
echo " "
echo "Opening file with: "$EDITOR
echo " "
$EDITOR official_race.dat 
echo " "
echo "============================================================="
echo "Done!"
echo "I've created "
echo " " 
echo "             "$new_dir"/official_race.dat" 
echo " " 
echo "Please make sure you stage this race by running"
echo " " 
echo "             bin/stage_official_races.bash <race_series>" 
echo " " 
echo "in the home directory."
echo "============================================================="
echo " "

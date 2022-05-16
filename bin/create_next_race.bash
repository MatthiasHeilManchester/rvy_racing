#! /bin/bash

# Create the next race (assuming existing ones are already numbered
# race?????
existing_race_list=`find . -name 'race[0-9][0-9][0-9][0-9][0-9]' -type d`
next_race_number=0;
count=1
for race in `echo $existing_race_list`; do
    let count=$count+1
    test_race_number=`echo $count | awk '{printf "%05d\n",$1}'`
    next_race_number=`echo $race | awk '{printf "%05d\n",(substr($1,7,5)+1)}'`
    if [ $test_race_number -ne $next_race_number ]; then
        echo "ERROR: Directory " $race " is not enumerated consistently!"
        exit 1
    fi
done

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
emacs official_race.dat 

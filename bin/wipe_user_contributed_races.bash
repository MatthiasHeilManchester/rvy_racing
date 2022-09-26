#!/bin/bash


#-------------------------------------------------------------
# Wipe user contributed races (i.e. backup and replace with
# empty files
#-------------------------------------------------------------

# More output for debugging
verbose_debug=0


# Script should be run from three levels below home dir
home_dir=`pwd`
if [ ! -e ../../../master_race_data ]; then
    echo -e "Error: Script ought to be run three levels below home directory, so that"
    echo "directory master_race_data is available as ../../../master_race_data."
    echo "You are in $home_dir"
    exit 1
fi


# Check that we're in the promising looking directory:
if [ ! -e contributed_race.dat ]; then
    echo "Doesn't look like we're in the right directory. I can't find"
    echo "the file "
    echo " "
    echo "           contributed_race.dat"
    echo " "
    echo "Here's the content of the current directory:"
    echo " "
    ls -l
    echo " " 
    exit 1;
fi
if [ ! -e contributed_race_list_items.html ]; then
    echo "Doesn't look like we're in the right directory. I can't find"
    echo "the file "
    echo " "
    echo "           contributed_race_list_items.html"
    echo " "
    echo "Here's the content of the current directory:"
    echo " "
    ls -l
    echo " " 
    exit 1;
fi


# Back it up!
touch contributed_race_backup_before_wiping.dat
date >> contributed_race_backup_before_wiping.dat
cat contributed_race.dat contributed_race_list_items.html >> contributed_race_backup_before_wiping.dat

# Kill 'em
rm contributed_race.dat
touch contributed_race.dat
rm contributed_race_list_items.html
touch contributed_race_list_items.html


# Now what
echo " "
echo "Done! I've deleted the user contributed races in "
echo " "
echo "       "`pwd`
echo " "
echo "Now re-stage the races!"
echo " "



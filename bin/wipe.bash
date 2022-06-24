#! /bin/bash


#----------------------------------------------------
# Wipe race data. Mainly used during
# development.
#----------------------------------------------------

# Script should be run from home directory
home_dir=`pwd`
if [ ! -e master_race_data ]; then
    echo -e "\033[0;31mERROR:\033[0m Script ought to be run from home directory, so that"
    echo "directory master_race_data is available as ./master_race_data."
    echo "You are in $home_dir"
    exit 1
fi


echo " " 
echo "This is going to wipe master and contributed race data"
echo "so it can be re-processed cleanly."
echo "Involves find with rm -rf so have a deep breath first..."
echo " "
read -p "Press enter to continue"
echo " " 


# Wipe
echo "wiping"
dir_list=`find  contributed_race_data generated_race_data generated_html master_race_data -maxdepth 1 -mindepth 1 -type d `
for dir in `echo $dir_list`; do
    #ls -d `pwd`/$dir
    rm -rf $dir
done
echo "done wiping"

exit

    

#! /bin/bash


#----------------------------------------------------------------
# Insert private data into results and league table html tables
#----------------------------------------------------------------

# Just one command line argument
if [ $# -ne 1 ]; then
 echo "Please specify the race series"
 exit 1
fi

# Name of race series
race_series=$1

if [ ! -e  generated_race_data ]; then
    echo -e "\033[0;31mERROR:\033[0m Script must be run in home directory so generated_race_data is"
    echo "accessible as ./generated_race_data"
    echo " "
    echo "You are in: "`pwd`
    echo " "
    exit
fi

# Bash script that does padding with sed
bash_script_for_sed_based_padding=`pwd`/master_race_data/$race_series/pad_results_with_private_data.bash
if [ ! -e $bash_script_for_sed_based_padding ]; then
    echo "Bash script for sed based paddding "
    echo " "
    echo "      "$bash_script_for_sed_based_padding
    echo " "
    echo "not found"
    exit 1
fi


home_dir=`pwd`
dir_list=`ls -d generated_race_data/$race_series*`
for dir in `echo $dir_list`; do
    cd $dir
    file_list='league_table.html'
    if [ -e league_table_wed.html ]; then
	file_list=$file_list" league_table_wed.html"
    fi
    if [ -e league_table_sat.html ]; then
	file_list=$file_list" league_table_sat.html"
    fi
    file_list=$file_list" "`find . -name 'results.html'`
    for file in `echo $file_list`; do
	if [ -e $file ]; then
	    $bash_script_for_sed_based_padding $file
	fi
    done
    cd $home_dir
done

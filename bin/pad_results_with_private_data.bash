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

if [ ! -e  generated_html ]; then
    echo -e "\033[0;31mERROR:\033[0m Script must be run in home directory so generated_html is"
    echo "accessible as ./generated_html"
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

cd generated_html/$race_series
file_list='league_table.html'
file_list=$file_list" "`find . -name 'results.html'`
for file in `echo $file_list`; do
    $bash_script_for_sed_based_padding $file
done

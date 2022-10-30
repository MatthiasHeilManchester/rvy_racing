#! /bin/bash

#--------------------------------------------------------
# Script to create "monster of the month league table"
#--------------------------------------------------------

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
if [ ! -e generated_race_data ]; then
    echo -e "\033[0;31mERROR:\033[0m Script ought to be run from home directory, so that"
    echo "directory generated_race_data is available as ./generated_race_data."
    echo "You are in $home_dir"
    exit 1
fi

# Does race series even exist?
if [ ! -e generated_race_data/$race_series ]; then
    echo -e "\033[0;31mERROR:\033[0m Race series generated_race_data/$race_series doesn't exist!"
    exit 1
fi

# Back home?
home_dir=`pwd`



#hierher loop over these
month_string="Oct"
year_string="2022"


month_race_series=$race_series"_"$month_string"_"$year_string

month_dir=`pwd`"/generated_race_data/"$month_race_series
echo "month dir: "$month_dir

# New month?
if [ ! -e $month_dir ]; then
    mkdir $month_dir
fi

# Duplicate master dir via link (same data)
master_month_dir=`pwd`"/master_race_data/"$month_race_series
master_dir=`pwd`"/master_race_data/"$race_series
echo "master_month dir: "$master_month_dir
echo "master_dir      : "$master_dir

# New month?
if [ ! -e $master_month_dir ]; then
   ln -s $master_dir $master_month_dir
fi


# Go to full race series
race_dir=`pwd`"/generated_race_data/"$race_series
cd $race_dir

dir_list=`find .  -maxdepth 1 -type d -name 'race?????' -exec basename {} \;`
for dir in `echo $dir_list`; do
    found_chars=`grep -H -i $month_string $dir/*html | grep '<h2>Race' | grep $year_string | wc -c`
    echo "dir: "$dir" found chars: "$found_chars
    if [ $found_chars -ne 0 ]; then
	prev_dir=`pwd`
	cd $month_dir
	if [ ! -e $dir ]; then
	    echo "I'm in "`pwd` . "Linking "$dir" to ../"$dir
	    ln -s $race_dir/$dir $dir
	else
	    echo "Not linking "$dir" because link already exists."
	fi
	cd $prev_dir
    else
	echo "Not linking "$dir" because it's the wrong month"
    fi
done


# Goin' home
cd $home_dir

# Create league table
bin/create_overall_league_table.bash $month_race_series

# Monster it up!
sed -i "s/<h2>Overall league table/<h1>Monster of the Month<\/h1><h2>Overall league table/" $month_dir/league_table.html



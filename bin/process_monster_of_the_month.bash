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

# hierher Winter series or summer series?
winter=0

# hierher update year (all relative to start in oct)
current_year_string="2023" #hierher
next_year_string="2024" #hierher

# Loop over months
if [ $winter == 1 ]; then
    echo "Doing Winter series for Monster of the month"
    year_string=$current_year_string
    month_string="Oct"
    month_list="10 11 12 1 2 3"
else
    echo "Doing Summer series for Monster of the month"
    month_string="May"
    year_string=$next_year_string
    month_list="5 6 7 8 9"
fi

for month_index in `echo $month_list`; do
    cd $home_dir
    if [ $month_index -eq 10 ]; then	
	month_string="Oct"
	year_string=$current_year_string
    elif [ $month_index -eq 11 ]; then	
	month_string="Nov"
	year_string=$current_year_string
    elif [ $month_index -eq 12 ]; then	
	month_string="Dec"
	year_string=$current_year_string
    elif [ $month_index -eq 1 ]; then	
	month_string="Jan"
	year_string=$next_year_string
    elif [ $month_index -eq 2 ]; then	
	month_string="Feb"
	year_string=$next_year_string
    elif [ $month_index -eq 3 ]; then	
	month_string="Mar"
	year_string=$next_year_string
    elif [ $month_index -eq 4 ]; then	
	month_string="Apr"
	year_string=$next_year_string
    elif [ $month_index -eq 5 ]; then	
	month_string="May"
	year_string=$next_year_string
    elif [ $month_index -eq 6 ]; then	
	month_string="Jun"
	year_string=$next_year_string
    elif [ $month_index -eq 7 ]; then	
	month_string="Jul"
	year_string=$next_year_string
    elif [ $month_index -eq 8 ]; then	
	month_string="Aug"
	year_string=$next_year_string
    elif [ $month_index -eq 9 ]; then	
	month_string="Sep"
	year_string=$next_year_string
    else
	echo "Error; wrong month index: "$month_index
	exit 1
    fi	
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
    if [ -e $month_dir/league_table.html ]; then
	sed -i "s/<h2>Overall league table/<h1>(Watt-)Monster of the Month<\/h1><h2>Overall league table/" $month_dir/league_table.html
    fi

    # Add header and footer
    cp $month_dir/league_table.html .tmp_body
    echo "<div style=\"text-align:center;\"><button class=\"select_league_table_buttons\"  onclick=\"back_to_rvy_racing_homepage(1)\">Back to rvy_racing home page</button></div><hr>" > .tmp_body2
    cat html_templates/html_start.txt .tmp_body2 .tmp_body html_templates/html_end.txt > $month_dir/league_table.html
    cp html/script.js $month_dir
    cp html/style.css $month_dir
    rm .tmp_body .tmp_body2
    
done


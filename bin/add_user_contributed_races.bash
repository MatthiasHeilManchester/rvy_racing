#!/bin/bash



# Five command line arguments
if [ $# -ne 5 ]; then
 echo "Five args: race_series newly_created_race_url route_id race_number race_date_string"
 exit 1
fi


# More output for debugging
verbose_debug=0

# Convert input params to sensibly named variables. All data is
# for master race (for validation of newly created one), apart
# from newly_created_race_url.
race_series=$1
newly_created_race_url=$2
route_id=$3
race_number=$4
race_date_string=$5

# Script should be run from one level below home dir (because it's ususally
# called from php script in html directory)
home_dir=`pwd`
if [ ! -e ../master_race_data ]; then
    echo "ERROR: Script ought to be run one level below home directory, so that"
    echo "directory master_race_data is available as ../master_race_data."
    echo "You are in $home_dir"
    exit 1
fi


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


# Check that relevant directories exist
series_dir=../contributed_race_data/$race_series
if [ ! -e $series_dir ]; then
    echo "ERROR: Race series dir for contributed race of series "$race_series" doesn't exist yet: "$series_dir
    exit 1
fi
contributed_race_data_race_dir=../contributed_race_data/$race_series/race`echo $race_number | awk '{printf "%05d\n",$1}'`
if [ ! -e $contributed_race_data_race_dir ]; then
    echo "ERROR: Race dir doesn't exist yet: "$contributed_race_data_race_dir
    exit 1
fi





# This is where we're actually assembling all the data
series_dir_for_overview="../generated_race_data/"$race_series
race_dir=../generated_race_data/$race_series/race`echo $race_number | awk '{printf "%05d\n",$1}'`
if [ ! -e $race_dir ]; then
    echo "ERROR: Race dir doesn't exist yet: "$race_dir
    exit 1
fi

# Go to generated race directory and check things out
cd $race_dir


# Do the lock check in the relevant race directory, 'cos that's where
# we're writing stuff:

# Check if lock File exists, if not create it and set trap on exit
# but first check if we even have write permission here!
rm -f .date.dat
date > .date.dat
if [ ! -e .date.dat ]; then
    echo "ERROR: Don't appear to have write permission in "`pwd`
    echo "Locking is likely to fail..."
fi
rm -f .date.dat

# Keep looping; reset of max_while to zero is treated as success
# and causes and of loop
while_count=0
max_while=5
while [ $while_count -le $max_while ]; do

    #echo "check "$while_count
    lock_file_name=`pwd`"/lock_file_for_contributed_races.lock"
    ls -l lock_file.lock
    if { set -C; 2>/dev/null > $lock_file_name ; }; then
        #echo "trapping newly created lockfile"
        trap "rm -f $lock_file_name" EXIT
        max_while=0
    else        
        #echo "Lock file found in: "
        #echo " "
        #echo "   "$lock_file_name
        #echo " "
        #echo "Attempt "$while_count" . Waiting for 0.1 sec."

        sleep 0.1
    fi
    while_count=$(( $while_count + 1 ))
done


if [ $max_while -gt 0 ]; then    
    echo "ERROR: Kept finding lock file: "
    echo " "
    echo "     "`pwd`/lock_file.lock
    echo " "
    echo "during several attempts."
    echo " "
    echo "Somebody else may be uploading a contributed race (but it's more likely "
    echo "that this is a bug...)"
    echo " "
    echo "Please try again later. If this problem persists, please report it on the"
    echo "discussion board."
    echo " "
    exit
fi

# Need to have a link to contributed race file
if [ ! -e contributed_race.dat ]; then
    echo "ERROR: Need a link to contributed_race.dat"
    exit 1
fi

# Need to have a link to contributed race list items
if [ ! -e contributed_race_list_items.html ]; then
    echo "ERROR: Need a link to contributed_race_list_items.html"
    exit 1
fi

# How many races do we alrady have?
next_contributed_race_number=1
n_existing_contributed_races=`wc -l contributed_race.dat | awk '{print $1}'`
let next_contributed_race_number=`expr $next_contributed_race_number + $n_existing_contributed_races`


# Download race file for check of consitency with offical race
html_file="downloaded_contributed_race_pages/downloaded_contributed_race_file"$next_contributed_race_number".html"
#echo "html file : "$html_file
#echo "race url "$newly_created_race_url
#pwd
wget -O $html_file $newly_created_race_url
if [ ! -e $html_file ]; then
    echo "ERROR: Couldn't download "$html_file" in "`pwd`
    exit 1
fi

# Check if route and date agree
newly_contributed_race_date=`$home_dir/../bin/extract_parameters_from_rouvy_race_page.bash $html_file --date`
newly_contributed_race_time=`$home_dir/../bin/extract_parameters_from_rouvy_race_page.bash $html_file --time`
newly_contributed_route_id=`$home_dir/../bin/extract_parameters_from_rouvy_race_page.bash  $html_file --route_id`

something_wrong=0
if [ "$newly_contributed_race_date" == "" ]; then
    echo "ERROR: Race is (probably) already running; but please report the occurence of this error message [date]"
    something_wrong=1
fi
if [ "$newly_contributed_race_time" == "" ]; then
    echo "ERROR: Race is (probably) already running; but please report the occurence of this error message [time]"
    something_wrong=1
fi
if [ "$newly_contributed_route_id" == "" ]; then
    echo "ERROR: Race is (probably) already running; but please report the occurence of this error message [id]"
    something_wrong=1
fi
if [ $something_wrong -eq 1 ]; then
    rm $html_file
    echo "DIAGNOSTIC: URL of user contributed race                      :  "$newly_created_race_url
    echo "DIAGNOSTIC: Race date of user contributed race (from url file): -"$newly_contributed_race_date"-"
    echo "DIAGNOSTIC: Race time of user contributed race (from url file): -"$newly_contributed_race_time"-"
    echo "DIAGNOSTIC: Route ID of user contributed race  (from url file): -"$newly_contributed_route_id"-"

    exit 1
fi

# an array to look up th month-names
month_names=(not_a_month Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)

# Prettify date
day=`echo $newly_contributed_race_date | awk '{print substr($0,4,2)}'`
month=`echo $newly_contributed_race_date | awk '{print substr($0,1,2)}'`
year=`echo $newly_contributed_race_date | awk '{print substr($0,7)}'`
newly_contributed_race_date_string=`echo $day " " ${month_names[${month}]} " " $year`


# Check date of race
we_have_an_error=0
#echo "race: -"$race_date_string"-"
#echo "cont: -"$newly_contributed_race_date_string"-"
if [ "$race_date_string" != "$newly_contributed_race_date_string"]; then
    echo "ERROR: Newly contributed  race is on a different date ( -"$newly_contributed_race_date_string"- GMT ) from date of official race ( -"$race_date_string"- GMT )"
    we_have_an_error=1
else
    if [ $verbose_debug == 1 ]; then echo "OK: official races 1 and newly contributed race are on same date: " $newly_contributed_race_date_string" and "$race_date_string; fi 
fi

# Check route
if [ "$route_id" != "$newly_contributed_route_id" ]; then
    echo "ERROR: Newly contributed race is on a <a href=\""$newly_created_race_url"\">different route</a> from from that of the <a href=\"https://my.rouvy.com/virtual-routes/detail/"$route_id"\">official race</a>"
    we_have_an_error=1
else
    if [ $verbose_debug == 1 ]; then echo "OK: Newly created race is on the same route as the official race!"; fi 
fi


if [ $we_have_an_error == 1 ]; then
    rm -f $html_file
    echo " "
    echo "Please use your browser's back button (twice) to return to the original form and check your input."
    exit 1
fi

existing_url_list=`cat $home_dir/$contributed_race_data_race_dir/contributed_race.dat`
race_is_new=1
nrace=1 # start with one to include the current one
for existing_url in `echo $existing_url_list`; do
    let nrace=`expr $nnrace + 1`
    if [ $newly_created_race_url == $existing_url ]; then
        if [ $verbose_debug == 1 ]; then
            echo "New race url "$newly_created_race_url" is the same as existing race url "$existing_url
            echo "Deleting downloaded file and not adding this race (again) to contributed races."
        fi
        rm -f $html_file
        race_is_new=0
    fi
done

if [ $race_is_new -eq 1 ]; then
    echo $newly_created_race_url >> $home_dir/$contributed_race_data_race_dir/contributed_race.dat
    echo "<li>  <a href="$newly_created_race_url">Contributed race $nrace: $newly_contributed_race_time (GMT)</a>" >> contributed_race_list_items.html
    echo "Congratulations. Your contributed race was successfully added."
    cd $home_dir/..
    bin/bolshy_stage_races.bash $race_series
    echo " " 
    echo "I've updated the webpages too!"
    echo " "
    echo "      <h2><a href=\"../generated_html/$race_series/rvy_racing.php\"><b>Return to the race pages</b></a></h2>"
    echo " "
    exit 0
else
    echo "ERROR: Race had already been added; not adding it again. <br><br>Please have a look on the <a href=\"../generated_html/$race_series/rvy_racing.php\"><b>race pages</b></a> for the list of currently existing user-contributed races."
    exit 1
fi


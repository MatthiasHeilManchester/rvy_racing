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
echo "HOME DIR : "$home_dir

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


if [ -e downloaded_contributed_race_pages ]; then
    if [ $verbose_debug == 1 ]; then echo `pwd`"/downloaded_contributed_race_pages already exists."; fi
else
    mkdir downloaded_contributed_race_pages
    if [ $verbose_debug == 1 ]; then echo "made "`pwd`"/downloaded_contributed_race_pages directory"; fi
fi

echo "i AM HERE : "`pwd`

next_contributed_race_number=1
n_existing_contributed_races=`wc -l contributed_race.dat | awk '{print $1}'`
let next_contributed_race_number=`expr $next_contributed_race_number + $n_existing_contributed_races`
echo "next contrib race number : "$next_contributed_race_number

# Now download the race html file
html_file="downloaded_contributed_race_pages/downloaded_contributed_race_file"$next_contributed_race_number".html"
echo "doing wget with race_url "$race_url
wget -O $html_file $race_url


# Check if route title and 
race_date=`$home_dir/../bin/extract_parameters_from_rouvy_race_page.bash $html_file --date`
race_time=`$home_dir/../bin/extract_parameters_from_rouvy_race_page.bash $html_file --time`
route_id=`$home_dir/../bin/extract_parameters_from_rouvy_race_page.bash  $html_file --route_id`

echo "Race date of user contributed race (from url file): "$race_date
echo "Race time of user contributed race (from url file): "$race_time
echo "Route ID of user contributed race  (from url file): "$route_id



# hierher re-enable checks

#if [ "$race_date" != "$race_date_from_race1" ]; then
#    echo "WARNING: official races 1 and "$race_number" are on different dates: -"$race_date"- and -"$race_date_from_race1"-"
#else
#    if [ $verbose_debug == 1 ]; then echo "OK: official races 1 and "$race_number" are on same date!"; fi 
#fi
#if [ "$route_id" != "$route_id_from_race1" ]; then
#    echo "WARNING: official races 1 and "$race_number" are on different routes: -"$route_id"- and -"$route_id_from_race1"-"
#else
#    if [ $verbose_debug == 1 ]; then echo "OK: official races 1 and "$race_number" are on same route!"; fi 
#fi


touch contributed_race.dat
existing_url_list=`cat  contributed_race.dat`
race_is_new=1
for existing_url in `echo $existing_url_list`; do
    echo "Existing url: "$existing_url
    if [ $race_url == $existing_url ]; then
        echo "New race url "$race_url" is the same as existing race url "$existing_url
        echo "Deleting downloaded file and not adding this race (again) to contributed races."
        rm -f $html_file
        race_is_new=0
    fi
done

if [ $race_is_new -eq 1 ]; then
    echo $race_url >> contributed_race.dat
    echo "<li>  <a href="$race_url">Contributed race $race_number: $race_time (GMT)</a>" # hierher >> .race.html
fi


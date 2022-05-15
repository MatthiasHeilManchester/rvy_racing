#! /bin/bash


#--------------------------------------------------------
# Script to stage races in a specified series.
#
# Assumptions:
#
# - script is run from home directory, i.e.
#   the directory master_race_data is available
#   as
#
#        ./master_race_data
#
# - single command line argument specifies name
#   of race series, $1. This identifies the
#   series directory as
#
#        ./master_race_data/$1
#
# - Race series contains file with rouvy usernames of
#   all participants in
#
#        ./master_race_data/$1/user_list.txt
#
# - Info about official races is encoded in
#
#        ./master_race_data/$1/race?????/official_race.dat
#
#   which contain the urls of the rouvy race pages, so e.g.
#
#        > cat master_race_data/test_series/race00001/official_race.dat 
#        https://my.rouvy.com/onlinerace/live/87048
#        https://my.rouvy.com/onlinerace/live/87049
#        https://my.rouvy.com/onlinerace/live/87050
#
# Script produces:
#
#  - html file that provides info and links to rouvy race pages
#    for official races in
#
#      ./master_race_data/$1/all_races_in_series.html
#
#  - placeholder html files for race results in
#
#      ./master_race_data/$1/race?????results.html
#
#    This is over-written when
#
#       bin/process_race_outcome.bash
#
#    is executed in the relevant race directory.
#--------------------------------------------------------

# Just one command line argument
if [ $# -ne 1 ]; then
 echo "Please specify the race series"
 exit 1
fi



# Be verbose for debugging?
verbose_debug=0

# Name of race series
race_series=$1

# Script should be run from home directory
home_dir=`pwd`
if [ ! -e master_race_data ]; then
    echo "ERROR: Script ought to be run from home directory, so that"
    echo "directory master_race_data is available as ./master_race_data."
    echo "You are in $home_dir"
    exit 1
fi

# Does race series even exist?
if [ ! -e master_race_data/$race_series ]; then
    echo "ERROR: Race series master_race_data/$race_series doesn't exist!"
    exit 1
fi
echo " "
echo "==========================================================================="
echo " "
echo "Setting up series : "$race_series
rm -f master_race_data/$race_series/all_races_in_series.html


# Do we have users?
if [ ! -e ./master_race_data/$race_series/user_list.txt ]; then
    echo "ERROR: No users for series, i.e. master_race_data/$race_series/user_list.txt doesn't exist!"
    exit 1
fi


# Loop over all races in this series
race_number_in_series=0
dir_list=`ls -d master_race_data/$race_series/race?????`
for dir in `echo $dir_list`; do

    # Bump
    let race_number_in_series=$race_number_in_series+1
    echo " "
    echo "Doing race "$race_number_in_series" in series"

    # Go into race
    cd $dir
    if [ -e downloaded_official_race_pages ]; then
        if [ $verbose_debug == 1 ]; then echo `pwd`"/downloaded_official_race_pages already exists."; fi
    else
        mkdir downloaded_official_race_pages
        if [ $verbose_debug == 1 ]; then echo "made "`pwd`"/downloaded_official_race_pages dir"; fi
    fi
    
    # Read the URLs of the official races
    if [ ! -e official_race.dat ]; then
        echo "ERROR: No races specified via official_race.dat in " `pwd`
        exit 1
    fi
    
    url_list=`cat official_race.dat`
    cd downloaded_official_race_pages
    race_number=1
    race_date_from_race1="dummy"
    race_time_from_race1="dummy"
    route_id_from_race1="dummy"
    route_title="dummy"
    
    # Loop over all races, download race html file from rouvy
    # and check that they're all
    # - on the same day
    # - on the same route
    for url in `echo $url_list`; do
        html_file="downloaded_race_file"$race_number".html"
        if [ -e $html_file ]; then
            if [ $verbose_debug == 1 ]; then echo "Have already downloaded "$html_file; fi
        else
            wget -O $html_file $url
        fi

        # Extract race date and time from downloaded html files
        if [ $race_number -eq 1 ]; then
            
            html_file_name=`ls downloaded_race_file1.html`
            race_date_from_race1=`$home_dir/bin/extract_parameters_from_rouvy_race_page.bash $html_file_name --date`
            race_time=`$home_dir/bin/extract_parameters_from_rouvy_race_page.bash $html_file_name --time`
            route_id_from_race1=`$home_dir/bin/extract_parameters_from_rouvy_race_page.bash $html_file_name --route_id`
            route_title=`$home_dir/bin/extract_parameters_from_rouvy_race_page.bash $html_file_name --route_title`
            
            day=`echo $race_date_from_race1 | awk '{print substr($0,4,2)}'`
            month=`echo $race_date_from_race1 | awk '{print substr($0,1,2)}'`
            year=`echo $race_date_from_race1 | awk '{print substr($0,7)}'`

            # an array to look up th month-names
            month_names=(not_a_month Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)

            
            echo "Date : " $day " " ${month_names[${month}]} " " $year
            echo "Route: " $route_title
            echo " "
            
            echo "<h2>Race "$race_number_in_series" : " $day " " ${month_names[${month}]} " " $year "</h2><br>" > .race.html
            echo "<b>Route:</b> <a href=\"https://my.rouvy.com/virtual-routes/detail/"$route_id_from_race1"\">"$route_title"</a>" >> .race.html
            echo "<ul>" >> .race.html
        else
            html_file_name=`ls downloaded_race_file$race_number.html`
            race_date=`$home_dir/bin/extract_parameters_from_rouvy_race_page.bash $html_file_name --date`
            race_time=`$home_dir/bin/extract_parameters_from_rouvy_race_page.bash $html_file_name --time`
            route_id=`$home_dir/bin/extract_parameters_from_rouvy_race_page.bash $html_file_name --route_id`
            
            if [ "$race_date" != "$race_date_from_race1" ]; then
                echo "WARNING: official races 1 and "$race_number" are on different dates: -"$race_date"- and -"$race_date_from_race1"-"
            else
                if [ $verbose_debug == 1 ]; then echo "OK: official races 1 and "$race_number" are on same date!"; fi 
            fi
            if [ "$route_id" != "$route_id_from_race1" ]; then
                echo "WARNING: official races 1 and "$race_number" are on different routes: -"$route_id"- and -"$route_id_from_race1"-"
            else
                if [ $verbose_debug == 1 ]; then echo "OK: official races 1 and "$race_number" are on same route!"; fi 
            fi
        fi

        echo "<li>  <a href="$url">Official race $race_number: $race_time (GMT)</a>" >> .race.html
        let race_number=$race_number+1
    done
    echo "</ul>" >> .race.html
    
    # Prepare link to rouvy race ranking (dummy page until race is over and has been processed)
    if [ ! -e ../results.html ]; then
        echo "Race hasn't been raced or processed yet!" > ../results.html
    fi
    race_results_file=`basename $dir`/results.html
    echo "<a href=\"$race_results_file\">Race results</a>" >> .race.html
    
    # Add to race info for overall series (reverse order)
    touch $home_dir/master_race_data/$race_series/all_races_in_series.html
    mv $home_dir/master_race_data/$race_series/all_races_in_series.html .tmp
    cat .race.html .tmp >> $home_dir/master_race_data/$race_series/all_races_in_series.html
    rm -f .tmp
    rm .race.html


    # Get read for the next one
    cd $home_dir
    
done


# Tell us what you've done
cd $home_dir
echo "Races staged. Here are the files that need to be installed:"
echo " " 
ls -l master_race_data/$race_series/all_races_in_series.html master_race_data/$race_series/*/results.html
echo " "
echo "Note that the results.html files are placeholders. They will be overwritten"
echo "when individual races are  processed by running"
echo " "
echo "     bin/process_race_outcome.bash"
echo " "
echo "in the relevant race directory."
echo " "
echo "======================================================================"
echo " "

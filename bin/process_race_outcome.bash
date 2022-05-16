#! /bin/bash

# Be verbose for debugging?
verbose_debug=1


# Where's the bin directory? (That's where the awk script lives)
#echo "The script you are running has basename `basename "$0"`, dirname `dirname "$0"`"
bin_dir=`dirname "$0"`


# hierher also deal with contributed races
if [ ! -e official_race.dat ]; then
    echo " "
    echo "ERROR: Script should be run in race directory "
    echo "(e.g. in master_race_data/test_series/race00001) where"
    echo "info about constituent races is provided in official_race.dat"
    echo " "
    exit
fi

# Provide storage for results
if [ -e downloaded_official_race_results ]; then
    if [ $verbose_debug == 1 ]; then echo `pwd`"/downloaded_official_race_results already exists."; fi
else
    mkdir downloaded_official_race_results
    if [ $verbose_debug == 1 ]; then echo "made "`pwd`"/downloaded_official_race_results dir"; fi
fi

# Read the URLs of the official races
url_list=`cat official_race.dat`
cd downloaded_official_race_results

# Initialise race reslts
race_result_list=""


race_date_from_race1="dummy"
route_id_from_race1="dummy"
route_title="dummy"

# Loop over all races, download race results html file from rouvy
# and check that they're all
# - on the same day
# - on the same route
race_number=0
for url in `echo $url_list`; do
    let race_number=$race_number+1
    html_file="downloaded_race_results_file"$race_number".html"
    if [ -e $html_file ]; then
        if [ $verbose_debug == 1 ]; then echo "INFO: Have already downloaded "$html_file; fi
    else
        wget -O $html_file $url
    fi
    
    if [ $race_number -eq 1 ]; then
        
        race_date_from_race1=`../$bin_dir/extract_parameters_from_rouvy_race_page.bash $html_file_name --date`
        route_id_from_race1=`../$bin_dir/extract_parameters_from_rouvy_race_page.bash $html_file_name --route_id`
        route_title=`../$bin_dir/extract_parameters_from_rouvy_race_page.bash $html_file_name --route_title`

    else

        race_date=`../$bin_dir/extract_parameters_from_rouvy_race_page.bash $html_file_name --date`
        route_id=`../$bin_dir/extract_parameters_from_rouvy_race_page.bash $html_file_name --route_id`
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
    
    # Do we have users?
    if [ ! -e ../../user_list.txt ]; then
        echo "ERROR: Don't have user data in " `pwd`"../../user_list.txt"
        exit 1
    fi
    user_list=`cat ../../user_list.txt`
    
    rm -f .tmp_result_file
    for user in `echo $user_list`; do
        awk -f ../$bin_dir/extract_finish_time_for_user_from_rouvy_race_results.awk -v user=$user $html_file  >> .tmp_result_file
        #echo " "
        #echo "tmp file"
        #cat .tmp_result_file
        #echo "end tmp file"
        #echo " "
    done

    
    # Results for this race
    result_file="results_race"$race_number".dat"
    race_result_list=$race_result_list" "$result_file

    # Sort by name of user
    sort .tmp_result_file > $result_file
    rm -f .tmp_result_file
    
# End of loop over races
done
       


# Now collate all individual races
#---------------------------------
paste_command="paste "
for race_result in `echo $race_result_list`; do
    paste_command=$paste_command" "$race_result
done


# hierher add race data
# hierher add results from previous races
html_file="../results.html"
cat ../$bin_dir/../html_templates/html_start.txt > $html_file
`echo $paste_command`| awk -f ../$bin_dir/create_rank_table_for_race.awk > .tmp_file
echo "<h3>Ranked list</h3>" >>  $html_file
echo "<table>" >>  $html_file
sort -k 5 -o .sorted_tmp_file .tmp_file
awk 'BEGIN{count=1}{printf(" %s %i %s",$1,count,"</td><td>"); for (i=2;i<=NF;i++){printf(" %s ",$i)}; print " ";count++}' .sorted_tmp_file >>  $html_file
#cat .sorted_tmp_file >>  $html_file
echo "</table>" >>  $html_file
cat ../$bin_dir/../html_templates/html_end.txt >> $html_file


#! /bin/bash


#---------------------------------------------------------------
# Process race outcome for a single specific race (comprising
# all the official and contributed actual races).
# This is where the real magic happens (and will break when
# rouvy move/rewrite their webpages).
#---------------------------------------------------------------

# Be verbose for debugging?
verbose_debug=0


# Where's the bin directory? (That's where the awk script lives)
#echo "The script you are running has basename `basename "$0"`, dirname `dirname "$0"`"
bin_dir=`dirname "$0"`

# This should be run two levels below the generated_race_data directory, i.e. in the actual race directory
my_dir=`pwd`
cd ../..
dir_name=`basename \`pwd\``
cd $my_dir
if [ "$dir_name" != "generated_race_data" ]; then
    echo " "
    echo -e "\033[0;31mERROR:\033[0m Script should be run in generated race directory "
    echo "(e.g. in generated_race_data/fake_commute/race00001"
    echo " "
    exit
fi

if [ ! -e official_race.dat ]; then
    echo " "
    echo -e "\033[0;31mERROR:\033[0m Official races do not seem to have been staged!"
    echo "There is no (symlink) to official_race.dat in"`pwd`
    exit
fi
if [ ! -e contributed_race.dat ]; then
    echo " "
    echo -e "\033[0;31mERROR:\033[0m Official races do not seem to have been staged!"
    echo "There is no (symlink) to contributed_race.dat in"`pwd`
    exit
fi



# Get userlist from master directory
my_dir=`pwd`
cd ..
thingy=`readlink -f .` 
the_path=`basename $thingy`
#the_path=`realpath --relative-to=../ .`
the_file=../../master_race_data/$the_path/user_list.txt

# Do we have users?
if [ ! -e $the_file ]; then
    echo -e "\033[0;31mERROR:\033[0m Don't have user data in $my_dir"
    echo "I'm in "`pwd`
    exit 1
fi
user_list=`cat $the_file`
cd $my_dir

    
# Get race number from directory name
command=`printf '%s\n' "${PWD##*/}" | awk '{print "echo $((10#"substr($1,5,5)"))"}' `
race_number_in_series=`eval $command`



# Provide storage for results
if [ -e downloaded_race_results ]; then
    if [ $verbose_debug == 1 ]; then echo `pwd`"/downloaded_race_results already exists."; fi
else
    mkdir downloaded_race_results
    if [ $verbose_debug == 1 ]; then echo "made "`pwd`"/downloaded_race_results dir"; fi
fi

# Read the URLs of the official races
url_list=`awk '{print $0" "}' official_race.dat; awk '{print $0}' contributed_race.dat`
cd downloaded_race_results

# Initialise race reslts
race_result_list=""


race_date_from_race1="dummy"
route_id_from_race1="dummy"
route_title="dummy"

# an array to look up th month-names
month_names=(not_a_month Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
    
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
        #echo "wgetting $url"
        wget -q -O $html_file  $url
    fi
    
    # Check if the race has actually been processed
    number_of_official_results_strings=`grep -c 'OFFICIAL RESULTS' $html_file`
    if [ $number_of_official_results_strings == 0 ]; then
        echo "Race doesn't seem to have been run yet, according to rouvy"
        echo "race page "
        echo " "
        echo "    "$url
        echo " "
        echo "which contains the string 'OFFICIAL RESULTS' " $number_of_official_results_strings " times."
        echo " "
        rm -f $html_file
        echo "Aborting after deleting the downloaded file!"
        echo " "
        exit 1
    else
        if [ $verbose_debug == 1 ]; then
            echo "Downloaded webpage contains the string 'OFFICIAL RESULTS' " $number_of_official_results_strings " times."
            echo "This suggests that the race was completed on rouvy. Yay!"
        fi
    fi
    
    if [ $race_number -eq 1 ]; then
        
        race_date_from_race1=`../$bin_dir/extract_parameters_from_rouvy_race_page.bash $html_file --date`
        route_id_from_race1=`../$bin_dir/extract_parameters_from_rouvy_race_page.bash $html_file --route_id`
        route_title=`../$bin_dir/extract_parameters_from_rouvy_race_page.bash $html_file --route_title`
        day=`echo $race_date_from_race1 | awk '{print substr($0,4,2)}'`
        month=`echo $race_date_from_race1 | awk '{print substr($0,1,2)}'`
        year=`echo $race_date_from_race1 | awk '{print substr($0,7)}'`

    else

        race_date=`../$bin_dir/extract_parameters_from_rouvy_race_page.bash $html_file --date`
        route_id=`../$bin_dir/extract_parameters_from_rouvy_race_page.bash $html_file --route_id`
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

    rm -f .tmp_result_file

    rm -f .log_file_for_most_likely_offset.dat
    offset=`../$bin_dir/explore_most_likely_offset_for_finish_time.bash $html_file .log_file_for_most_likely_offset.dat`
    if [ $offset == 0 ]; then
        echo "Inconsistency in determination of offset; see "`pwd`"/.log_file_for_most_likely_offset.dat for details."
        exit 1
    fi
    for user in `echo $user_list`; do
        awk -f ../$bin_dir/extract_finish_time_for_user_from_rouvy_race_results.awk -v user=$user -v required_offset=$offset $html_file  >> .tmp_result_file
        # DEBUG
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


html_file="../results.html"
cat ../$bin_dir/../html_templates/html_start.txt > $html_file

echo "<div style=\"text-align:center;\"><button class=\"select_league_table_buttons\"  onclick=\"back_to_rvy_racing_homepage(2)\">Back to rvy_racing home page</button></div><hr>" >> $html_file


# https://coderwall.com/p/cobcna/bash-removing-leading-zeroes-from-a-variable
day=$(echo $day | sed 's/^0*//')
month=$(echo $month | sed 's/^0*//')
year=$(echo $year | sed 's/^0*//')

echo "<h2>Race "$race_number_in_series" : " $day " " ${month_names[${month}]} " " $year "</h2><br>" >> $html_file
echo "<b>Route: </b> <a href=\"https://my.rouvy.com/virtual-routes/detail/"$route_id_from_race1"\">"$route_title"</a>" >> $html_file
echo "<br><br>" >> $html_file

echo "<b>Contributing races:</b>" >> ../results.html
echo "<ul>"  >> ../results.html
cat ../official_race_list_items.html >> ../results.html
cat ../contributed_race_list_items.html >> ../results.html
echo "</ul>"  >> ../results.html

`echo $paste_command`| awk -f ../$bin_dir/create_rank_table_for_race.awk > .tmp_file

#echo "<table border=1>" >>  $html_file
echo "<table style=\"border-spacing:10px; width:60%; background-color:white;\">" >>  $html_file
echo "<tr style=\"background-color:yellow\"> <th>Rank</th> <th>Rouvy username</th> <th>Finish time</th>  <th>Points</th> </tr>" >>  $html_file
sort -k 5 -o .sorted_tmp_file .tmp_file
awk 'BEGIN{count=1}{printf(" %s %i %s",$1,count," </td><td>"); for (i=2;i<=NF;i++){printf(" %s ",$i)}; print " ";count++}' .sorted_tmp_file >  .sorted_tmp_file2 
awk 'BEGIN{count=1;score[1]=40; score[2]=30; score[3]=25; for (i=4;i<=23;i++){score[i]=24-i}}{printf $1" "$2" "$3" "$4" "$5" "$6" "$7; start_of_time=substr($7,1,2); 
if (start_of_time=="DN"){
printf(" </td> <td> 0 </td> ")
}else{
printf(" </td> <td> %i </td> ",score[count])
}; print " </tr>"; count++}' .sorted_tmp_file2 >>  $html_file

echo "</table>" >>  $html_file
echo "<br>"  >>  $html_file
echo "Race processed: "`date --utc `  >>  $html_file
echo "<br>DNR = 'Did Not Register'.<br>Other = DNS/DNF/DSQ/ERROR.<br>Please report any errors via the <a href="https://www.matthias-heil.co.uk/phpbb/">discussion board</a>"  >>  $html_file

echo "<br>" >>  $html_file
echo "<hr>" >>  $html_file
echo " " >>  $html_file

cat ../$bin_dir/../html_templates/html_end.txt >> $html_file

echo " "
echo "Done; now run "
echo " "
echo "     bin/stage_official_races.bash"
echo " "
echo "again to update the results."
echo " " 

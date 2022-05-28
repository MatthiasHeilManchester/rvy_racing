#! /bin/bash

# Be verbose for debugging?
verbose_debug=1


# Where's the bin directory? (That's where the awk script lives)
#echo "The script you are running has basename `basename "$0"`, dirname `dirname "$0"`"
bin_dir=`dirname "$0"`

# This should be run two levels below the generated_race_data directory
my_dir=`pwd`
cd ../..
dir_name=`basename \`pwd\``
cd $my_dir
echo $dir_name
if [ "$dir_name" != "generated_race_data" ]; then
    echo " "
    echo "ERROR: Script should be run in generated race directory "
    echo "(e.g. in generated_race_data/fake_commute/race00001"
    echo " "
    exit
fi

# hierher cat with contributed_race.dat and use the combined one here
if [ ! -e official_race.dat ]; then
    echo " "
    echo "ERROR: Official races do not seem to have been staged!"
    echo "There is no (symlink) to official_race.dat in"`pwd`
    exit
fi



# Get userlist from master directory
my_dir=`pwd`
cd ..
the_path=`realpath --relative-to=../ .`
the_file=../../master_race_data/$the_path/user_list.txt

# Do we have users?
if [ ! -e $the_file ]; then
    echo "ERROR: Don't have user data in $my_dir"
    echo "I'm in "`pwd`
    exit 1
fi
user_list=`cat $the_file`
cd $my_dir

    
# Get race number from directory name
let race_number_in_series=`printf '%s\n' "${PWD##*/}" | awk '{print substr($1,5,5)}'`+0

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
        wget -O $html_file  $url
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
        echo "Downloaded webpage contains the string 'OFFICIAL RESULTS' " $number_of_official_results_strings " times."
        echo "This suggests that the race was completed on rouvy. Yay!"
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


html_file="../results.html"
cat ../$bin_dir/../html_templates/html_start.txt > $html_file



echo "<h2>Race "$race_number_in_series" : " $day " " ${month_names[${month}]} " " $year "</h2><br>" >> $html_file
echo "<b>Route: </b> <a href=\"https://my.rouvy.com/virtual-routes/detail/"$route_id_from_race1"\">"$route_title"</a>" >> $html_file
echo "<br><br>" >> $html_file

`echo $paste_command`| awk -f ../$bin_dir/create_rank_table_for_race.awk > .tmp_file
echo "<table border=1>" >>  $html_file
echo "<tr style=\"background-color:yellow\"> <td>Rank</td> <td>Rouvy username</td> <td>Finish time</td>  <td>Points</td> </tr>" >>  $html_file
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
echo "Race processed: "`date`  >>  $html_file
echo "<br>" >>  $html_file
echo "<hr>" >>  $html_file
echo " " >>  $html_file

cat ../$bin_dir/../html_templates/html_end.txt >> $html_file

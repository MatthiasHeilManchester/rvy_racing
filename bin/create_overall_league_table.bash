#! /bin/bash

#-------------------------------------------------------------
# Create overall league table from processed individual races
#-------------------------------------------------------------

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
echo " "
echo "==========================================================================="
echo " "
echo "Setting up/updating league table for series : "$race_series
html_file=generated_race_data/$race_series/league_table.html
cat $home_dir/html_templates/html_start.txt > $html_file


# Do we have users?
if [ ! -e ./master_race_data/$race_series/user_list.txt ]; then
    echo -e "\033[0;31mERROR:\033[0m No users for series, i.e. master_race_data/$race_series/user_list.txt doesn't exist!"
    exit 1
fi

# Create an associative array
declare -A total_points

# Loop over all races in this series
race_number_in_series=0
dir_list=`ls -d generated_race_data/$race_series/race?????`
rev_dir_list=`echo $dir_list | awk '{ for (i=NF; i>1; i--) printf("%s ",$i); print $1; }'`
for dir in `echo $dir_list`; do

    # Bump
    let race_number_in_series=$race_number_in_series+1
    echo " "
    echo "Doing race "$race_number_in_series" in series"

    # Go into race
    cd $dir
    if [ ! -e results.html ]; then
        echo "WARNING: results.html in"`pwd`" doesn't exist; ignoring."
    else
        # Prefix 10# declares numbers to be decimals in base 10
        # https://stackoverflow.com/questions/21049822/value-too-great-for-base-error-token-is-09
        command=`awk '{if ($1=="<tr><td>"){print "let total_points["$4"]=$((10#$((${total_points["$4"]}))))+$((10#"$10")); "}}' results.html`
	#echo "hierher "$command
	#exit
        eval $command
        #echo "bla hierher: " ${total_points[MatthiasHeil]}
        #echo "bla hierher: " ${total_points[whitesheep]}
        #echo "bla hierher: " ${total_points[stfmgr_65]}
        awk 'BEGIN{dont_print=1}{if (dont_print!=1){print $0}; if ($1=="<body>"){dont_print=0}; if ($1=="</body>"){dont_print=1};}' results.html > .tmp_html_body_for_race.html
    fi
    cd $home_dir
done




echo "<h2>Overall league table for race series <em>"$race_series"</em></h2>" >>  $html_file
echo "<h3>Note: The series hasn't started yet -- this is all dummy data from pre-season testing</h3>" >>  $html_file
echo "<table border=1>" >>  $html_file
echo "<tr style=\"background-color:yellow\"> <td>Rank</td> <td>Rouvy username</td> <td>Points</td> </tr>" >>  $html_file
rm -f .tmp_league_table.dat
rm -f .tmp_league_table2.dat
for i in "${!total_points[@]}"; do
    echo "<tr>  <td> "$i" </td> <td> " ${total_points[$i]} " </td> </tr>" >> .tmp_league_table.dat
done
#echo ".tmp:"
#cat  .tmp_league_table.dat
#echo "end .tmp"
sort -k 6 -n -r .tmp_league_table.dat > .tmp_league_table2.dat

#echo ".tmp2:"
#cat  .tmp_league_table2.dat
awk 'BEGIN{count=1;}{if ($1 == "<tr>"){printf("<tr> <td> %s </td>", count); for (i=2;i<=NF;i++){printf("%s",$i)}; count++}; print " "}' .tmp_league_table2.dat >> $html_file

echo "<table>" >>  $html_file
echo "<br>" >>  $html_file
echo "League table processed: "`date --utc`  >>  $html_file
echo "<br>" >>  $html_file
echo "<hr>" >>  $html_file
echo " " >>  $html_file

echo "<h2>Individual race results:</h2>" >> $html_file
for dir in `echo $rev_dir_list`; do
    cat $dir/.tmp_html_body_for_race.html >>  $html_file
done

cat $home_dir/html_templates/html_end.txt >> $html_file




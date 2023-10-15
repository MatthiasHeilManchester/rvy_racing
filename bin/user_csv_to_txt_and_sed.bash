#! /bin/bash

#----------------------------------------------------------------
# Read in csv file from phpBB and create
# - user_list.txt:
#      for normal processing
# - pad_results_with_private_data.bash:
#       to run sed on generated tables and insert private data
#----------------------------------------------------------------

# Specify csv file downloaded from phpbb
if [ $# -ne 1 ]; then
    echo "Please specify name of csv file downloaded from phpBB "
    exit
fi
csv_file=$1
echo "Operating on csv file: "$csv_file


# Check that we're in the right place
if [ ! -e ../../master_race_data ] || [ ! -e $csv_file  ]; then
    echo "You're in the wrong directory. This is supposed to be run in the "
    echo "race series directory, e.g. in "
    echo " "
    echo "      master_race_data/rvy_racing"
    echo " "
    echo "which must contain the file "
    echo " "
    echo "     "$csv_file
    echo " "
    echo "Bailing."
    exit 1;
fi

# Check if the first line contains caption
first_entry_is_user_name=`awk -F',' 'BEGIN{first_line_done=0}
    {if (first_line_done==0){first_line_done=1; gsub("\"","",$1); if ($1=="Username"){print 1}else{print 0}}}' $csv_file `

if [ $first_entry_is_user_name -eq 0 ]; then
    echo "csv file must contain caption/title and the first entry has to be \"Username\n";
    exit
fi

# Check number of entries (note the trailing comma)
ncols=`awk -F',' 'BEGIN{first_line_done=0}
    {if (first_line_done==0){first_line_done=1; print NF}}' $csv_file `

if [ $ncols -ne 9 ]; then
    echo "csv file must contain 8 columns: "
    echo "-- \"Username\""
    echo "-- \"Rouvy username (case sensitive!)\""
    echo "-- \"First name\""
    echo "-- \"Surname\""
    echo "-- \"Strava URL\""
    echo "-- \"Year of birth\""
    echo "-- \"Gender\""
    echo "-- \"Display of user info allowed on non-password protected pages\""
    exit
else
    echo "Number of columns is ok"
fi


# Generated updated user_list.txt file for general processing
# Extracts ony rouvy username (from field 2); skip caption line
awk -F',' 'BEGIN{first_line_done=0}
    {if (first_line_done==0){first_line_done=1}else{gsub("\"","",$2); print $2}}' $csv_file > user_list.txt


# Rouvy username (#2), First name (#3), Surname (#4), YOB (#6), Gender (#7), public allowed (#8)
echo "#!/bin/bash" > pad_results_with_private_data.bash
echo '#-------------------------------------------------------'>> pad_results_with_private_data.bash
echo '# This is an automatically generated script, created by'>> pad_results_with_private_data.bash
echo '#           user_scv_to_txt_and_sed.bash'>> pad_results_with_private_data.bash
echo '# DON-T EDIT IT!'>> pad_results_with_private_data.bash
echo '#-------------------------------------------------------'>> pad_results_with_private_data.bash
echo 'if [ $# -ne 1 ]; then' >> pad_results_with_private_data.bash
echo '    echo "Please specify name of results file which contains table to be expanded with private data "' >> pad_results_with_private_data.bash
echo '    exit' >> pad_results_with_private_data.bash
echo 'fi' >> pad_results_with_private_data.bash
echo 'results_file_with_table=$1' >> pad_results_with_private_data.bash
awk -F',' -v results_file='$results_file_with_table' 'BEGIN{first_line_done=0}
    {if (first_line_done==0){first_line_done=1}else{gsub("\"","",$2);gsub("\"","",$3);gsub("\"","",$4);gsub("\"","",$6);gsub("\"","",$7);;gsub("\"","",$8); if ($8=="Allow"){print "sed -i \x27s/<td> "$2" <\\/td>/<td> ",$2," <\\/td><td> ",$3," <\\/td><td> ",$4," <\\/td><td> ",$6," <\\/td><td> ",$7," <\\/td>/g\x27 ",results_file}else{print "sed -i \x27s/<td> "$2" <\\/td>/<td> ",$2," <\\/td><td> ","<small>--<\\/small>"," <\\/td><td> ","<small>--<\\/small>"," <\\/td><td> ","<small>--<\\/small>"," <\\/td><td> ","<small>--<\\/small>"," <\\/td>/g\x27 ", results_file}}}' $csv_file >> pad_results_with_private_data.bash

# Crazy hacky duplication from create_overall_league_table.bash; when updating make sure you escape all the "/" in the closing tags (or rewrite in a more easy to maintain way!)
echo "sed -i 's/<th>Rouvy username<\/th>/<th>Rouvy username<\/th><th>First name<\/th><th>Surname<\/th><th>YOB<\/th><th>Gender<\/th>/g' "'$results_file_with_table' >> pad_results_with_private_data.bash

# Make it executable
chmod a+x pad_results_with_private_data.bash

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


# Generated updated user_list.txt file for general processing
# Extracts ony rouvy username (from field 2)
awk -F',' 'BEGIN{first_line_done=0}
    {if (first_line_done==0){first_line_done=1}else{gsub("\"","",$2); print $2}}' $csv_file > user_list.txt


# Rouvy username (#2), First name (#3), Surname (#4), YOB (#6), Gender (#7), public allowed (#8)
echo "#!/bin/bash" > pad_results_with_private_data.bash
echo 'if [ $# -ne 1 ]; then' >> pad_results_with_private_data.bash
echo '    echo "Please specify name of results file which contains table to be expanded with private data "' >> pad_results_with_private_data.bash
echo '    exit' >> pad_results_with_private_data.bash
echo 'fi' >> pad_results_with_private_data.bash
echo 'results_file_with_table=$1' >> pad_results_with_private_data.bash
awk -F',' -v results_file='$results_file_with_table' 'BEGIN{first_line_done=0}
    {if (first_line_done==0){first_line_done=1}else{gsub("\"","",$2);gsub("\"","",$3);gsub("\"","",$4);gsub("\"","",$6);gsub("\"","",$7);;gsub("\"","",$8); if ($8=="Allow"){print "sed -i \x27s/<td> "$2" <\\/td>/<td> ",$2," <\\/td><td> ",$3," <\\/td><td> ",$4," <\\/td><td> ",$6," <\\/td><td> ",$7," <\\/td>/g\x27 ",results_file}else{print "sed -i \x27s/<td> "$2" <\\/td>/<td> ",$2," <\\/td><td> ","<small>--<\\/small>"," <\\/td><td> ","<small>--<\\/small>"," <\\/td><td> ","<small>--<\\/small>"," <\\/td><td> ","<small>--<\\/small>"," <\\/td>/g\x27 ", results_file}}}' $csv_file >> pad_results_with_private_data.bash
echo "sed -i 's/<td>Rouvy username<\/td>/<td>Rouvy username<\/td><td>First name<\/td><td>Surname<\/td><td>YOB<\/td><td>Gender<\/td>/g' "'$results_file_with_table' >> pad_results_with_private_data.bash

# Make it executable
chmod a+x pad_results_with_private_data.bash

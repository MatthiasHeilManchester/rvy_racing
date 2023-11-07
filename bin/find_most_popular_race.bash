#! /bin/bash

#-------------------------------------------------------------
# Script called from php to find number of registered riders
# for race series: 2 args: race_series and race_number.
# Script should only be called from php script
#-------------------------------------------------------------

# Two command line arguments
if [ $# -ne 2 ]; then
 echo "Two args: race_series race_number"
 exit 1
fi

# Copy across into meaningful variables
race_series=$1
race_number=$2

# Pad to get the relevant directory and extract contributed races
padded_race_number=`printf "%05d\n" $race_number`
race_data_dir="../generated_race_data/"$race_series"/race"$padded_race_number
race_list=`cat $race_data_dir/official_race_list_items.html $race_data_dir/contributed_race_list_items.html`

# Workspace
tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)

# Put into bash array
array_assignment_command=`echo $race_list | sed 's/<li>/\"/g'| sed 's/<\/a>/<\/a>\"/g' | awk '{print "race_item_array=("$0")"}'`
echo $array_assignment_command > $tmp_dir/.tmp1.command
chmod a+x $tmp_dir/.tmp1.command
source $tmp_dir/.tmp1.command
rm $tmp_dir/.tmp1.command


# Get ready to count
url_list=`echo $race_list | awk '{for (i=1;i<=NF;i++){if (substr($i,1,5)=="href="){end=index($i,">"); print substr($i,6,end-6)}}}'`
array_assignment_string="count_array=("
count=1
for url in `echo $url_list`; do
    file="$tmp_dir/race_file"$count".html"
    wget --output-document=$file $url
    let count=$count+1

    
    # If page is empty the race has probably been deleted
    file_length=`wc -m $file | awk '{print $1}'`
    if [ $file_length -eq 0 ]; then
	array_assignment_string=$array_assignment_string" \"[race not accessible on rouvy]\""
    else	
	# If page doesn't have the word STARTLIST the race is over
	n_start_list=`grep -c STARTLIST $file`
	if [ $n_start_list -eq 1 ]; then
	    # If the page has the string "EVENT TIME" the race is running
	    n_event_time=`grep -c "EVENT TIME" $file`
	    if [ $n_event_time -eq 1 ]; then
		array_assignment_string=$array_assignment_string" \"[already running]\""
	    else
		n_registered=`grep -c registered $file`
		array_assignment_string=$array_assignment_string" \"$n_registered\""
	    fi
	else
	    array_assignment_string=$array_assignment_string" \"[race already over]\""
	fi
    fi
    echo " "
done


array_assignment_string=$array_assignment_string")"
echo $array_assignment_string > $tmp_dir/.tmp.command
chmod a+x $tmp_dir/.tmp.command
source $tmp_dir/.tmp.command
rm $tmp_dir/.tmp.command
count=0
echo "<table class=\"head_to_head_table\">"
echo "<tr style=\"background-color:yellow\"> <td> Race </td> <td> Number of currently registered riders </td> </tr>"
for race_item in "${race_item_array[@]}"; do
    echo "<tr> <td> "$race_item" </td> <td class=\"center_text\"> "${count_array[$count]}" </td> </tr>"
    let count=$count+1
done
echo "</table>"

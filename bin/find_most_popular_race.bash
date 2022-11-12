#! /bin/bash




race_series=$1
race_number=$2

padded_race_number=`printf "%05d\n" $race_number`
race_data_dir="../generated_race_data/"$race_series"/race"$padded_race_number

race_list=`cat $race_data_dir/official_race_list_items.html $race_data_dir/contributed_race_list_items.html`




array_assignment_command=`echo $race_list | sed 's/<li>/\"/g'| sed 's/<\/a>/<\/a>\"/g' | awk '{print "race_item_array=("$0")"}'`
echo "STROMG " $array_assignment_command
pwd
echo $array_assignment_command > /tmp/.tmp1.command
cat /tmp/.tmp1.command
chmod a+x /tmp/.tmp1.command
source /tmp/.tmp1.command
#rm /tmp/.tmp1.command
for race_item in "${race_item_array[@]}"; do
  echo "race_item: $race_item"
done

echo "num items " ${#race_item_array[@]}

url_list=`echo $race_list | awk '{for (i=1;i<=NF;i++){if (substr($i,1,5)=="href="){end=index($i,">"); print substr($i,6,end-6)}}}'`

array_assignment_string="count_array=("
count=1
for url in `echo $url_list`; do
    # hierher change /tmp and clean up 
    file="/tmp/race_file"$count".html"
    #echo $file
    # hierher
    wget --output-document=$file $url
    let count=$count+1
    n_start_list=`grep -c STARTLIST $file`
    if [ $n_start_list -eq 1 ]; then
	n_event_time=`grep -c "EVENT TIME" $file`
	if [ $n_event_time -eq 1 ]; then
	    echo "Have event time: race seems to be running"
	    echo "Number of registered riders: -"
	    array_assignment_string=$array_assignment_string" \"-\""
	else
	    echo "Have start list but not event time. Good!"
	    n_registered=`grep -c registered $file`
	    echo "Number of registered riders: "$n_registered
	    array_assignment_string=$array_assignment_string" \"$n_registered\""
	fi
    else
	echo "Race seems to have finished already..."
	echo "Number of registered riders: -"
	array_assignment_string=$array_assignment_string" \"-\""
    fi
done
array_assignment_string=$array_assignment_string")"
echo "STRING: "$array_assignment_string
echo $array_assignment_string > /tmp/.tmp.command
chmod a+x /tmp/.tmp.command
source /tmp/.tmp.command
cat /tmp/.tmp.command
rm /tmp/.tmp.command
count=1
echo "<table>"
echo "<tr> <td> Race </td> <td> Number of registered riders </td> </tr>"

for race_item in "${race_item_array[@]}"; do
  echo "<tr> <td> "$race_item" </td> <td> "${count_array[$count]}" </td> </tr>"
done
echo "</table>"

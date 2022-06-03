#! /bin/bash


#-------------------------------------------------------------------------------
# Race results contain usernames twice, e.g.
#
# 	<a class="username" href="/Procat">Procat</a>
# 	<a class="username" href="/Procat">Procat</a><br>
#
# and up to two times for each user. The first one is the finish time;
# the second one (if provided) is the gap to the winner (it's empty for the
# winner. No times (i.e. time is empty) for dns/dnf/dsq
# so for the winner we have
#
#  	<span>0:28:41.9</span>
#
# for all finishers we have
#
# 	<span>0:32:44.3</span>
# 	<span>0:04:02.4</span>
#
# awk computes various offsets and then computes the offset between the first
# mention of the username and the first subequent time.
#-------------------------------------------------------------------------------

# Just one command line argument
if [ $# -ne 2 ]; then
    echo "Please specify:"
    echo "- the name of the downloaded race results file"
    echo "- the name of the (temporary) log file in which errors get recorded"
    exit 1
fi


html_file=$1
log_file=$2


#==================================================================================
# Heuristic 1: Look for offsets between start of new user record (identified by avatar)
# and mention of username and time-like strings (surrounded by <span></span> which
# represented finish time and time gap.
#==================================================================================
offset_from_heuristic1=`awk -v log_file=$log_file 'BEGIN{
  offset=0;
  found_start_of_new_user=0;
  min_time_offset=10000000;
  min_username_offset=10000000;
 }
{
  if ($0 ~ /avatar22/) 
   {
    found_start_of_new_user=1 
    offset=0
   }
  else 
   {
    if (found_start_of_new_user==1)
      {
       offset++
      }
   }
  #------------------------- 
  # Looking for username  
  #-------------------------
  if ($0 ~ /<a class=\"username\" href=/) 
   {
    print offset " " $0 > log_file
    if (offset<min_username_offset) min_username_offset=offset;
   }
  #-------------------------
  # Looking for patterns like 
  # <span>0:31:55.9</span>
  # <span>0:03:13.10</span>
  # <span>10:03:13.10</span>
  #-------------------------
  if ($0 ~ /<span>[0-9]*:[0-9]+:[0-9]+\.[0-9]*<\/span>/) 
   {
    print offset " " $0 > log_file
    if (offset<min_time_offset) min_time_offset=offset
   }
}
END{
 print " " > log_file
 print "Min offset for username and finish times, respectively : "min_username_offset " " min_time_offset > log_file
 print " " > log_file
 print "So offset for" > log_file
 print " " > log_file
 print "     bin/extract_finish_time_for_user_from_rouvy_race_results.awk" > log_file
 print " "  > log_file
 print "should be: "(min_time_offset-min_username_offset) > log_file
 print " "  > log_file
 print (min_time_offset-min_username_offset) }' $html_file`



#==================================================================================
# Heuristic 2: Offset of 19 tends to occur in official rouvy races in which age is
# characterised by "YOB"; otherwise appears to be 16.
#==================================================================================
count_yob=`grep -c "YOB" $html_file`
if [ $count_yob == 1 ]; then
    if [ $offset_from_heuristic1 != 19 ]; then
        echo "Heuristics for determination of offset are not in agreement" >> $log_file
        echo "Heuristic 1 yields offset of "$offset_from_heuristic1 >> $log_file
        echo "but presence of string \"YOB\" suggests that it should be 19." >> $log_file
        echo 0
        exit 1
    fi
else
    if [ $offset_from_heuristic1 != 16 ]; then
        echo "Heuristics for determination of offset are not in agreement" >> $log_file
        echo "Heuristic 1 yields offset of "$offset_from_heuristic1 >> $log_file
        echo "but absence of string \"YOB\" suggests that it should be 16." >> $log_file
        echo 0
        exit 1
    fi
fi
echo $offset_from_heuristic1



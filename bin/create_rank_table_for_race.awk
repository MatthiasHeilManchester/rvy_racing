# Awk script acts on pasted results from multiple races. 
# If there were N races, each line in the input file contains
#
#   username : dns/dnf/time
#
# repeated n times, so there are 3N fields in each line. 
#
BEGIN{error=0}
{
 # Start new table row for new user
 printf "<tr>";
 # First mention of name is in column 1
 ref_name=$1;
 # Loop over the other columns in increments of 3 and check if the names
 # match 
 for (i=2;i<=NF/3;i++)
  {
   col=3*(i-1)+1;
   if (ref_name!=$col){error=1}
  };
 if (error==1)
  {
   print "ERROR NAMES DONT MATCH FOR USER " refname
  }
 # Data is for the same user
 else
  {
   # Output username as first data item in html table row
   printf("<td> %s </td>\t",ref_name);
   # Check dns: If user has N dns they didn't start in any of the races
   dns_count=0;
   for (i=1;i<=NF/3;i++)
    {
     col=3*(i-1)+3;
     if ($col=="dns")
      {
       dns_count++
      }
    }
   # DNS? If so, that's it.
   if (dns_count==NF/3)
    {
     printf "<td> DNS </td>"
    }
   # Not all DNS: So the user would have started at least one race
   # but may have DNF/DSQed, so check again to see if any of the non DNS races
   # have a non-DNF/DSQ outcome. This will be the time. Keep track of all the times
   # and use the best one
   else
    {
     default_best_time=1.0e36;
     best_time=default_best_time;
     best_raw_time="no time"
     dnf_count=0
     for (i=1;i<=NF/3;i++)
      {
       col=3*(i-1)+3;
       # Do we have a number?
       if (($col!="dnf")&&($col!="dsq")&&($col!="dns")&&($col!="ERROR_IN_EXTRACTING_FINISH_TIME"))
        {
         # Raw time: 13:04:14.7 or 3:04:14.7
         raw_time=$col
         hour_end=match(raw_time,":")
         hours=substr(raw_time,1,hour_end-1);
         minutes=substr(raw_time,hour_end+1,2);
         seconds=substr(raw_time,hour_end+4,2);
         tenth_seconds=substr(raw_time,hour_end+7,1);
         #print hours" "minutes" "seconds" "tenth_seconds
         tenth_sec_time=tenth_seconds+10*(seconds+60*(minutes+60*hours))
         #print "time best_time -- " tenth_sec_time " -- " best_time
         if (tenth_sec_time<best_time)
          {
           best_time=tenth_sec_time
           best_raw_time=raw_time
          }
        }
      }
     # Haven't changed the default best time so there's been no valid time: dnf/dsq
     if (best_time==default_best_time)
      {
       printf "<td> DNF/DSQ/ERROR </td>"
      }
     else
      {
       printf"<td> %s </td>",best_raw_time
      }
    }
  }
 #End of row
 print "</tr>"
}
# Final error check
END{if (error==1)
  {
   print "Error: Names didn't match!"
  }
}

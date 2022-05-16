#---------------------------------------------------------------------------------------
# Awk script to extract race times from rouvy's html file.
#
# Logic: Search through file until the first occurence of username, prefixed by "/".
# Inspection of downloaded html file shows that finish time appears a certain number
# of lines later. Time is then encoded as
# <span>0:34:24.6</span>
# or
# <span>dnf</span>
# so we extract the relevant string and store as time
# If username can't be found, we declare the outcome to be dns.
# Note there's a potential problem if a username is sufficiently
# obscure to feature as a substring somewhere else in the file.
# We'll have to deal with this when it happens.
#
# Pass username as argument, e.g.
#
#  awk -f extract_finish_time_for_user_from_rouvy_race_results.awk -v user=MatthiasHeil downloaded_race_results_file2.html
#
# Required offset is hard coded in BEGIN block. This is what needs to be changed if rouvy
# change their html. Currently the finish time appears 23 lines below first mention of user.
#---------------------------------------------------------------------------------------
BEGIN{offset_from_first_occurence=0; found=0; required_offset=23;}
{
  # If we haven't found username yet, keep looking
  if ( (match($0,"/"user)) && (offset_from_first_occurence==0) ) 
     {
      # Found it; now keep counting the offset of subsequent lines
      # from the first mention
      found=1; offset_from_first_occurence+=1;
      # DEBUG:
      #print offset_from_first_occurence $0;
     };
   # Keep counting  
   if ( offset_from_first_occurence > 0 )
      {
        offset_from_first_occurence+=1;
      };
   #DEBUG
   #if ( offset_from_first_occurence > 0 )
   #   {
   #    print "offset: " offset_from_first_occurence " " $0;
   #   };
   # Time is at required_offset
   # print "bla : " offset_from_first_occurence " " required_offset
   if ( offset_from_first_occurence == required_offset)   
     {
      # Actual time (or dnf) is currently surrounded by <span></span>
      offset_from_first_occurence+=1;
      start=index($1,">")+1;
      end=index($1,"/span");
      lngth=end-start-1;
      print user " : " substr($1,start,lngth);
     }
}
END{if (found==0){print user " : dns"}}

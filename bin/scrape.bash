#! /bin/bash


# hierher read in race details from generated race id file (generated from
# master list (official races) and user generated ones)


#https://my.rouvy.com/onlinerace/detail/86636
#https://my.rouvy.com/onlinerace/detail/87429

# Race 8:
#--------
race_number_list=$race_number_list" 8"
race_id_list[8]="87429 86636"



# Loop over overall races, each one of which typically has three sub-races
for race_number in `echo $race_number_list`; do
    

    # Loop over sub-races
    count_subrace=0
    sub_race_result_list=""
    for race_id in `echo ${race_id_list[$race_number]}`; do
        let count_subrace=$count_subrace+1
        
        url=https://my.rouvy.com/onlinerace/detail/$race_id
        echo "Race URL: "$url
        
        webpage_file="downloaded_data/webpage_race_"$race_id
        echo "Webpage downloaded to: "$webpage_file
        
        result_file="results/result_race_"$race_number"_"$count_subrace"_"$race_id
        echo "Results written to: " $result_file

        sub_race_result_list=$sub_race_result_list" "$result_file

        echo "Bypassing wget for " $url
        # wget -O $webpage_file $url
        
        
        user_list=`cat input_data/user_list.txt`
        
        rm -f .tmp_result_file
        for user in `echo $user_list`; do
            #echo "doing user: " $user 
            echo "BEGIN{offset_from_first_occurence=0; found=0}" > .awk_script.txt
            echo "{ if ( (match(\$0,\"/$user\")) && (offset_from_first_occurence==0) ) " >> .awk_script.txt
            echo "     {" >> .awk_script.txt
            echo "      found=1; offset_from_first_occurence+=1;" >> .awk_script.txt
            echo "      # DEBUG: print offset_from_first_occurence \$0" >> .awk_script.txt
            echo "     };" >> .awk_script.txt
            echo "   if ( offset_from_first_occurence > 0 )" >> .awk_script.txt
            echo "      {" >> .awk_script.txt
            echo "          offset_from_first_occurence+=1" >> .awk_script.txt
            echo "      };" >> .awk_script.txt
            echo "   #DEBUG" >> .awk_script.txt
            echo "   #if ( offset_from_first_occurence > 0 )" >> .awk_script.txt
            echo "   #   {" >> .awk_script.txt
            echo "   #    print \"offset: \" offset_from_first_occurence \" \" \$0;" >> .awk_script.txt
            echo "   #   };" >> .awk_script.txt
            echo "   # Time is at offset 23:" >> .awk_script.txt
            echo "      if ( offset_from_first_occurence == 23)" >> .awk_script.txt
            echo "         {" >> .awk_script.txt
            echo "             offset_from_first_occurence+=1;" >> .awk_script.txt
            echo "              lngth=length(\$1);" >> .awk_script.txt
            echo "             start=7;" >> .awk_script.txt
            echo "             length_to_display=lngth-7-6;" >> .awk_script.txt
            echo "             print \"$user : \" substr(\$1,start,length_to_display)}" >> .awk_script.txt
            echo "}" >> .awk_script.txt
            echo "END{if (found==0){print \"$user :  dns\"}}" >> .awk_script.txt

            #echo "about to do awk for webpage_file "$webpage_file
            awk -f .awk_script.txt $webpage_file  >> .tmp_result_file
            #echo "done awk"

        done
        
        # Sort by name of user
        sort .tmp_result_file > $result_file
        rm -f .tmp_result_file
        
        #echo "Result: "
        #cat $result_file
        
        
    # End of race id list (typically three per race)
    done
    
    
    
    
    
    # Now collate all individual races
    #---------------------------------
    paste_command="paste "
    for race_result in `echo $sub_race_result_list`; do
        paste_command=$paste_command" "$race_result
    done


    html_file="generated_html/results_race"$race_number".html"
    cat html_templates/html_start.txt > $html_file
    echo "<h2>Race "$race_number"</h2>" >>  $html_file
    echo "<h3>Alphabetical list</h3>" >>  $html_file
    echo "<table>" >>  $html_file
    echo "paste command: " $paste_command
    `echo $paste_command`| awk -f bin/create_rank_table_for_race.awk > .tmp_file
    cat .tmp_file >> $html_file
    echo "</table>" >> $html_file
    echo "<h3>Ranked list</h3>" >>  $html_file
    echo "<table>" >>  $html_file
    sort -k 5 -o .sorted_tmp_file .tmp_file
    cat .sorted_tmp_file >>  $html_file
    echo "</table>" >>  $html_file
    cat html_templates/html_end.txt >> $html_file

    
# End over races
done

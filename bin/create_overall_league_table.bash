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



# LOOP OVER FULL/WEDNESDAY/SATURDAY SERIES
sub_series_number_list="1 2 3"
sub_series_postfix=""
sub_series_title_postfix=" (full series)"
race_day_list="Wed Thu Sat Sun"
for sub_series_number in `echo $sub_series_number_list`; do
    
    # Set up relevant strings
    case $sub_series_number in
	1) echo "Doing full series"
	   ;;
	2) sub_series_postfix="_wed"
	   sub_series_title_postfix=" (Wednesday only)"
	   race_day_list="Wed Thu"
	   echo "Doing Wednesday only"
	   ;;
	3) sub_series_postfix="_sat"
	   sub_series_title_postfix=" (Saturday only)"
	   race_day_list="Sat Sun"
	   echo "Doing Saturday only"
	   ;;
	*) echo "Wrong subseries number '${1}'; doing full series"
	   ;;
    esac

    #echo "Postfix: "$sub_series_postfix
    #echo "Title:   "$sub_series_title_postfix

    html_file=generated_race_data/$race_series/league_table$sub_series_postfix.html
    active_users_json_file=generated_race_data/$race_series/head_to_head_active_users$sub_series_postfix.json
    race_results_json_file=generated_race_data/$race_series/head_to_head_race_results$sub_series_postfix.json

    echo -e "{\n\"active_users\" : [" > $active_users_json_file
    echo -e "[\n{" > $race_results_json_file
    
    # Do we have users?
    if [ ! -e ./master_race_data/$race_series/user_list.txt ]; then
	echo -e "\033[0;31mERROR:\033[0m No users for series, i.e. master_race_data/$race_series/user_list.txt doesn't exist!"
	exit 1
    fi
    
    # Create an associative array
    unset total_points
    unset races_completed
    declare -A total_points
    declare -A races_completed
    
    # Loop over all races in this series
    race_number_in_series=0
    #dir_list=`ls -d generated_race_data/$race_series/race?????`
    dir_list=`find generated_race_data/$race_series -name 'race?????'`
    rev_dir_list_aux=`echo $dir_list | awk '{ for (i=NF; i>=1; i--) printf("%s ",$i); print $1; }'`
    rev_dir_list=`echo $rev_dir_list_aux | awk '{for (i=1;i<NF;i++){print $i}}' | sort -r -n`
    #echo "dir list : "$dir_list
    #echo "rev_dir list : "$rev_dir_list
    
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

	    #echo "Post-processing: "`pwd`"/results.html"
	    extracted_date_string=`awk '{if ($1=="<h2>Race"){print $4" "$5" "$6}}' results.html`
	    #echo "extracted date string: "$extracted_date_string
	    extracted_day=`date --date="$extracted_date_string" | awk '{print $1}'`
	    #echo "extracted day string: "$extracted_day

	    include_race=0
	    for legal_race_day in `echo $race_day_list`; do
		if [ "$extracted_day" == "$legal_race_day" ]; then
		    include_race=1
		fi
	    done

	    if [ $include_race -eq 0 ]; then
		#echo "Excluding race from sub-series"
		rm .tmp_html_body_for_race.html
	    else
		#echo "Including race from sub-series"

		echo "Race "$race_number_in_series > .head_to_head_race_results_json_file.json
		
		# Prefix 10# declares numbers to be decimals in base 10
		# https://stackoverflow.com/questions/21049822/value-too-great-for-base-error-token-is-09
		command=`awk '{if ($1=="<tr><td>"){print "let total_points["$4"]=$((10#$((${total_points["$4"]}))))+$((10#"$10")); "}}' results.html`
		eval $command
		
		# Output username and points
		awk '{if (($1=="<tr><td>")&&($7!="DNR")&&($7!="Other")){print $4" "$10}}' results.html >> .head_to_head_race_results_json_file.json

		echo "Column 7: "
		awk '{if ($1=="<tr><td>"){print $7}}' results.html 

		# Get the total number of races completed
		# Entry 7 contains time as hh:mm:ss.t so if that entry contains a colon, we have a race time
		command=`awk '{if ($1=="<tr><td>"){pos_of_colon=match($7,":"); if (pos_of_colon!=0){print "let races_completed["$4"]=$((10#$((${races_completed["$4"]}))))+1; "}}}' results.html`
		#echo "COMMAND: "$command
		eval $command

		# Active users hierher are they really active? What about dnf etc.
		awk '{if ($1=="<tr><td>"){pos_of_colon=match($7,":"); if (pos_of_colon!=0){print $4}}}' results.html >> .head_to_head_active_users_json_file.json
		
		# Fill up body of file with individual race results (strip out body tags)
		awk 'BEGIN{dont_print=1}{if (dont_print!=1){print $0}; if ($1=="<body>"){dont_print=0}; if ($1=="</body>"){dont_print=1};}' results.html > .tmp_html_body_for_race.html
		sed -i 's/<\/body>//g' .tmp_html_body_for_race.html
		
		# Get rid of bottom line
		cp .tmp_html_body_for_race.html .tmp_html_body_for_race2.html
		awk '{if (index($0,"back_to_rvy_racing_homepage") == 0){print $0}}' .tmp_html_body_for_race2.html > .tmp_html_body_for_race.html
		rm -f .tmp_html_body_for_race2.html
	    fi
	fi
	cd $home_dir
    done
    
    echo "<h2>Overall league table for race series <em>"$race_series"</em>"$sub_series_title_postfix"</h2>" >  $html_file
    echo "<div style=\"text-align:left; font-size:medium;\">[Click on \"Rank\", \"Points\", \"# of races\" or \"Points/Race\" to re-sort. Overall rank remains based on total number of points.]</div><br>" >>  $html_file
    
    # Crazy hacky duplication with user_csv_to_txt_and_sed.bash; if you update the stuff below update there too (it fills in the private data)
    echo "<table id=\"league_table"$sub_series_postfix"\" style=\"border-spacing:10px; width:60%; background-color:white;\">" >>  $html_file
    echo "<tr style=\"background-color:yellow;\"> <th class=\"th_sortable\" style=\"background-color:gold;\" onclick=\"sort_column_in_table('asc',this,0)\">Rank<span class=\"up_down_arrow_in_league_table\">&#8597;</span></th> <th>Rouvy username</th> <th class=\"th_sortable\" onclick=\"sort_column_in_table('desc',this,6)\">Points<span class=\"up_down_arrow_in_league_table\">&#8597;</span></th> <th class=\"th_sortable\" onclick=\"sort_column_in_table('desc',this,7)\"><span style=\"white-space:nowrap;\"># of races</span><span class=\"up_down_arrow_in_league_table\">&#8597;</span></th> <th class=\"th_sortable\" onclick=\"sort_column_in_table('desc',this,8)\">Points/Race<span class=\"up_down_arrow_in_league_table\">&#8597;</span></th> </tr>" >>  $html_file
    rm -f .tmp_league_table.dat
    rm -f .tmp_league_table2.dat
    rm -f .tmp_league_table3.dat
    for i in "${!total_points[@]}"; do
	ncompleted=0;
	if [ "${races_completed[$i]}" != "" ]; then ncompleted=${races_completed[$i]}; fi
	echo "<tr>  <td> "$i" </td> <td> " ${total_points[$i]} " </td> <td> " $ncompleted " </td> </tr>" >> .tmp_league_table.dat
    done
    #echo ".tmp:"
    #cat  .tmp_league_table.dat
    #echo "end .tmp"
    if [ -e  .tmp_league_table.dat ]; then
	sort -k 6 -n -r .tmp_league_table.dat > .tmp_league_table2.dat
    fi
    
    #echo ".tmp2:"
    #cat  .tmp_league_table2.dat
    if [ -e  .tmp_league_table2.dat ]; then
	awk 'BEGIN{count=1;}{if ($1 == "<tr>"){printf("<tr> <td> %s </td>", count); for (i=2;i<=NF;i++){printf(" %s",$i)}; count++}; print " "}' .tmp_league_table2.dat >> .tmp_league_table3.dat
    fi
    
    # add points per race
    if [ -e  .tmp_league_table3.dat ]; then
	# points in column 9 number of races in 12
	awk '{if ($1 == "<tr>"){for (i=1;i<=12;i++){printf(" %s",$i)}; print " </td> <td> "; if ($12==0){print "0"}else{printf("%4.2f",$9/$12); print " </td> </tr>"}}}' .tmp_league_table3.dat >> $html_file
    fi
    
    
    
    echo "</table>" >>  $html_file
    echo "<br>" >>  $html_file
    echo "League table processed: "`date --utc`  >>  $html_file
    echo "<br>" >>  $html_file
    echo "<hr>" >>  $html_file
    echo " " >>  $html_file
    
    echo "<h2>Individual race results:</h2>" >> $html_file
    added_race=0
    for dir in `echo $rev_dir_list`; do
	#echo "#"
	#echo "#"
	#echo "APPENDING $dir/.tmp_html_body_for_race.html to $html_file"
	#echo "IN "`pwd`
	#echo "#"
	#echo "#"
	if [ -e  $dir/.tmp_html_body_for_race.html ]; then
	    cat $dir/.tmp_html_body_for_race.html >>  $html_file
	    added_race=1
	fi
    done
    if [ $added_race -eq 0 ]; then
	echo "[No contributing races for this series]"  >>  $html_file
    fi
    
    # cat $home_dir/html_templates/html_end.txt >> $html_file
    
    
    # Now rectify ties (should really have built this in above so it's a bit of a hack to do this now but...
    $home_dir/bin/rectify_ties.bash $html_file > .junk.txt
    mv .junk.txt $html_file


    echo "Postprocessing from here: "`pwd`
    ls -l
    back_to_where_we_were=`pwd`
    cd generated_race_data/$race_series

    # Find active users
    cat race*/.head_to_head_active_users_json_file.json > .tmp_combined_user_file
    # sed to replace just one occurence of comma with closing bracket:
    # https://stackoverflow.com/questions/8081297/sed-to-change-string-in-a-file-only-once
    sort -u .tmp_combined_user_file | awk '{if ($1!=""){print "\""$1"\","}}' | tac | sed '0,/,/s//]/' | tac >> head_to_head_active_users$sub_series_postfix.json
    echo "}" >> head_to_head_active_users$sub_series_postfix.json
    if [ -e .tmp_combined_user_file ]; then
	active_user_list="`sort -u .tmp_combined_user_file | awk '{if ($1!=""){print $1" "}}'`"

	# Loop over races
	race_results_list="`find race* -name '.*results_json_file.json'`"
	for race_results_file in `echo $race_results_list`; do

	    # Start header
	    head -n 1 $race_results_file | awk '{print "\"name\": \"Race"$2"\",\n\"results\":\n["}' >> head_to_head_race_results$sub_series_postfix.json 

	    
	    # Now filter out active users
	    for active_user in `echo $active_user_list`; do
		name=`grep $active_user $race_results_file | awk '{print $1}'`
		points=`grep $active_user $race_results_file | awk '{print $2}'`
		if [ "$name" != "" ]; then
		    if [ "$points" != "" ]; then
			echo "{\"rouvy_username\":\""$name"\",\"points\":"$points"}," >> head_to_head_race_results$sub_series_postfix.json
		    fi
		fi
	    done
	    echo -e "]},{\n" >> head_to_head_race_results$sub_series_postfix.json
	    
	    # remove bloody trailing commas
	    # https://unix.stackexchange.com/questions/485004/remove-trailing-commas-from-invalid-json-to-make-it-valid
	    sed -i ':begin;$!N;s/,\n]/\n]/g;tbegin;P;D' head_to_head_race_results$sub_series_postfix.json 

	done

	# ...and the final one I'm doing by brute force
	tac head_to_head_race_results$sub_series_postfix.json  | awk 'BEGIN{done=0}{if (done==0){if ($1=="]},{"){print "]}]"; done=1}}else{print $0}}' | tac > .junk.txt
	mv .junk.txt head_to_head_race_results$sub_series_postfix.json
	   
    fi
    
    
    cd $back_to_where_we_were
    
#end of loop over subseries
done

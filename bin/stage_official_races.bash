#! /bin/bash

# Be verbose for debugging?
verbose_debug=0

# Pass in as command line
race_series="test_series"

# Script should be run from home directory
home_dir=`pwd`
if [ ! -e master_race_data ]; then
    echo "ERROR: Script ought to be run from home directory, so that"
    echo "directory master_race_data is available as ./master_race_data."
    echo "You are in $home_dir"
    exit
fi


echo " " 
echo "Setting up series "$race_series
rm -f master_race_data/$race_series/all_races_in_series.html


# Loop over all races in this series
race_number_in_series=0
dir_list=`ls -d master_race_data/$race_series/*`
for dir in `echo $dir_list`; do

    # Bump
    let race_number_in_series=$race_number_in_series+1
    echo "Doing race "$race_number_in_series" in series"

    # Go into race
    cd $dir
    if [ -e downloaded_official_race_pages ]; then
        if [ $verbose_debug == 1 ]; then echo `pwd`"/downloaded_official_race_pages already exists."; fi
    else
        mkdir downloaded_official_race_pages
        if [ $verbose_debug == 1 ]; then echo "made "`pwd`"/downloaded_official_race_pages dir"; fi
    fi
    
    # Read the URLs of the official races
    url_list=`cat official_race.dat`
    cd downloaded_official_race_pages
    race_number=1
    race_date_from_race1="dummy"
    route_id_from_race1="dummy"
    route_title="dummy"
    
    # Loop over all races, download race html file from rouvy
    # and check that they're all
    # - on the same day
    # - on the same route
    for url in `echo $url_list`; do
        html_file="downloaded_race_file"$race_number".html"
        if [ -e $html_file ]; then
            if [ $verbose_debug == 1 ]; then echo "Have already downloaded "$html_file; fi
        else
            wget -O $html_file $url
        fi

        # Extract race date and time from downloaded html files
        # Race date is listed as <span class="date">05/11/2022</span>
        # Race time is listed as <span class="time">01:00:00</span>
        # Route ID and name are listed as <h3><img class="flagIco" src="https://cdn.rouvy.com/www/images/flags/IT.png" alt="IT"><a href="/virtual-routes/detail/91851">PEDALITALY Etna - Sicily - Italy</a></h3>
        if [ $race_number -eq 1 ]; then
            race_date_from_race1=`grep 'span class="date">' *1.html | awk '{print substr($2,14,10)}'`
            route_id_from_race1=`grep virtual-routes/detail *1.html | awk '{nstart=index($0,"virtual-route"); last_bit=substr($0,nstart); nend=index(last_bit,"\""); print substr(last_bit,23,nend-23)}'`
            route_title=`grep virtual-routes/detail *1.html | awk '{nstart=index($0,"virtual-route"); last_bit=substr($0,nstart); nend_of_route_id=index(last_bit,"\""); n_end_of_route_title=index(last_bit,"</a>"); print substr(last_bit,nend_of_route_id+2,n_end_of_route_title-(nend_of_route_id+2))}'`

            day=`echo $race_date_from_race1 | awk '{print substr($0,4,2)}'`
            month=`echo $race_date_from_race1 | awk '{print substr($0,1,2)}'`
            year=`echo $race_date_from_race1 | awk '{print substr($0,7)}'`

            # an array to look up th month-names
            month_names=(not_a_month Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
            
            echo "<h2>Race "$race_number_in_series" : " $day " " ${month_names[${month}]} " " $year "</h2><br>" > .race.html
            echo "<b>Route:</b> <a href=\"https://my.rouvy.com/virtual-routes/detail/"$route_id_from_race1"\">"$route_title"</a>" >> .race.html
            echo "<ul>" >> .race.html
        else
            cmd_string="grep 'span class=\"date\">' *"$race_number".html | awk '{print substr(\$2,14,10)}'"
            race_date=`eval $cmd_string`
            if [ "$race_date" != "$race_date_from_race1" ]; then
                echo "WARNING: official races 1 and "$race_number" are on different dates: -"$race_date"- and -"$race_date_from_race1"-"
            else
                if [ $verbose_debug == 1 ]; then echo "OK: official races 1 and "$race_number" are on same date!"; fi 
            fi
        fi
        cmd_string="grep 'span class=\"time\">' *"$race_number".html | awk '{print substr(\$2,14,8)}'"
        race_time=`eval $cmd_string`
        echo "<li>  <a href="$url">Official race $race_number: $race_time (GMT)</a>" >> .race.html
        let race_number=$race_number+1
    done
    echo "</ul>" >> .race.html
    
    # Prepare link to rouvy race ranking (dummy page until race is over and has been processed)

    if [ ! -e ../results.html ]; then
        echo "Race hasn't been raced or processed yet!" > ../results.html
    fi
    race_results_file=`basename $dir`/results.html
    echo "<a href=\"$race_results_file\">Race results</a>" >> .race.html

    # hierher check if file exists; if so leave; otherwise prepare placeholder entry
    
    # Add to race info for overall series (reverse order)
    touch $home_dir/master_race_data/$race_series/all_races_in_series.html
    mv $home_dir/master_race_data/$race_series/all_races_in_series.html .tmp
    cat .race.html .tmp >> $home_dir/master_race_data/$race_series/all_races_in_series.html
    rm -f .tmp
    rm .race.html


    

    # Get read for the next one
    cd $home_dir
    
done


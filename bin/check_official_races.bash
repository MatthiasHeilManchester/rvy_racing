#! /bin/bash



home_dir=`pwd`

# Pass in as command line
race_series="test_series"



dir_list=`ls -d master_race_data/$race_series/*`
for dir in `echo $dir_list`; do

    cd $dir
    if [ -e downloaded_official_race_pages ]; then
        echo "downloaded_official_race_pages exists; emptying"
        cd downloaded_official_race_pages
        rm -f *.html
        cd ..
    else
        mkdir downloaded_official_race_pages
        echo "made downloaded_official_race_pages dir"
    fi
    url_list=`cat official_race.dat`
    cd downloaded_official_race_pages
    race_number=1
    race_date_from_race1="dummy"
    for url in `echo $url_list`; do
        html_file="downloaded_race_file"$race_number".html"
        if [ -e $html_file ]; then
            echo "Have already downloaded "$html_file
        else
            wget -O $html_file $url
        fi


        # Extrac race date and time from downloaded html files
        # Race date is listed as <span class="date">05/11/2022</span>
        # Race time is listed as <span class="time">01:00:00</span>
        if [ $race_number -eq 1 ]; then
            race_date_from_race1=`grep 'span class="date">' *1.html | awk '{print substr($2,14,10)}'`
            echo "bla: "$race_date_from_race1    
        else
            cmd_string="grep 'span class=\"date\">' *"$race_number".html | awk '{print substr(\$2,14,10)}'"
            echo "BLA: "$cmd_string
            race_date=`eval $cmd_string`
            echo "BLABLA: "$race_date
            echo "Bla: " $race_date " Bla2: " $race_date_from_race1          
            if [ "$race_date" == "$race_date_from_race1" ]; then
                echo "ERROR: official races 1 and "$race_number" are on different dates!"
            else
                echo "OK: official races 1 and "$race_number" are on same date!"
            fi
        fi
        # hierher race_time[$race_number=`grep 'span class="date">' *$.html | awk '{print substr($2,14,8)}'`
        let race_number=$race_number+1
    done
done

# hierher loop over all races and check their dates
#dir=master_race_data/test_series/race00001

#! /bin/bash


#=====================================================
# Extract key parameters, namely
#
# - race date
# - race time
# - route id
# - route title
#
# from rouvy race html file
#=====================================================
wrong_args="ERROR: Wrong command line arg. Please pass name_of_html_file and one of {--date,--time,--route_id,--route_title}"
if [ $# -ne 2 ]; then
 echo $wrong_args
 exit 1
fi


# Patterns may need to be changed if rouvy change their webpages.

# Race date is listed as <span class="date">05/11/2022</span>
if [ "$2" == "--date" ];  then
    echo `grep 'span class="date">' $1 | awk '{print substr($2,14,10)}'`


# Race time is listed as <span class="time">01:00:00</span>
elif [ "$2" == "--time" ];  then
    echo `grep 'span class="time">' $1 | awk '{print substr($2,14,8)}'`


# Route ID and name are listed as <h3><img class="flagIco" src="https://cdn.rouvy.com/www/images/flags/IT.png" alt="IT"><a href="/virtual-routes/detail/91851">PEDALITALY Etna - Sicily - Italy</a></h3>
elif [ "$2" == "--route_id" ];  then
    echo `grep virtual-routes/detail $1 | awk '{nstart=index($0,"virtual-route"); last_bit=substr($0,nstart); nend=index(last_bit,"\""); print substr(last_bit,23,nend-23)}'`
elif [ $2 == "--route_title" ]; then
    echo `grep virtual-routes/detail $1 | awk '{nstart=index($0,"virtual-route"); last_bit=substr($0,nstart); nend_of_route_id=index(last_bit,"\""); n_end_of_route_title=index(last_bit,"</a>"); print substr(last_bit,nend_of_route_id+2,n_end_of_route_title-(nend_of_route_id+2))}'`
else
    echo $wrong_args
    exit 1
fi

#! /bin/bash

#--------------------------------------------------------------------------
# Change permissions for directories that apache needs to be able to write
# to
#--------------------------------------------------------------------------
if [ ! -e master_race_data ]; then
    echo -e "\033[0;31mERROR:\033[0m Script ought to be run from home directory, so that"
    echo "directory master_race_data is available as ./master_race_data."
    echo "You are in "`pwd`
    exit 1
fi

echo " " 
echo "one off preparation: "
echo " "
echo "sudo groupadd webmasters"
echo "sudo usermod -a -G webmasters matthias"
echo "sudo usermod -a -G webmasters www-data"
echo " "
read -p "Press enter to continue"
echo " " 



dir_list="backups_of_generated_html contributed_race_data generated_race_data generated_html bolshy_logs"
for dir in `echo $dir_list`; do

    sudo chgrp -R webmasters ./$dir
    sudo chmod -R ug+rwx $dir
    sudo chmod -R g+s $dir
done

exit
    



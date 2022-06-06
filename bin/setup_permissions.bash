#! /bin/bash

#--------------------------------------------------------------------------
# Change permissions for directories that apache needs to be able to write
# to
#--------------------------------------------------------------------------
if [ ! -e master_race_data ]; then
    echo "ERROR: Script ought to be run from home directory, so that"
    echo "directory master_race_data is available as ./master_race_data."
    echo "You are in "`pwd`
    exit 1
fi

echo " " 
echo "one off preparation: "
echo " "
echo "sudo group add webmasters"
echo "sudo groupadd webmasters"
echo "sudo usermod -a -G webmasters matthias"
echo "sudo usermod -a -G webmasters www-data"
echo " "
read -p "Press enter to continue"
echo " " 



sudo chgrp -R webmasters ./contributed_race_data
sudo chgrp -R webmasters ./generated_race_data
sudo chmod -R ug+rwx generated_race_data
sudo chmod -R ug+rwx contributed_race_data
sudo chmod -R g+s generated_race_data
sudo chmod -R g+s contributed_race_data

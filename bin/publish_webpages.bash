#! /bin/bash


if [ ! -e  master_race_data ]; then
    echo "ERROR: Script must be run in home directory so master_race_data is"
    echo "accessible as ./master_race_data"
    echo " "
    echo "You are in: "`pwd`
    echo " " 
    exit
fi
cd master_race_data


# Extracting generated data for all series and races
#https://superuser.com/questions/513304/how-to-combine-the-tar-command-with-find
find . \( -iname 'results.html' -o -iname 'all_races_in_series.html' \) -print0  | tar -cf generated_html_files.tar --null -T -



# Backup old generated html (which is served by webserver)
cd ..
if [ ! -e backups_of_generated_html ]; then
    echo "ERROR: Script must be run in home directory so backups_of_generated_html is"
    echo "accessible as ./backups_of_generated_html"
    echo " "
    echo "You are in: "`pwd`
    echo " " 
    exit
fi
backup_file="backups_of_generated_html/backup_"`date | sed 's/ /_/g'`".tar.gz"
tar  cfz $backup_file generated_html

# Kill previous version
cd generated_html
find  . -maxdepth 1 -type d -name '*[a-zA-Z]*' -exec rm -rf {} \;
cd ..

# Move and unpack updated version
mv master_race_data/generated_html_files.tar generated_html
cd generated_html
tar xf generated_html_files.tar
rm -f generated_html_files.tar




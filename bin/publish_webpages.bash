#! /bin/bash


if [ ! -e  generated_race_data ]; then
    echo "ERROR: Script must be run in home directory so generated_race_data is"
    echo "accessible as ./generated_race_data"
    echo " "
    echo "You are in: "`pwd`
    echo " " 
    exit
fi
cd generated_race_data


# Extracting generated data for all series and races
# https://superuser.com/questions/513304/how-to-combine-the-tar-command-with-find
# Also use -h in tar follow links so make a deep copy
find . \( -iname 'results.html' -o -iname 'all_races_in_series.html' -o -iname 'league_table.html' \) -print0 | tar -hcf  generated_html_files.tar --null -T -



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
mv generated_race_data/generated_html_files.tar generated_html
cd generated_html
tar xf generated_html_files.tar
rm -f generated_html_files.tar

# Copy across style file and general page
dir_list=`find  . -maxdepth 1 -type d`
for dir in `echo $dir_list`; do
    cp ../html/style.css $dir
    cp ../html/rvy_racing.php $dir
    cp ../html/rvy_racing.png $dir
    cp ../html/nonono.png $dir
done




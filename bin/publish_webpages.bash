#! /bin/bash

#-----------------------------------------------------------------
# publish webpages (after backing up the old ones!)
#-----------------------------------------------------------------

if [ ! -e  generated_race_data ]; then
    echo -e "\033[0;31mERROR:\033[0m Script must be run in home directory so generated_race_data is"
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
    echo -e "\033[0;31mERROR:\033[0m Script must be run in home directory so backups_of_generated_html is"
    echo "accessible as ./backups_of_generated_html"
    echo " "
    echo "You are in: "`pwd`
    echo " " 
    exit
fi
backup_file="backups_of_generated_html/backup_"`date --utc | sed 's/ /_/g'`".tar.gz"
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
dir_list=`find  . -mindepth 1 -maxdepth 1 -type d`

# Find actual race directory (without month modifiers)
shortest_length=`echo $dir_list | wc -c`
shortest_dir="-"
for dir in `echo $dir_list`; do
    length=`echo $dir | wc -c` 
    if [ $length -lt $shortest_length ]; then
	shortest_dir=$dir
	shortest_length=$length
    fi
done

if [ $shortest_dir == "-" ]; then
    echo "ERROR: Didn't find shortest directory; copying the lot."
else    
    echo "Found shortest dir: "$shortest_dir
    dir_list=$shortest_dir
fi
for dir in `echo $dir_list`; do
    echo "Copying generic web stuff for dir: "$dir
    cp ../html/style.css $dir
    cp ../html/rvy_racing.php $dir
    cp ../html/rvy_racing.png $dir
        cp ../html/click-to-sort_thumbnail.png $dir
    cp ../html/nonono.png $dir
    cp ../html/add_your_own.jpg $dir
    cp ../html/private_message.jpg $dir
    cp ../html/contact.jpg $dir
    cp ../html/registration1.jpg $dir
    cp ../html/registration2.jpg $dir
    cp ../html/registration3.jpg $dir
    cp ../html/registration4.jpg $dir
    cp ../html/subscribe_to_forum1.jpg $dir
    cp ../html/subscribe_to_forum2.jpg $dir
    cp ../html/subscribe_to_forum3.jpg $dir
    cp ../html/profile1.jpg $dir
    cp ../html/profile2.jpg $dir
    cp ../html/profile3.jpg $dir
    cp ../html/profile4.jpg $dir
done




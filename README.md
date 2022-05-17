# To do
- [publish races, series by series]
- Add race info to results.html (recycle information that's already being generated when creating dummy text).
- Make sure that race00001 is created in empty directory
- tab complete race series!
- create overall league table (separate script!)
- add option for user-contributed races
   - add link to appropriate php script when creating race data in `all_races_in_series.html`; php file should be told what race series/number we're dealing with so user contributed data is written in the right place.

---

# Create a new race series:
- Create race series directory, so for a `fake_commute` series, say, do
    ```bash
    cd master_race_series  
    mkdir fake_commute
    cd fake_commute
    ```
- Create the user list
    ```bash
    emacs user_list.txt
    ``` 
    which contains the rouvy usernames of all riders, e.g.
    ```bash
    > cat master_race_data/fake_commute/user_list.txt
    ```
    ```
    MatthiasHeil
    nigelhardy
    MARK_J
    Robbo_66
    HeikeHardt
    ```

---

# Create new official race(s) in series

- Each official race is typically repeated several times (for different timezones). The different rouvy races (all on the same route, of course) are staged as follows:

- Create race directory and specify URLs of races:
```bash

# Go to race series directory
cd master_race_series/fake_commute

# Make directory for this race
mkdir race00001  # 5 digits
cd race00001

# Specify rouvy races via their url
emacs official_races.dat
```
which contains, e.g.
```bash
https://my.rouvy.com/onlinerace/live/87061
https://my.rouvy.com/onlinerace/live/87063
https://my.rouvy.com/onlinerace/live/87064
```

In our specific example the file is
```bash
master_race_series/fake_commute/race00001/official_races.dat
```
- You can create as many races as you want; they are ordered alphanumerically, so assuming you stick the to conventions above, by the 5-digit number in the race directory.
- In fact, there's a script that will create the "next" race directory for you and open the `official_races.dat` file! Run it in the race series directory, e.g.  
  ```bash
  # Go to the relevant race series
  cd master_race_series/fake_commute
  
  # Run the script
  ../../bin/create_next_race.bash
  ```
  Note that if you abandon this process, the directory will remain there (empty), so make sure you delete it before doing it properly (otherwise race 3 will turn into race 4 with race 3 being empty!).
---

# Stage the races 

Once the (typically multiple) rouvy races for a given route are specified, using the steps described in the previous step, we extract information about dates and times of races, names of routes, etc. from rouvy html files. These are downloaded if not yet available (delete the directory  `downloaded_official_race_pages/` in the race directory to force a new download if anything has been changed).

Information is cross-checked (e.g. different instances of the race have to be on the same route, on the same day, etc.) and then summarised in the html file 
```bash
master_race_series/fake_commute/all_races_in_series.html
```
say. This file lists the race details (in reverse chrononological order) for all races, and provides links to the race results. These are initially populated with a dummy text which gets overwritten when the results are processed (see below).

- To stage the races run the script `bin/stage_official_races.bash` in the home directory, specifying the name of the race series, e.g.
```bash
bin/stage_official_races.bash fake_commute
``` 
---
# Publish races
Run 
```bash
bin/publish_races.bash
```
in the home directory. This does the following:
- Make a backup of the content of the `generated_html/` directory, labels the tar file with time and date of the backup and moves it to the `backups_of_generated_html` directory.
- Tar up the relevant staged html files (with their directory structure, so relative links remain functional) from the `master_race_series/` directory and unpack them in `generated_html/`.

Once this is done, the races are visible to outside users.

---

# Post-process races

Once a race is over, the race html file needs to be downloaded again to obtain the finish times (using the best times from the multiple races on the route). This is done separately for each race, so to process `race00002` from the `fake_commute` series, do
```bash
# Go to the relevant race directory
cd master_race_series/fake_commute/race00002

# Post-process the race
../../../bin/process_race_outcome.bash
```
This downloads the html files of the rouvy race pages (which should by now contain the results for everybody), does the same sanity check as when staging the races, and then extracts the finishing times (or DNS/DNF) for all users specified in the `user_list.txt` file for the race series. Results are written to `results.html`, so here
```bash
master_race_series/fake_commute/race00002/results.html
```
This overwrites the dummy text created when the stage was initially staged.
Check the results, e.g. by doing
```bash
firefox master_race_series/fake_commute/all_races_in_series.html
```
and if everything looks ok, (re-)publish the races as described above.


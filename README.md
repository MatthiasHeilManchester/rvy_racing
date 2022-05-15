# To do
- publish races series by series
- do overall league table
- add user-contributed races (create dummy to appropriate php webpage) which should be told what race series/number we're dealing with.

---

# Create new race series:
- Create series directory:
    ```bash
    cd master_race_series  
    mkdir fake_commute
    cd fake_commute
    ```
- Create user list
    ```bash
    emacs user_list.txt
    ``` 
    which contains, e.g.
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

# Create new race(s) in series

- Create race directory and specify instances of races (typically three for different timezones) by adding urls of rouvy races to `official_races.dat`:
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

- Keep going until all races are created.

---

# Stage races 

We extract information about dates and times of races, names of routes, etc. from rouvy html files (downloaded if not yet available; delete directory  `downloaded_official_race_pages/` to force a new download if anything has been changed).

Information is cross-checked (e.g. different instances of the race have to be on the same route, on the same day, etc.) and then summarised in the html file 
```bash
master_race_series/fake_commute/all_races_in_series.html
```
say. This file lists the race details (in reverse chrononological order) and provides links to the race results (initially populated with a dummy text which gets overwritten when the results are processed (see below)).

- Run the script `bin/stage_official_races.bash`, specifying the name of the race series, e.g.
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
- Tar up the relevant staged html files (with directory structure) from the `master_race_series/` directory and unpack them in `generated_html/`.

---

# Post-process races

Once a race is over, the race html file needs to be downloaded again. This is done race by race, so to process `race00002` from the `fake_commute` series, do
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
This overwrittes the dummy text created when initially staging the race.

Check the results, e.g. by doing
```bash
firefox master_race_series/fake_commute/all_races_in_series.html
```
and if everything looks ok, (re-)publish the races; see above.


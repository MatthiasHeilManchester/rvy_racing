<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Rvy Racing</title>
    <link rel="stylesheet" href="style.css">
    <script src="script.js"></script>
  </head>
  <body>
  
<?php


// Recover -- these are all for the official race (apart from the race 
// url of the newly contributed race
session_start();
$newly_contributed_race_url = $_SESSION['newly_contributed_race_url'];
$route_id = $_SESSION['route_id'];
$race_series = $_SESSION['race_series'];
$race_number = $_SESSION['race_number'];
$race_date_string = $_SESSION['race_date_string'];

// Pass parameters for official race and the race url of the new race
$command_string="../bin/add_user_contributed_races.bash " .
" " . $race_series . 
" " . $newly_contributed_race_url .
" " . $route_id . 
" " . $race_number .
" " . "\"" . $race_date_string . "\"";
//echo $command_string;
$success_string=shell_exec($command_string);
echo "<pre>".$success_string."</pre>";


?>

</body>
</html>

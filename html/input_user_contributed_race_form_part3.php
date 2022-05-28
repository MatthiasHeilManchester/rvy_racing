
<!DOCTYPE HTML>  
<html>
<head>
<style>
.error {color: #FF0000;}
</style>
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
echo $command_string;
$scripts=shell_exec($command_string);
echo $scripts;


?>

</body>
</html>


<!DOCTYPE HTML>  
<html>
<head>
<style>
.error {color: #FF0000;}
</style>
</head>
<body>
  
<?php

// Recover
session_start();
$race_url = $_SESSION['race_url'];
$route_id = $_SESSION['route_id'];
$race_series = $_SESSION['race_series'];
$race_number = $_SESSION['race_number'];
$race_date_string = $_SESSION['race_date_string'];

echo "bla -- ";
echo $race_date_string;
echo $route_id;
echo $race_url;
echo " -- bla bla";



$command_string="../bin/add_user_contributed_races.bash " . $race_series;
echo $command_string;
$scripts=shell_exec($command_string);
echo $scripts;



// Code for managing write access
// echo `whoami`. "\n";
// echo getcwd() . "\n";

// Assuming this returns the user as www-data, then change ownership
// directory as follows
// sudo chown -R www-data user_uploaded_data/


// File with user contributed race urls
// use this one to check error of file opening, causing it to die
// $file_name='user_uploaded_data/user_contributed_races.dat';
$file_name='../user_uploaded_data/user_contributed_races.dat';
$all_lines = file($file_name);
$number_of_lines= count($all_lines);

// Don't allow more than 100 races (more worried about hackers than 
// overenthusiastic users)
$n_max=100; 
if ($number_of_lines < $n_max)
{
 $fp = fopen($file_name,'a') or die("ERROR: Unable to open file" . $file_name . " Please leave a message on the discussion board.");
 fwrite($fp,$race_url . PHP_EOL);
 fclose($fp);
 echo "Done! Your race has been added to the list of user-generated races.";
}
else
{
echo "We already have more than ".$n_max." user contributed races.\n\n";
echo "This probably means something went wrong. Please leave a message on the discussion board. (Your race was not added to the list.)";
}
?>

</body>
</html>

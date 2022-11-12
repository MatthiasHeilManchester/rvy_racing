
<!DOCTYPE HTML>  
<html>
<head>
<style>
.error {color: #FF0000;}
</style>
</head>
<body>  

<?php
 // GET REQUIRED RACE DATA FROM URL: THIS IS THE DATA FOR THE OFFICIAL RACE!

 // Route ID (postfix in url of route on rouvy)
 $route_id=$_GET['route_id'];

 // Route title 
 $route_title=$_GET['route_title'];

 // Name of race series
 $race_series=$_GET['race_series'];

 // Number of race in series
 $race_number=$_GET['race_number'];

 // Race date (GMT)
 $race_date_string=$_GET['race_date_string'];

 // hierher may not be needed 
 // Remember data for the next scripts; all for the official race(s)
 session_start();
 $_SESSION['route_id'] = $route_id;
 $_SESSION['race_series'] = $race_series;
 $_SESSION['race_number'] = $race_number;
 $_SESSION['race_date_string'] = $race_date_string;

 ?>



<h2>Here's a list of the current number of signed-up racers for <em>Race <?php echo $race_number ?></em> in
  the race series <em><?php echo $race_series ?></em> on the route
  <a href="https://my.rouvy.com/virtual-routes/detail/<?php echo
           $route_id?>"><?php echo $route_title ?></a> 
 held on <?php echo $race_date_string ?> (GMT).
</h2>

<?php
 //echo "I'm in directory: ".getcwd()."\n";
 $command="../bin/find_most_popular_race.bash ".$race_series." ".$race_number;
 system($command);
?>



</body>
</html>

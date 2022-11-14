
<!DOCTYPE HTML>  
<html>
<head>
<style>
.error {color: #FF0000;}
</style>
<style>
  table, th, td {
      border: 1px solid black;
      border-collapse: collapse;
      padding: 15px;
  }
  .center_text {
      text-align: center;
  }
</style>
</head>
<body>  

  <?php

   // MH doesn't really understand this. I'm supposed to call this but when I do
   // flushing doesn't work at all...
   // ob_start();
   
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
   
   // not be needed 
   // Remember data for the next scripts; all for the official race(s)
   //session_start();
   //$_SESSION['route_id'] = $route_id;
   //$_SESSION['race_series'] = $race_series;
   //$_SESSION['race_number'] = $race_number;
   //$_SESSION['race_date_string'] = $race_date_string;
   
   ?>
  
  
  <h1>Want the most popular race?</h1>
  <h3><em>Race <?php echo $race_number ?></em> in
    the race series <em><?php echo $race_series ?></em>: <ul><li> Route:
	<a href="https://my.rouvy.com/virtual-routes/detail/<?php echo
		 $route_id?>"><?php echo $route_title ?></a> 
      <li> Date: <?php echo $race_date_string ?> (GMT).</ul>
  </h3>
  
  <?php

   // Loading animation
   echo "<div id=\"loading_image\">";
   echo "<center><img src=\"cyclist.gif\" height=300><h2>Patience please. I'm interrogating rouvy -- while cycling up a hill!</h2></center>";
   echo "</div>";

   // Make loading animation visible
   echo "<script type=\"text/javascript\">";
   echo "document.getElementById('loading_image').style.display = 'visible'";
									   echo "</script>";
   // Flush; see above
   ob_flush();
   ob_end_flush();


   // Now do the actual work.
   $command="../bin/find_most_popular_race.bash ".$race_series." ".$race_number;
   system($command);

   // Hide loading animation
   echo "<script type=\"text/javascript\">";
   echo "document.getElementById('loading_image').style.display = 'none'";
   echo "</script>";

?>

<h3>Please make sure you un-register on rouvy if you can't make it!</h3>


</body>
</html>

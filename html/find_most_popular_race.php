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

   
   // GET REQUIRED RACE DATA FROM URL: THIS IS THE DATA FOR THE OFFICIAL RACE!
   
   // Route ID (postfix in url of route on rouvy)
   $route_id=$_GET['route_id'];
   
   // Route title 
   // $route_title=$_GET['route_title'];

   // Route title
   $route_title_padded=$_GET['route_title'];
   $route_title=str_replace("__rvy_padding_gt_sign_rvy_padding__","&gt;",$route_title_padded);
   
   // Name of race series
   $race_series=$_GET['race_series'];
   
   // Number of race in series
   $race_number=$_GET['race_number'];
   
   // Race date (GMT)
   $race_date_string=$_GET['race_date_string'];
      
   ?>
  
  <div style="text-align:center;">
    <button class="select_league_table_buttons"  onclick="back_to_rvy_racing_homepage_from_top_level_html_dir()">Back to rvy_racing home page</button>
  </div>
  <hr>
  
  
  <h2>Want the most popular race?</h2>
  <em>Race <?php echo $race_number ?></em> in
    the race series <em><?php echo $race_series ?></em>: <ul><li> Route:
	<a href="https://my.rouvy.com/virtual-routes/detail/<?php echo
		 $route_id?>"><?php echo $route_title ?></a> 
      <li> Date: <?php echo $race_date_string ?> (GMT).</ul>
  
  <?php

   // Now do the actual work.
   $command="../bin/find_most_popular_race.bash ".$race_series." ".$race_number;
   system($command);

?>

<br><br>
Please
<ul>
  <li> make sure you un-register on rouvy if you can't make it,</li>
  <li> do not delete any contributed races on the rouvy webpage after they have been registered here (via the "Add your own" option in the race list).</li>
</ul>
Thank you!


</body>
</html>

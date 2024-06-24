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
 $route_title_padded=$_GET['route_title'];
 $route_title=str_replace("__rvy_padding_gt_sign_rvy_padding__","&gt;",$route_title_padded);
 
 // Name of race series
 $race_series=$_GET['race_series'];

 // Number of race in series
 $race_number=$_GET['race_number'];

 // Race date (GMT)
 $race_date_string=$_GET['race_date_string'];

 // Remember data for the next scripts; all for the official race(s)
 session_start();
 $_SESSION['route_id'] = $route_id;
 $_SESSION['race_series'] = $race_series;
 $_SESSION['race_number'] = $race_number;
 $_SESSION['race_date_string'] = $race_date_string;

 ?>



<h2>Create a user contributed race for <em>Race <?php echo $race_number ?></em> in
  the race series <em><?php echo $race_series ?></em>.</h2>

<ul>
<li> The race must be held on the route
  <a href="https://my.rouvy.com/virtual-routes/detail/<?php echo
           $route_id?>"><?php echo $route_title ?></a>.
<li> The race must be held on <?php echo $race_date_string ?> (GMT).
</ul>
<br>
Please go
to <a href="https://my.rouvy.com/onlinerace">https://my.rouvy.com/onlinerace</a>
to create your race.

Rouvy races are identified by the final number in the URL for the race
registration page.
Once you have created the race, please check the URL of its
registration page and enter the race ID below.
<br>
<br>
<b>Example:</b>
<br>
<br>
If your race registration page is
<br><br>
  <code>https://my.rouvy.com/onlinerace/detail/87800</code>
  <br><br>
    please enter
    <br><br>
      87800
    <br><br>
<br>
<br>
<hr>
<br>
<br>

<h1>Sorry, the ability to upload user-generated races is currently disabled; it'll return when Rouvy have completed the rewrite of their 
webpages.</h1>
<br>
<br>

<!--
<form action="input_user_contributed_race_form_part2.php" method="post">
  Please enter the race ID: <input style="display:block;" type="text" name="newly_contributed_race_url_number">
  <br>
  <br>
  <input style="display:block;" type="submit" name="submit" value="Submit">  
</form>
-->

<br>
<br>
<b>NOTE: Please do not delete the race on rouvy once it has been registered here!</b>



</body>
</html>

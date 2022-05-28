
<!DOCTYPE HTML>  
<html>
<head>
<style>
.error {color: #FF0000;}
</style>
</head>
<body>
  
<?php
 
 $newly_contributed_race_url_number=$_POST["newly_contributed_race_url_number"];
 if (!preg_match('/^[0-9]*$/',$newly_contributed_race_url_number)) 
 {
 print "ERROR: Only numbers allowed; please return to the previous
 page, using your browser's \"Back\" button."; 
 }
 elseif (""==$newly_contributed_race_url_number)
 {
 print "ERROR: Please enter a number; please return to the previous page, using your browser's \"Back\" button."; 
 }
 else
 {
 print "<h2>Thank you</h2>";
 print "Please check if this link leads you to the correct race page (page will open in a new browser/tab):";
 $newly_contributed_race_url="https://my.rouvy.com/onlinerace/detail/".$newly_contributed_race_url_number;
 
 // Remember the race url for next script
session_start();
$_SESSION['newly_contributed_race_url'] = $newly_contributed_race_url;
print "<br><br><center><a href=\"".$newly_contributed_race_url."\" target=\"_blank\">".$newly_contributed_race_url."</a></center><br><br>";
print "Once checked, please click here to confirm <br><br>";
print "<center><a href=\"input_user_contributed_race_form_part3.php\">CONFIRM_IMAGE</a></center><br><br>";
}
?>

</body>
</html>

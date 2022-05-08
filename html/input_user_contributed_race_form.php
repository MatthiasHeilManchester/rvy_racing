
<!DOCTYPE HTML>  
<html>
<head>
<style>
.error {color: #FF0000;}
</style>
</head>
<body>  

<?php


// hierher
// define variables and set to empty values
// $race_url_number=0;

$race_url_number_is_valid=true;
if ($_SERVER["REQUEST_METHOD"] == "POST") {

  if (empty($_POST["race_url_number"]))
  {
   $race_url_number_Err = "Race url number is required";
   $race_url_number_is_valid=false;
  }
  else 
  {
  $race_url_number = test_input($_POST["race_url_number"]);
  // check if race_url_number only contains numbers
  if (!preg_match('/^[0-9]*$/',$race_url_number)) 
  {
  $race_url_number_Err = "Only numbers allowed"; 
  $race_url_number_is_valid=false;
  }
  }
  
}

function test_input($data) {
  $data = trim($data);
  $data = stripslashes($data);
  $data = htmlspecialchars($data);
  return $data;
}
?>

<h2>User contributed races</h2>
Rouvy races are identified by the final number in the URL for the race
registration page.
<br>
<br>
Once you have created the race, please check the URL of its
registration page and enter the race ID below.
<br>
<br>
<b>Example:</b>
<br>
<br>
If your race registration page is
<code>https://my.rouvy.com/onlinerace/detail/87800</code>, please
enter 87800.

<br>
<br>
<hr>
<br>
<br>




<form action="input_user_contributed_race_form_part2.php" method="post">
  Please enter the race ID: <input type="text" name="race_url_number">
  <br>
  <br>
  <input type="submit" name="submit" value="Submit">  
</form>





</body>
</html>

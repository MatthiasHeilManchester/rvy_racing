<!DOCTYPE HTML>  
<html>
<head>
<style>
.error {color: #FF0000;}
</style>
</head>
<body>  





<!-- ========================================== -->
<!-- The actual form in html-->
<!-- ==========================================-->
<h2>Register new official races menu</h2>
<form method="post" action="process_register_new_race.php" id="register_race_form">
  <br><br>
  <ul>
  <li>Race number (within season; two per week) <br> <input type="number" name="race_number"></li>
  <br>
  <li>Race URLs:<br><textarea rows="4" cols="50" name="urls_from_text_area" form="register_race_form"></textarea></li>
  </ul>
  <br>
  <input type="submit" name="submit_name" value="Submit">
</form>
<!-- ========================================== -->
<!-- End of form in html-->
<!-- ==========================================-->




</body>
</html>


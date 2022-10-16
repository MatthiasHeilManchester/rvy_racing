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
<h2>Upload user list in csv format (from phpBB)</h2>
<form method="post" action="process_upload_user_list.php" id="upload_user_list_form">
  <br><br>
  <ul>
  <br>
    <li>User list (make sure you include the title/caption line!):<br><textarea rows="50" cols="160" name="user_list_from_text_area" form="upload_user_list_form"></textarea></li>
  </ul>
  <br>
  <input type="submit" name="submit_name" value="Submit">
</form>
<!-- ========================================== -->
<!-- End of form in html-->
<!-- ==========================================-->




</body>
</html>


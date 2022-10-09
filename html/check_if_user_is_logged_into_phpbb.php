<!DOCTYPE HTML>  
<html>
<head>
<style>
.error {color: #FF0000;}
</style>
</head>
<body>  



<?php


 //===============================================================
 // Function to assess if general user user is logged into phpbb
  //===============================================================
 function logged_into_phpbb() : bool
 {
  define('IN_PHPBB', true);
 
  // path to phpbb
  //$phpbb_root_path = './forum/';
  
  // Pi:
  //$phpbb_root_path = '/var/www/html';
  
  // godaddy:
  $phpbb_root_path = '/home/jcx8vb3xd9vs/public_html/phpbb/';

  echo "Hello ".$phpbb_root_path;
  
  $phpEx = substr(strrchr(__FILE__, '.'), 1);
  include($phpbb_root_path . 'common.' . $phpEx);
  
  // Start session management
  $user->session_begin();
  $auth->acl($user->data);
  $user->setup();

  echo "Hello2 ".$user;

  // Initialise
  $user_is_logged_in=false;

  // hierher $admin_is_logged_in=0;
  if($user->data['is_registered'])
   { 
    $user_is_logged_in=true;
    
    $username=$user->data['username'];
    echo "User is logged in as ".$username;

    // hierher
    // if ( $username == "matthias")
    // {	    
      // temporarily enable superglobals (hierher don't understand)
      //$request->enable_super_globals();
      //$admin_is_logged_in=1;
   //  }

   }
   return $user_is_logged_in;
 }

//========================================================================

echo "Checking if user is logged in....";
$logged_in=logged_into_phpbb();
if ($logged_in)
{
echo "You are logged in";
}
else
{
echo "You are not logged in";
}

// hierher kill
$admin_is_logged_in=1;

if ( $admin_is_logged_in == 1 ){

  ?>

<!-- ========================================== -->
<!-- The actual form in html-->
<!-- ==========================================-->
<h2>Admin menu</h2>
<form method="post" action="process_admin.php">
  <br><br>
  <input type="radio" name="Action" value="register">Register races
  <br>
  <input type="radio" name="Action" value="stage">Stage races
  <br>
  <input type="radio" name="Action" value="process">Process races
  <br>
  <input type="submit" name="submit_name" value="Submit">
</form>
<!-- ========================================== -->
<!-- End of form in html-->
<!-- ==========================================-->



<?php
   
 } 
# Not logged in yet, so go to phpbb login page
else {
// hierher update url to actual one
echo "Please log into phpBB as admin, then reload the page.";
echo "<br><br><a href=\"http://192.168.0.67/index.php\" target=\"_blank\">Link to phpBB (will open in new window)</a>";
  }
    
   ?>





</body>
</html>


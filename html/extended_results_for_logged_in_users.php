<!DOCTYPE HTML>  
<html>
<head>
<style>
.error {color: #FF0000;}
</style>
</head>
<body>  




<?php

//===============================================
// Login check
//===============================================
define('IN_PHPBB', true);

// path to phpbb
//$phpbb_root_path = './forum/';

// Pi:
$phpbb_root_path = '/var/www/html/';

// godaddy:
$phpbb_root_path = '/home/jcx8vb3xd9vs/public_html/phpbb/';

$phpEx = substr(strrchr(__FILE__, '.'), 1);
include($phpbb_root_path . 'common.' . $phpEx);

// Start session management
$user->session_begin();
$auth->acl($user->data);
$user->setup();

$user_is_logged_in=0;

if($user->data['is_registered'])
 {
$username=$user->data['username'];
$user_is_logged_in=1;
echo "<br>Logged in as: ".$username."<br>";
}


if ( $user_is_logged_in == 1 ){

echo "User is logged in!";

  ?>

<!-- ========================================== -->
<!-- include results file-->
<!-- ==========================================-->
<h2>Extended results file</h2>



<?php
   
 } 
# Not logged in yet, so go to phpbb login page
else {
echo "Please log into phpBB, then reload the page.";
echo "<br><br><a href=\"https://www.matthias-heil.co.uk/phpbb/\" target=\"_blank\">Link to phpBB (will open in new window)</a>";
  }
    
   ?>





</body>
</html>


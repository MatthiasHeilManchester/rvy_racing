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
//error_reporting(E_ALL & ~E_NOTICE);
//ini_set("display_errors", 1);
//ini_set("log_errors", 0);


//==============================================
// Here's the form code for specifying new races
//==============================================

// define variables and set to empty values
$nraceErr = $urlsErr = "";
$nrace = $urls = "";

// hierher
if ($_SERVER["REQUEST_METHOD"] == "POST")
{

  if (empty($_POST["nrace"]))
   {
    $nraceErr="Number of races is required!";
   }
  else
   {
    // Read out number of races
    $nrace = test_input($_POST["nrace"]);
     
    // check if nrace contains only numbers
    if (!is_numeric($nrace))
     {
      $nraceErr = "Only numbers allowed; no letters or whitespace!";
     }
   }

  // What are the urls? (hierher make this required)
  if (empty($_POST["urls"]))
    {
     $urls_err = "";
    }
  else
    {
     // Read it out
     $urls = test_input($_POST["urls"]);
    }


  // Reset?
  if (empty($_POST["reset"]))
   {
    //echo "not resetting";
   }
  else
   {  
    $urls="";
    $nrace="";
   }
    
  }

// Strip out stuff we don't want from string
function test_input($data)
{
  // Remove leading/trailing whitespace
  $data = trim($data);

  // hierher
  $data = stripslashes($data);
  $data = htmlspecialchars($data);
  return $data;
}


?>





<?php

//===============================================
// Login check from hierher url
//===============================================
define('IN_PHPBB', true);

// hierher update path to phpbb (install on pi
// as on actual server)
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

$admin_is_logged_in=0;

if($user->data['is_registered'])
 {
  $username=$user->data['username'];
  if ( $username == "matthias")
  {
	    
   // temporarily enable superglobals (hierher don't understand)
   $request->enable_super_globals();

   $admin_is_logged_in=1;

  }
}

if ( $admin_is_logged_in == 1 ){

  ?>

<!-- ========================================== -->
<!-- The actual form in html hierher: add race series and check that directory exists-->
<!-- ==========================================-->
<h2>Admin menu</h2>
<p><span class="error">* required field</span></p>
<!-- hierher what does the action php_self do? -->
<form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]);?>">
  <!-- not how the default value is the previously saved one! -->
  Number of races: <input type="text" name="nrace" value="<?php echo $nrace;?>">
  <span class="error">* <?php echo $nraceErr;?></span>
  <br><br>
  Race URLs (one per line): <textarea name="urls" rows="5" cols="60" valign="middle"><?php echo $urls;?></textarea>
  <br><br>
  <input type="submit" name="submit" value="Submit">
  <br><br>
  <input type="submit" name="reset" value="Reset">
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




<?php

//===============================================
// Check if the form has been completed properly
//===============================================
if ( $nrace!="")
{

// Extract individual urls (seperated by lines)
$url_array=explode("\n",$urls);
$n_url=count($url_array);


// Do we have the right number?
if ( $n_url == $nrace )
{
// spawn system command to create new race
echo "Number of urls (".$n_url.") matches expected number (".$nrace.")<br>";
for ($i = 0; $i < $nrace; $i++)
		   {
		   echo "Race URL: ".$i." ".str_replace(' ', '',$url_array[$i])."<br>";
							  }
}
else
{
 // hierher elaborate/show
		  echo "Number of race urls provided (".$n_url.
		  ") doesn't match expected number (".$nrace.")";
}

}
?>



</body>
</html>


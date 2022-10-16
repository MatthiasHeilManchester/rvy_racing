<?php



$user_list=$_POST['user_list_from_text_area'];
//echo "user_list: ".$user_list."<br>";


// Extract individual users (seperated by lines)
$user_array=explode("\n",$user_list);
$n_user=count($user_array);


// Create unique filename
$filename = tempnam('', '');

// Open file
$fp = fopen($filename, 'w');



// Note that we've read in the caption (but output that too for check)
echo "Number of users:".($n_user-1)."<br>";
for ($i = 0; $i < $n_user; $i++)
{
if ( !empty($user_array[$i]) )
{
 fwrite($fp, $user_array[$i]."\n");
}
}

// Close file
fclose($fp);


echo "<pre>";

$command="cat ".$filename;
system($command);


$file_to_be_created="../master_race_data/rvy_racing/user_data.csv";


if ( file_exists( $file_to_be_created ) )
{
 $my_date=date("Y-m-d-h:i:s");
 while (true)
 {
  $backup_filename = uniqid($file_to_be_created."_backup".$my_date."_", true);
  if (!file_exists($backup_filename)) break;
 }
 echo "Backup file name: <br><br>".$backup_filename."<br><br>is unique<br><br>";
 $backup_command = "mv ".$file_to_be_created." ".$backup_filename;
 echo "<br><br>Backup command:<br><br>".$backup_command."<br><br>";
 system($backup_command);
 echo("...done"); 
}

$command = "mv ".$filename." ".$file_to_be_created;
echo "<br><br>Command:<br><br>  ".$command."<br><br>";
system($command);
echo("...done");

// Now it's gone!
unlink($filename);

$command = "cd ../master_race_data/rvy_racing/ ; ../../bin/user_csv_to_txt_and_sed.bash user_data.csv";
echo "<br><br>Command:<br><br>  ".$command."<br><br>";
system($command);
echo("...done");

echo "</pre>";


?>

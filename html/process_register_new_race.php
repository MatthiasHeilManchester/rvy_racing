<?php


$race_number=$_POST['race_number'];
$url_list=$_POST['urls_from_text_area'];

//echo "race_number: ".$race_number."<br>";
//echo "url_list2: ".$url_list."<br>";


// Extract individual urls (seperated by lines)
$url_array=explode("\n",$url_list);
$n_url=count($url_array);


// Create unique filename
$filename = tempnam('', '');

// Open file
$fp = fopen($filename, 'w');



//echo "Number of urls:".$n_url."<br>";
for ($i = 0; $i < $n_url; $i++)
{
if ( !empty($url_array[$i]) )
{
 $the_url=trim(str_replace(' ','',$url_array[$i]));
 echo "Race URL: ".$i." --".$the_url."--<br>";
 if (filter_var($the_url, FILTER_VALIDATE_URL) === FALSE)
  {
   die('URL not valid; bailing.');
  }
 fwrite($fp, $the_url."\n");
}
}

// Close file
fclose($fp);


echo "<pre>";

//$command="cat ".$filename;
//system($command);

$dir_to_be_created="../master_race_data/rvy_racing/race".sprintf('%05d', $race_number);
$dir_prev="../master_race_data/rvy_racing/race".sprintf('%05d', ($race_number-1));

echo "Dir to be created: ".$dir_to_be_created."<br>";
echo "Previous dir     : ".$dir_prev."<br>";
if ( file_exists( $dir_to_be_created ) )
{
  echo "Supposed to be created new race directory <br><br>    ".$dir_to_be_created."<br><br>already exists. Check the race number specified on the form!</br>";
  die("Bailing");
}
else
{
  echo "Supposed to be created new race directory <br><br>    ".$dir_to_be_created."<br><br>doesn't exist yet. Race number specified on the form is ok! Yay!</br>";
}


if ( !file_exists( $dir_prev ) )
{
  echo "Supposed to be created new race directory <br><br>    ".$dir_to_be_created."<br><br>is not preceeded by an existing previous directory<br><br>    ".$dir_prev."<br><br>. Check the race number specified on the form!</br>";
  die("Bailing");
}
else
{
  echo "Supposed to be created new race directory <br><br>    ".$dir_to_be_created."<br><br>is preceeded by an existing previous directory<br><br>    ".$dir_prev."<br><br>Race number specified on the form is ok! Yay!</br>";
}
echo "</pre>";

// die("Bailing for now");

$command="cd ../master_race_data/rvy_racing/; ../../bin/create_next_race.bash ".$filename;
echo "Command: ".$command."<br>";
system($command);
//system("pwd");
$command="cd ..; bin/bolshy_stage_races.bash rvy_racing";
system($command);
echo "</pre>";


// Now it's gone!
unlink($filename);

echo "<br><hr><br>";
echo "<h1><a href=\"https://www.matthias-heil.co.uk/rvy_racing\">Back to race page</a></h1>";
?>

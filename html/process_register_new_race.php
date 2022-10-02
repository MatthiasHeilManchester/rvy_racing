<?php


$race_number=$_POST['race_number'];
$url_list=$_POST['urls_from_text_area'];

echo "race_number: ".$race_number."<br>";
echo "url_list2: ".$url_list."<br>";


// Extract individual urls (seperated by lines)
$url_array=explode("\n",$url_list);
$n_url=count($url_array);


// Create unique filename
$filename = tempnam('', '');

// Open file
$fp = fopen($filename, 'w');



echo "Number of urls:".$n_url."<br>";
for ($i = 0; $i < $n_url; $i++)
{
if ( !empty($url_array[$i]) )
{
 $the_url=str_replace(' ', '',$url_array[$i]);
 echo "Race URL: ".$i." --".$the_url."--<br>";
 fwrite($fp, $the_url);
}
}

// Close file
fclose($fp);


echo "<pre>";
$command="cat ".$filename;
echo "Command: ".$command."<br>";
system($command);
echo "</pre>";


// Now it's gone!
unlink($filename);

echo "<br><hr><br>";
echo "<h1><a href=\"https://www.matthias-heil.co.uk/rvy_racing\">Back to race page</a></h1>";
?>

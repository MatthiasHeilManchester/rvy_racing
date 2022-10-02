<?php

if (isset($_POST['Action']))
{
 if ($_POST['Action']=="process")
  {
  echo "about to process";
  echo "<pre>";
  system("cd .. ; bin/bolshy_process_races.bash rvy_racing");
  echo "</pre>";
  }
  elseif ($_POST['Action']=="stage")
  {
  echo "about to stage";
  echo "<pre>";
  system("cd .. ; bin/bolshy_stage_races.bash rvy_racing");
  echo "</pre>";       
  }
  else
  {
  echo "Error: Action \"".$_POST['Action']."\" not recognised.";
  }
}
else
{
echo "do nothing";
}

echo "<br><hr><br>";
echo "<h1><a href=\"https://www.matthias-heil.co.uk/rvy_racing\">Back to race page</a></h1>";
?>

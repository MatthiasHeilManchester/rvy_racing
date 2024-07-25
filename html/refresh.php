<?php
$race_number = $_GET['race_number'];
$existing = isset($_GET['existing']) ? 'TRUE' : 'FALSE';

// let's not accept arbitrary data
if (preg_match("/^([0-9]{1,3})$/", $race_number)) {
    $command = escapeshellcmd("/usr/local/bin/python3.9 include_user_event.py " . $race_number . " " . $existing);
    chdir("../python_processing");
    $result =  shell_exec($command);
    // TODO: check for issues
    echo "Refresh complete";
} else {
    echo "Failed to refresh tasks";
}

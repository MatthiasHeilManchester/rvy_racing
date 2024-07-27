<?php
$race_number = $_GET['race_number'];
$existing = isset($_GET['existing']) ? 'TRUE' : 'FALSE';

// let's not accept arbitrary data
if (preg_match("/^([0-9]{1,3})$/", $race_number)) {
    // Use local python if it exists
    $filename = '~/.local/bin/python3';
    if (!file_exists($filename)) {
        $filename = "/usr/local/bin/python3.9";
    }
    if (!file_exists($filename)) {
        error_log("python binary could not be found!", 0);
    }

    // get to the depth we need to be
    for ($i = 1; $i <= 6; $i++) {
        if (file_exists("../python_processing")) {
            break;
        }
        chdir("..");
    }

    if (!file_exists("../python_processing")) {
        error_log("python_processing folder could not be found!", 0);
    }

    $command = escapeshellcmd($filename . " include_user_event.py " . $race_number . " " . $existing);
    chdir("../python_processing");
    $result =  shell_exec($command);
    // TODO: check for issues
    echo "Refresh complete";
} else {
    echo "Failed to refresh tasks";
}

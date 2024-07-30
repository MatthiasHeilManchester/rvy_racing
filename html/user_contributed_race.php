<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Rvy Racing</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="js/script.js"></script>
    <script src="js/jquery-3.7.1.min.js"></script>
</head>
<body>

<?php
// GET REQUIRED RACE DATA FROM URL: THIS IS THE DATA FOR THE OFFICIAL RACE!
$route_id = $_GET['route_id'];
$route_title = $_GET['route_title'];
$race_series = $_GET['race_series'];
$race_number = $_GET['race_number'];
$race_laps = $_GET['race_laps'];
$race_date_string = $_GET['race_date_string'];
$scroll = isset($_GET['scroll']) ? $_GET['scroll'] : '0';
?>

<h2>User contributed race instructions</h2>
<br>
To create a user contributed race for <b>Race <?php echo $race_number ?></b> in
the race series <b><?php echo $race_series ?></b>

<ul>
    <li>Use this link <a href="https://riders.rouvy.com/events/setup?route=<?php echo $route_id ?>" target="_blank">
            Create Race (opens in new tab)</a> to create the race as it will already have the required route
        <b><?php echo $route_title ?></b> selected.
        </li>
    <li>Set event type to Race</li>
    <li>Make sure the race name contains the string "rvy_racing" otherwise it won't get picked up by our clever scripts. </li>
    <li> The race must be held on <?php echo $race_date_string ?> (GMT).<br>Locally this will be some time between:
        <ul>
            <script type="text/javascript">
                const [local_from, local_to] = utc_date_str_to_local('<?php echo $race_date_string ?>')
                document.write('<li> ' + local_from + '</li>');
                document.write('<li> ' + local_to + '</li>');
            </script>
        </ul>
    </li>
    <li>From advanced options choose:
        <ul>
            <li>
                Smart trainers only
            </li>
            <?php if ($race_laps != '1'){
                echo "<li>Multiple laps and enter <b>" . $race_laps . "</b> laps</li>";
            }  ?>
        </ul>
    </li>

</ul>
<br>
<br>


If you have now created a new race, click <button style="margin-left:0" class="select_league_table_buttons" type="button" id="ajax_refresh">Schedule Refresh</button>

<script>
    $('#ajax_refresh').on('click', function () {
        let btn = $('#ajax_refresh')
        btn.attr("disabled", true)
        btn.html("Refreshing....");
        $.ajax({
            url: "refresh.php?race_number=<?php echo $race_number ?>",
            type: "POST", //request type
            success: function (result) {
                window.location.href = "rvy_racing.php?RacesTab=<?php echo $scroll ?>";
            },
            complete: function () {
                $('#ajax_refresh').attr("disabled", false);
            }
        });
    });
</script>
give it about 30 seconds, and you will be returned to the races page.

<br>
<br>
<br>
<b>NOTE: Please do not delete the race on rouvy once it has been registered here!</b>

</body>
</html>

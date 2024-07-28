
<!doctype html>
<html lang=en>
<head>
<meta charset=utf-8>
<title>sort table</title>
</head>


<style>
table {
  border-spacing: 0;
  width: 100%;
  border: 1px solid #ddd;
}

#th {
#    #cursor: ns-resize;
#    cursor: url(images/click-to-sort_thumbnail.png), nw-resize;
#}

.th_sortable {
    #cursor: ns-resize;
    cursor: url(images/click-to-sort_thumbnail.png), nw-resize;
}

td {
  text-align: left;
  padding: 16px;
}

th {
  text-align: left;
  padding: 16px;
  background-color: yellow;
}

tr:nth-child(even) {
  background-color: #f2f2f2
}

.select_league_table_buttons {
  display: inline-block;
  padding: 5px 10px;
  cursor: pointer;
  text-align: center;
  text-decoration: none;
  outline: none;
  color: black;
  background-color: yellow;
  border: none;
  border-radius: 15px;
  box-shadow: 0 2px #999;
}

.row_of_league_table_buttons {
  white-space:nowrap;
  }

#.select_league_table_buttons : button {
#  white-space:nowrap;
#}

</style>


<body>

<img src="images/click-to-sort_thumbnail.png">
<br>

<span class="row_of_league_table_buttons">
<button id="full_league_table_button" class="select_league_table_buttons" onclick="show_league_table(1)">Full league table</button>
<button id="wed_league_table_button"  class="select_league_table_buttons" style="background-color:lightyellow;" onclick="show_league_table(2)">League table from Wednesday races only</button>
<button id="sat_league_table_button"  class="select_league_table_buttons" style="background-color:lightyellow;" onclick="show_league_table(3)">League table from Saturday races only</button>
</span>

<table id="myTable" style="display:block;">
  <tr>
   <!--When a header is clicked, run the sortTable function, with a parameter, 0 for sorting by names, 1 for sorting by country:-->  
   <th>Rank (main) (by points)</th>
   <th>Rank (by points/race)</th>
   <th>Username</th>
   <th class="th_sortable" onclick="sort_column_in_table(this,3)">Points</th>
   <th class="th_sortable" onclick="sort_column_in_table(this,4)">Points/race</th>
  </tr>
  <tr>
    <td>1</td>
    <td>2</td>
    <td>Bla</td>
    <td>43</td>
    <td>14.3</td>
  </tr>
  <tr>
    <td>2</td>
    <td>1</td>
    <td>bla2</td>
    <td>34</td>
    <td>15.4</td>
  </tr>
  <tr>
    <td>2=</td>
    <td>3</td>
    <td>bla3</td>
    <td>34</td>
    <td>2.4</td>
  </tr>
  <tr>
    <td>3</td>
    <td>3=</td>
    <td>bla4</td>
    <td>24</td>
    <td>2.4</td>
  </tr>
</table>







<table id="myTable2" style="display:none;">
  <tr>
   <!--When a header is clicked, run the sortTable function, with a parameter, 0 for sorting by names, 1 for sorting by country:-->  
   <th id="bla" class="th_sortable" onclick="myFunction()">Rank (wed) (by points)</th>
   <th class="th_sortable" >Rank (by points/race)</th>
   <th class="th_sortable" >Username</th>
   <th class="th_sortable" onclick="sort_column_in_table(this,3)">Points</th>
   <th class="th_sortable" onclick="sort_column_in_table(this,4)">Points/race</th>
  </tr>
  <tr>
    <td>1</td>
    <td>2</td>
    <td>Bla</td>
    <td>43</td>
    <td>14.3</td>
  </tr>
  <tr>
    <td>2</td>
    <td>1</td>
    <td>bla2</td>
    <td>34</td>
    <td>15.4</td>
  </tr>
  <tr>
    <td>2=</td>
    <td>3</td>
    <td>bla3</td>
    <td>34</td>
    <td>2.4</td>
  </tr>
  <tr>
    <td>3</td>
    <td>3=</td>
    <td>bla4</td>
    <td>24</td>
    <td>2.4</td>
  </tr>
</table>




<table id="myTable3" style="display:none;">
  <tr>
   <!--When a header is clicked, run the sortTable function, with a parameter, 0 for sorting by names, 1 for sorting by country:-->  
   <th>Rank (by points) (sat)</th>
   <th>Rank (by points/race)</th>
   <th>Username</th>
   <th class="th_sortable" onclick="sort_column_in_table(this,3)">Points</th>
   <th class="th_sortable" onclick="sort_column_in_table(this,4)">Points/race</th>
  </tr>
  <tr>
    <td>1</td>
    <td>2</td>
    <td>Bla</td>
    <td>43</td>
    <td>14.3</td>
  </tr>
  <tr>
    <td>2</td>
    <td>1</td>
    <td>bla2</td>
    <td>34</td>
    <td>15.4</td>
  </tr>
  <tr>
    <td>2=</td>
    <td>3</td>
    <td>bla3</td>
    <td>34</td>
    <td>2.4</td>
  </tr>
  <tr>
    <td>3</td>
    <td>3=</td>
    <td>bla4</td>
    <td>24</td>
    <td>2.4</td>
  </tr>
</table>






















<script>


// Function to make full (1), wed-only (2) or sat-only (3) league
// table visible
function show_league_table(i_table) {

switch(i_table) {
  case 1:
    document.getElementById("myTable").style.display = "block";
    document.getElementById("myTable2").style.display = "none";
    document.getElementById("myTable3").style.display = "none";
    document.getElementById("full_league_table_button").style.background = "yellow";
    document.getElementById("wed_league_table_button").style.background = "lightyellow";
    document.getElementById("sat_league_table_button").style.background = "lightyellow";
    break;
  case 2:
    // code block
    document.getElementById("myTable").style.display = "none";
    document.getElementById("myTable2").style.display = "block";
    document.getElementById("myTable3").style.display = "none";
    document.getElementById("full_league_table_button").style.background = "lightyellow";
    document.getElementById("wed_league_table_button").style.background = "yellow";
    document.getElementById("sat_league_table_button").style.background = "lightyellow";
    break;
  case 3:
    document.getElementById("myTable").style.display = "none";
    document.getElementById("myTable2").style.display = "none";
    document.getElementById("myTable3").style.display = "block";
    document.getElementById("full_league_table_button").style.background = "lightyellow";
    document.getElementById("wed_league_table_button").style.background = "lightyellow";
    document.getElementById("sat_league_table_button").style.background = "yellow";
    break;
  default:
    // code block
}
 

}


// Specify table column header that this is called from
// (clicking on "this" object calls this function; we retrieve the
// enclosing table by going up the dom hierarchy...
// Sort entries in the n-th column
function sort_column_in_table(th,n) {
  var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
  // oldtable = document.getElementById("myTable");
  table = th.parentNode.parentNode;
  var header_row=table.getElementsByTagName("th");
  console.log(header_row);
  for (i = 0; i < (header_row.length); i++) {
  header_row[i].style.backgroundColor='yellow';
  }
  th.style.backgroundColor='lightyellow';
  switching = true;
  //Set the sorting direction to ascending:
  dir = "asc"; 
  /*Make a loop that will continue until
  no switching has been done:*/
  while (switching) {
    //start by saying: no switching is done:
    switching = false;
    rows = table.rows;
    /*Loop through all table rows (except the
    first, which contains table headers):*/
    for (i = 1; i < (rows.length - 1); i++) {
      //start by saying there should be no switching:
      shouldSwitch = false;
      /*Get the two elements you want to compare,
      one from current row and one from the next:*/
      x = rows[i].getElementsByTagName("TD")[n];
      y = rows[i + 1].getElementsByTagName("TD")[n];
      /*check if the two rows should switch place,
      based on the direction, asc or desc:*/
      if (dir == "asc") {
        if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
          //if so, mark as a switch and break the loop:
          shouldSwitch= true;
          break;
        }
      } else if (dir == "desc") {
        if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
          //if so, mark as a switch and break the loop:
          shouldSwitch = true;
          break;
        }
      }
    }
    if (shouldSwitch) {
      /*If a switch has been marked, make the switch
      and mark that a switch has been done:*/
      rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
      switching = true;
      //Each time a switch is done, increase this count by 1:
      switchcount ++;      
    } /* else {
      /*If no switching has been done AND the direction is "asc",
      set the direction to "desc" and run the while loop again.*/
      if (switchcount == 0 && dir == "asc") {
        dir = "desc";
        switching = true;
      } */
    }
  }
}


// Original version
function sortTable(n) {
  var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
  table = document.getElementById("myTable");
  switching = true;
  //Set the sorting direction to ascending:
  dir = "asc"; 
  /*Make a loop that will continue until
  no switching has been done:*/
  while (switching) {
    //start by saying: no switching is done:
    switching = false;
    rows = table.rows;
    /*Loop through all table rows (except the
    first, which contains table headers):*/
    for (i = 1; i < (rows.length - 1); i++) {
      //start by saying there should be no switching:
      shouldSwitch = false;
      /*Get the two elements you want to compare,
      one from current row and one from the next:*/
      x = rows[i].getElementsByTagName("TD")[n];
      y = rows[i + 1].getElementsByTagName("TD")[n];
      /*check if the two rows should switch place,
      based on the direction, asc or desc:*/
      if (dir == "asc") {
        if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
          //if so, mark as a switch and break the loop:
          shouldSwitch= true;
          break;
        }
      } else if (dir == "desc") {
        if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
          //if so, mark as a switch and break the loop:
          shouldSwitch = true;
          break;
        }
      }
    }
    if (shouldSwitch) {
      /*If a switch has been marked, make the switch
      and mark that a switch has been done:*/
      rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
      switching = true;
      //Each time a switch is done, increase this count by 1:
      switchcount ++;      
    } else {
      /*If no switching has been done AND the direction is "asc",
      set the direction to "desc" and run the while loop again.*/
      if (switchcount == 0 && dir == "asc") {
        dir = "desc";
        switching = true;
      }
    }
  }
}



function myFunction() {
  document.getElementById("bla").innerHTML = "YOU CLICKED ME!";
}

function find_parent(node) {
  node.parentNode.parentNode.innerHTML = "YOU bastard!";
}



</script>


  
  
</body>
</html>

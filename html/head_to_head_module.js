
//------------------------------------------------
// js module for processing of head to head stuff
//------------------------------------------------



// Read the file containing the active users when the page is built.
// Needed for drop-down menu in head-to-head comparison
import active_users from "./head_to_head_active_users.js";

var user_list=JSON.parse(active_users)["user_list"];
var n_user=user_list.length;
console.log("n_user",n_user);
for (var i=0; i<n_user; i++) {
    var element = document.getElementById('user1_drop_down');
    element.options[element.length] = new Option(user_list[i]["name"],user_list[i]["name"]);	 
    element = document.getElementById('user2_drop_down');
    element.options[element.length] = new Option(user_list[i]["name"],user_list[i]["name"]);
}

  


// Now read in the head to head results
import race_results from "./head_to_head_race_results.js";
//console.log("race_results ",race_results);



// Function to evaluate the head-to-head evaluation on the league table;
// argument points to the form via which the user selects the two racers
// Pass pointer to form this all lives in
export function evaluate_head_to_head(form){
    
    // Get the two racers from the form
    var user1=form.user1_drop_down.value;
    var user2=form.user2_drop_down.value;

    // hierher move this outside
    var race_data=JSON.parse(race_results)["race_list"];
    
    // loop over the races
    var n_races=race_data.length;
    var user1_wins=0;
    var user2_wins=0;
    var n_draw=0;
    var n_joint_races=0;
    var n_races=race_data.length;
    for (var i=0; i<n_races; i++) {
	var n_racers=race_data[i]["results"].length;
	var user1_points=-1;
	var user2_points=-1;
	var n_found=0;
	for (var j=0;j<n_racers;j++){
	    if (race_data[i]["results"][j]["rouvy_username"] == user1){
		user1_points=race_data[i]["results"][j]["points"];
		n_found++;
	    }
	    if (race_data[i]["results"][j]["rouvy_username"] == user2){
		user2_points=race_data[i]["results"][j]["points"];
		n_found++;
	    }
	    if (n_found == 2){
		break;
	    }
	}
	if ( (user1_points >= 0) && (user2_points >= 0) ){
	    n_joint_races++;
	    if (user1_points > user2_points){
		user1_wins++;
	    }
	    if (user1_points < user2_points){
		user2_wins++;
	    }
	    if (user1_points == user2_points){
		n_draw++;
	    }		      
	}
    }
    
    // Assemble result for display
    var result='<div style="padding:1vw;"><table style="border:0px;border-collapse:collapse;padding:0px;"><tr><td style="border:0px;border-collapse:collapse;padding:0px;"><span class="head_to_head_result_user">'+user1+"</span></td> "+
	'<td style="border:0px;border-collapse:collapse;padding:0px;"><span class="head_to_head_result_wins">'+user1_wins+"</span></td>"+
	'<td style="border:0px;border-collapse:collapse;padding:0px;"><span class="head_to_head_result_colon">:</span></td>'+
	'<td style="border:0px;border-collapse:collapse;padding:0px;"><span class="head_to_head_result_wins">'+user2_wins+"</span></td>"+
	'<td style="border:0px;border-collapse:collapse;padding:0px;"><span class="head_to_head_result_user">'+user2+"</span> </div></td></tr>"+
	'<tr><td colspan="5" style="border:0px;border-collapse:collapse;padding:20px;"><center><span class="head_to_head_result_sub_info">('+n_draw+" draws; "+n_joint_races+" joint races)</span></center></td><tr></table>";
    
    // ...and display it
    document.getElementById("head_to_head_outcome").innerHTML=result;
    
    // toggle to displaying results
    choose_display_head_to_head('result');
}

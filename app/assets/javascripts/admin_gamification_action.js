(function() {
  "use strict";

	var get_operations = function () {
		// second dropdown is disable while first dropdown is empty
		if($("#gamification_action_process_type").val() == ''){
			$("#gamification_action_operation").prop("disabled", true);
		}

		$("#gamification_action_process_type").change(function(){
		  	var process_type = $(this).val();
		  	if(process_type == ''){
		  		$("#gamification_action_operation").prop("disabled", true);
		  	}else{
		  		$("#gamification_action_operation").prop("disabled", false);
		  	}
		  	$.ajax({
			    url: "/admin/gamification/update_operations",
			    method: "GET",  
			    dataType: "json",
			    data: {process_type: process_type},
			    error: function (xhr, status, error) {
			      	console.error('AJAX Error: ' + status + error);
			    },
			    success: function (response) {
			      	console.log(response);
			      	var operations = response["operations"];
			      	$("#gamification_action_operation").empty();

			      	$("#gamification_action_operation").append('<option value="">...</option>');
			      	for(var i = 0; i < operations.length; i++){
			      		$("#gamification_action_operation").append('<option value="' + operations[i][1] + '">' +operations[i][0] + '</option>');
			      	}
			    }
		  	});
		});
	}

	$(document).ready(get_operations);
	$(document).on('page:load', get_operations);
})();
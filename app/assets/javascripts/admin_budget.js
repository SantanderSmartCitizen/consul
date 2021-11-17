(function() {
  "use strict";

	var show_hide_max_votes = function () {
		var voting_system = $("#budget_voting_system").val();
		if(voting_system == 'wallet'){
			$("#budget_max_votes").parent().hide();
			$("#budget_max_votes").val('');
		}
		else {
			$("#budget_max_votes").parent().show();
		}

		$("#budget_voting_system").change(function(){
		  	var voting_system = $(this).val();
		  	if(voting_system == 'wallet'){
				$("#budget_max_votes").parent().hide();
				$("#budget_max_votes").val('');
			}
			else {
				$("#budget_max_votes").parent().show();
			}
		});
	}

	$(document).ready(show_hide_max_votes);
	$(document).on('page:load', show_hide_max_votes);
})();
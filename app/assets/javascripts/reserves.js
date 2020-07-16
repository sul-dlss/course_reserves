// Things that need to document to be loaded to do.
$(document).ready(function(){

	// Add item from SW
	$(".add-sw-item").click(function(){
		if($("#sw_url").val() != ""){
			var already_exists = false;
			$("a").each(function(){
				if($(this).attr("href") == $("#sw_url").val() || $(this).attr("href") == "http://searchworks.stanford.edu/view/" + $("#sw_url").val()){
					already_exists = true;
				}
			});
			if(already_exists){
				return false;
			}else{
				$("body").css("cursor", "progress");
				$(this).css("cursor", "progress");
				$(this).removeClass("active-button");
			  $(this).addClass("disabled-button");
			  $(this).attr("href", $(this).attr("href") + "&url=" + $("#sw_url").val());
	    }
		}else{
			return false;
		}
	});

	// Create hidden elements reflecting the value of all disabled elements
	$("#send, #save").click(function(){
		$("#reserve_form select:disabled").each(function(){
			$(this).after("<input type='hidden' name='" + $(this).attr("name") + "' value='" + $(this).val() + "' />");
		});
		// We may not need to do this.  I won't hurt, but since we don't allow people to edit the term once we've disabled term, it really doesn't need to update.
		var radio = $("#reserve_form #reserve-timing input:checked");
		radio.after("<input type='hidden' name='" + radio.attr("name") + "' value='" + radio.val() + "' />");
	});

	$("#add_custom").click(function(){
		$("body").css("cursor", "progress");
	});

	// Delete item links
	$("body").on("click", ".delete", function(){
		$(this).parents("tr").remove();
		update_item_list_numbers_and_classes();
		show_changed($("#item_list_table"));
		check_validations();
		return false;
	});

  // form change hook
  $("#reserve_form input:not(#sw_url), #reserve_form textarea, #reserve_form select").on("change", function(){
    check_validations();
  });

  // Term processing
  $("#reserve_form select#term").focus(function(){
	  $("#reserve_form input#future").attr("checked", "checked");
  });

  // enforce loan period on library change
  $("select#libraries").on("change", function(){
  	  check_loan_period();
  });
  // enforce loan period on page load
  if($("#reserve_form").length > 0){
	  check_loan_period();
  }

  $('.digital-item-type input[name="reserve[item_list][][digital_type]"]').change(function() {
    var $textArea = $(this).closest('.digital-item-type').find('textarea[name="reserve[item_list][][digital_type_description]"]');
    if (this.value === 'complete_work') {
      $textArea.attr('disabled', true);
    }
    if (this.value === 'partial_work') {
      $textArea.attr('disabled', false);
    }
  });
});

function check_validations(){
	if($("#reserve_form #libraries").val() == "(select library)" || $("#item_list_table tbody tr").length < 2 ){
	  $("input#send").attr("disabled", "true");
	  $("input#send").removeClass("active-button");
	  $("input#send").addClass("disabled-button");
  }else{
	  $("input#send").removeAttr("disabled");
	  $("input#send").addClass("active-button");
	  $("input#send").removeClass("disabled-button");
		$("input#send").val("Save and SEND request");
  }
}

function update_item_list_numbers_and_classes(){
	i = 1;
	$("#item_list_table tbody tr").each(function(){
	  $(this).children("td:first").text(i);
	  i += 1;
	});
}
function show_changed(table){
	table.addClass("changed")
}
function check_loan_period(){
	var library = $("select#libraries").children("option:selected").text();
	$("select.loan-select").each(function(){
		var select = $(this);
		if(library == "Music Library") {
			$(".loan-select").each(function(){
				$("option", $(this)).each(function(){
					$(this).removeAttr("selected");
				});
				$("option:contains('4 hours')", $(this)).attr("selected", true);
			});
		  $(this).attr("disabled","true");
		}else if(!select.hasClass("media")){
			select.removeAttr("disabled");
		}
	});
}

function clean_up_loading() {
	$("body").css("cursor", "auto");
	$("a.add-sw-item").css("cursor", "pointer");
	$("a.add-sw-item").removeClass("disabled-button");
  $("a.add-sw-item").addClass("active-button");
}

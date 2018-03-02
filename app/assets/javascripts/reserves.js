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

	// Add comment links
	$("body").on("click", ".add-comment", function(){
		if($(this).text() == "Add comment"){
		  $(this).text("Remove comment");
		}else{
			$(this).text("Add comment");
		}
		$(this).parents("td").children("textarea").toggle();
		$(this).parents("td").children("textarea").val("");
    return false;
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

  // jQuery dialog
  $("a.dialog").each(function() {
    var dialog_box = "empty";
    var link = $(this);
    $(this).click( function() {
      //lazy create of dialog
      if ( dialog_box == "empty") {
        dialog_box = $('<div class="dialog_box"></div>').dialog({ autoOpen: false});
	      // Load the original URL on the link into the dialog associated
	      // with it. Rails app will give us an appropriate partial.
	      // pull dialog title out of first heading in contents.
	      $("body").css("cursor", "progress");
	      dialog_box.load( this.href , function() {
				  // Remove first header from loaded content, and make it a dialog
		      // title instead
		      var heading = dialog_box.find("h1, h2, h3, h4, h5, h6").eq(0).remove();
		      dialog_box.dialog("option", "title", heading.text());
	        $("body").css("cursor", "auto");
	      });

				// set the appropriate height/width/position of dialog.
	      dialog_box.dialog({
					height: 'auto',
					width: Math.max(($(window).width() /2), 45),
					position: { my: "center top", at: "center bottom", of: '#header' }
				});
      }
      dialog_box.dialog("open").dialog("moveToTop");

      return false; // do not execute default href visit
    });

  });


  // enforce loan period on library change
  $("select#libraries").on("change", function(){
  	  check_loan_period();
  });
  // enforce loan period on page load
  if($("#reserve_form").length > 0){
	  check_loan_period();
  }
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
		$(this).attr("class", (i % 2 == 0) ? "even" : "odd");
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

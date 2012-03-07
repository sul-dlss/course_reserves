// Things that need to document to be loaded to do.
$(document).ready(function(){
	
	// Add item from SW
	$(".add-sw-item").click(function(){
		if($("#sw_url").attr("value") != ""){
			$("body").css("cursor", "progress");
		  $(this).attr("href", $(this).attr("href") + "&url=" + $("#sw_url").attr("value"));	
		}else{
			return false;
		}
	});
	
	$("#add_custom").click(function(){
		$("body").css("cursor", "progress");
	});
	
	// Add comment links
	$(".add-comment a").live("click", function(){
		$(this).toggle();
		$(this).parents("td").children("textarea").toggle();
		return false;
	});
	
	// Delete item links
	$(".delete").live("click", function(){
		$(this).parents("tr").remove();
		update_item_list_numbers_and_classes();
		show_changed($("#item_list_table"));
		check_validations();
		return false;
	});

  // form change hook
  $("#reserve_form input, #reserve_form textarea, #reserve_form select").live("change", function(){
    check_validations();
  });
  
  // Term processing
  $("#reserve_form select#term").click(function(){
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
	      dialog_box.dialog("option", "height", "auto");
				dialog_box.dialog("option", "width", Math.max(($(window).width() /2), 45));
		    dialog_box.dialog("option", "position", ['center', 75]);
      }
      dialog_box.dialog("open").dialog("moveToTop");

      return false; // do not execute default href visit
    });
    
  });
  
  
  // enforce loan period on library change
  $("select#libraries").live("change", function(){
  	  check_loan_period();
  });
  // enforce loan period on page load
  if($("#reserve_form").length > 0){
	  check_loan_period();
  }
});

function check_validations(){
	if($("#reserve_form #libraries").val() == "(select library)" ||
		 $("#reserve_form input#contact_name").val() == ""  || 
	   $("#reserve_form input#contact_phone").val() == "" || 
	   $("#reserve_form input#contact_email").val() == "" || 
	   $("#item_list_table tbody tr").length < 2 ){
	  $("input#send").attr("disabled", "true");	
	  $("input#send").removeClass("active-button");
	  $("input#send").addClass("disabled-button");
  }else{
	  $("input#send").removeAttr("disabled");
	  $("input#send").addClass("active-button");
	  $("input#send").removeClass("disabled-button");
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
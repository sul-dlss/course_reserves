// Things that need to document to be loaded to do.
$(document).ready(function(){
	
	// Add item from SW
	$(".add-sw-item").click(function(){
		$(this).attr("href", $(this).attr("href") + "&url=" + $("#sw_url").attr("value"));
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
		return false;
	});

  // jQuery dialog
  $("a.dialog").each(function() {
    var dialog_box = "empty";
    var link = $(this);
    $(this).click( function() {     
      //lazy create of dialog
      if ( dialog_box == "empty") {
        dialog_box = $('<div class="dialog_box"></div>').dialog({ autoOpen: false});          
      }
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
      dialog_box.dialog("open").dialog("moveToTop");

      return false; // do not execute default href visit
    });
    
  });
  

  // enforce loan period on library change
  // $("select#libraries").change(function(){
  // 	  check_loan_period();
  // });
});

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
			select.children("option").each(function(){
				var option = $(this);
		    if(option.text() == "4 hours") {
			  	option.attr("selected", true);
		    }else{
			    option.removeAttr("selected")
		    }
			});
		  $(this).attr("disabled","true");
		}else{
			select.removeAttr("disabled");
		}
	});
}
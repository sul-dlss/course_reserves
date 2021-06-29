// Things that need to document to be loaded to do.
$(document).ready(function(){
	$('#collapsePrint').on('show.bs.collapse', function() {
		$('[data-target="#collapsePrint"] input[type="checkbox"]').prop( "checked", false );
	})
	$('#collapsePrint').on('hide.bs.collapse', function() {
		$('[data-target="#collapsePrint"] input[type="checkbox"]').prop( "checked", true );
	})
	$('#sw_url').on('keypress', function(e) {
		if (e.keyCode == 13) {
			e.preventDefault();
			$('.add-sw-item')[0].click();
		}
	});

	// Add item from SW
	$(".add-sw-item").click(function(){
		if($("#sw_url").val() != ""){
			var already_exists = false;
			$("a").each(function(){
				if($(this).attr("href") === $("#sw_url").val() || $(this).attr("href") === "https://searchworks.stanford.edu/view/" + $("#sw_url").val()){
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

	$("#add_custom").click(function(){
		$("body").css("cursor", "progress");
	});

	// Delete item links
	$("body").on("click", ".delete", function(){
		$(this).parents(".reserve").remove();
    togglePartialWorkTextarea();
		show_changed($("#item_list"));
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

  togglePartialWorkTextarea();
});

function check_validations(){
	if($("#reserve_form #libraries").val() == "(select library)" || $("#item_list .reserve:not(#add_row)").length < 1 ){
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

function togglePartialWorkTextarea() {
  $('.digital-item-type input[name$="[digital_type]"]').change(function() {
    var $textArea = $(this).closest('.digital-item-type').find('textarea[name$="[digital_type_description]"]');

    if (this.value === 'complete_work') {
      $textArea.attr('disabled', true);
    }
    if (this.value === 'partial_work') {
      $textArea.attr('disabled', false);
    }
  });
}

function show_changed(el){
	el.addClass("changed")
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

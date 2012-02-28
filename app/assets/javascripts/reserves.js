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
		return false;
	});
});

function update_item_list_numbers_and_classes(){
	i = 1;
	$("#item_list_table tbody tr").each(function(){
		$(this).attr("class", (i % 2 == 0) ? "even" : "odd");
	  $(this).children("td:first").text(i);
	  i += 1;
	});
}

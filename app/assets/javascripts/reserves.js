// Things that need to document to be loaded to do.
$(document).ready(function(){
	
	// Add comment links
	$(".add-comment a").each(function(){
		var link = $(this);
		var index = $(this).attr("data-item-index");
		link.click(function(){
			$('textarea.item-comment[data-item-index="' + index + '"]').toggle();
			link.toggle();
			return false;
		});
	});
	
	// Delete item links
	$(".delete").live("click", function(){
		$(this).parents("tr").remove();
		update_item_list_numbers();
		return false;
	});
});

function update_item_list_numbers(){
	i = 1;
	$("#item_list_table tbody tr").each(function(){
	  $(this).children("td:first").text(i);
	  i += 1;
	});
}

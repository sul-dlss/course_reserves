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
});

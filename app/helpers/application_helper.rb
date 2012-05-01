require 'terms'
module ApplicationHelper
  include Terms
  def item_in_searchworks?(item)
    if params[:sw] == "true" or ( item.has_key?("ckey") and !item["ckey"].blank? )
      true
    else
      false
    end
  end
  
  def app_config
    CourseReserves::Application.config
  end
  
end

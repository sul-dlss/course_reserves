module ApplicationHelper
  
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
  
  def current_term
    "#{season(Time.now)} #{Time.now.year}"
  end
  
  def future_terms(term = season(Time.now))
    ix = seasons.index(term)
    if seasons[ix + 1] and seasons[ix + 2]
      future = [seasons[ix + 1], seasons[ix + 2]]
    elsif seasons[ix + 1] and seasons[ix + 2].nil?
      future = [seasons.last, seasons.first]
    elsif ix == (seasons.length - 1)
      future = [seasons[0], seasons[1]]
    end
  end
  
  private
  
  def season(date)
    # Fall 2012-13: September 24 and December 14
    # Winter 2012-13: January 7 and March 22
    # Spring 2012-13: April 1 and June 12 (Commencement June 16)
    # Summer 2012-13: June 24 and August 17
    case date.month
      when 10..12 then seasons[0]
      when 1..3   then seasons[1]
      when 4..6   then seasons[2]
      when 7..9   then seasons[3]
    end
  end
  
  def seasons
    ["Fall", "Winter", "Spring", "Summer"]
  end
  
end

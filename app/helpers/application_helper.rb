require 'terms'
module ApplicationHelper
  def item_in_searchworks?(item)
    if params[:sw] == "true" or ( item.has_key?("ckey") and !item["ckey"].blank? )
      true
    else
      false
    end
  end

  def current_term
    Terms.current_term
  end

  def future_terms(*args)
    Terms.future_terms(*args)
  end

  def sortable_term_value(value)
    term_data = Settings.terms.find { |t| t[:term] == value } || {}
    term_data[:end_date]
  end
end

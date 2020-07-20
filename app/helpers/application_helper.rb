require 'terms'
module ApplicationHelper
  def application_name
    'Course Reserves'
  end

  def item_in_searchworks?(item)
    if (params[:sw] == "true") || (item.key?("ckey") && item["ckey"].present?)
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

  def has_existing_reserve_for_term?(reserve, term)
    Reserve.where(compound_key: reserve.compound_key, term: term).where.not(id: reserve.id).any?
  end

  def render_term_label(term)
    if term == Terms.current_term
      term + ' (current quarter)'
    else
      term
    end
  end
end

module Terms
    
  def current_term
    current_term_hash[:term]
  end
  
  def current_term_hash(date = Date::today)
    CourseReserves::Application.config.terms.each_with_index do |term, ix|
      return term if term[:end_date] >= date and CourseReserves::Application.config.terms[ix-1][:end_date] < date
    end
  end
  
  def future_terms(term = nil)
    if term.nil?
      current_term_index = CourseReserves::Application.config.terms.index(current_term_hash)
    else
      current_term = CourseReserves::Application.config.terms.collect{|t| t if t[:term] == term}.compact.first
      current_term_index = CourseReserves::Application.config.terms.index(current_term)
    end
    terms = [CourseReserves::Application.config.terms[current_term_index+1][:term]]
    terms << CourseReserves::Application.config.terms[current_term_index+2][:term] if CourseReserves::Application.config.terms[current_term_index+2]
    return terms
  end
  
  def process_term_for_cw(term)
    term.gsub(/Spring \d{2}/, "Sp").gsub(/Summer \d{2}/, "Su").gsub(/Winter \d{2}/, "W").gsub(/Fall \d{2}/, "F")
  end
  
end
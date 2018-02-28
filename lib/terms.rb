module Terms
  class << self
    def current_term
      current_term_hash[:term]
    end

    def future_terms(term = nil)
      if term.nil?
        current_term_index = terms.index(current_term_hash)
      else
        current_term = terms.collect{|t| t if t[:term] == term}.compact.first
        current_term_index = terms.index(current_term)
      end
      future_terms = [terms[current_term_index+1][:term]]
      future_terms << terms[current_term_index+2][:term] if terms[current_term_index+2]
      return future_terms
    end
    
    def process_term_for_cw(term)
      term.gsub(/Spring \d{2}/, "Sp").gsub(/Summer \d{2}/, "Su").gsub(/Winter \d{2}/, "W").gsub(/Fall \d{2}/, "F")
    end

    private

    def current_term_hash(date = Date::today)
      terms.each_with_index do |term, ix|
        return term if term[:end_date] >= date and terms[ix-1][:end_date] < date
      end
    end
    
    def terms
      Settings.terms
    end
  end
end

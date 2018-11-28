module Terms
  class << self
    def all
      [current_term, future_terms].flatten
    end

    def current_term
      current_term_hash[:term]
    end

    def future_terms(term = nil)
      current_term_index = if term.nil?
        terms.index(current_term_hash)
      else
        terms.index { |t| t[:term] == term }
      end

      terms.slice(current_term_index + 1, 2).map { |t| t[:term] }
    end

    def process_term_for_cw(term)
      term.gsub(/Spring \d{2}/, "Sp").gsub(/Summer \d{2}/, "Su").gsub(/Winter \d{2}/, "W").gsub(/Fall \d{2}/, "F")
    end

    private

    def current_term_hash(date = Date::today)
      terms.each_with_index do |term, ix|
        return term if (term[:end_date] >= date) && (terms[ix - 1][:end_date] < date)
      end
    end

    def terms
      Settings.terms
    end
  end
end

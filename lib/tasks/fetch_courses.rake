desc "rake task to fetch course term and individual course information from MaIS APIs"
task fetch_courses: :environment do
  current_term = Terms.current_term
  future_term = Terms.future_terms.first
  errors = []
  c_api = CourseApi.new

  # Get the current term and the very next term
  [current_term, future_term].each do |term|
    # Get the courses information for this particular term
    # The return object has errors and the list of courses
    courses_info = c_api.courses_for_term(term)
    if courses_info.empty?
      errors << "Courses not returned for #{term}"
    else
      # Write the JSON resulting from CourseTerm and Course API calls to the appropriate directory
      CourseOutputWriter.new(Terms.process_term_for_cw(term), courses_info[:courses]).write
      errors = courses_info[:errors]
    end
  end
  # Send error message if certain courses failing
  ReportMailer.msg(to: Settings.email.reports, subject: "Problem retrieving course results", message: errors).deliver_now if errors.present?
end

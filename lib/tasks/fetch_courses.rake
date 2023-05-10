require 'terms'
require 'faraday'
require 'openssl'
require 'course_api'

desc "rake task to fetch course term and individual course information from MaIS APIs"
task fetch_courses: :environment do
  current_term = Terms.current_term
  future_term = Terms.future_terms.first
  errors = []
  updated = false
  c_api = CourseAPI.new

  # Get the current term and the very next term
  [current_term, future_term].each do |term|
    # The file to which the JSON resulting from CourseTerm and Course API calls will be written
    file_name = "course_#{Terms.process_term_for_cw(term)}.json"
    # Get the courses information for this particular term
    # The return object has errors and the list of courses
    courses_info = c_api.courses_for_term(term)
    if courses_info.empty?
      errors << "Courses not returned for #{term}"
    else
      courses = courses_info[:courses]
      errors = courses_info[:errors]
      # Write the JSON to the folder where the app will pick it up later
      File.write("#{Rails.root}/lib/course_work_xml/#{file_name}", courses.to_json.force_encoding('UTF-8'))
      updated = true
    end
  end
  # Send error message if certain courses failing
  ReportMailer.msg(to: Settings.email.reports, subject: "Problem retrieving course results", message: errors).deliver_now if errors.present?
  `touch tmp/restart.txt` if updated
end

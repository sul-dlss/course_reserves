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
  c_api.setup_connection

  # Get the current term and the very next term
  [current_term, future_term].each do |term|
    # The file to which the JSON resulting from CourseTerm and Course API calls will be written
    file_name = "course_#{Terms.process_term_for_cw(term)}.json"
    # Get the course term API response
    response = c_api.course_term_response(term)
    if response.status == 200
      # Parse the course term information to retrieve courses
      courses_info = c_api.parse_term(response.body)
      courses = courses_info[:courses]
      course_errors = courses_info[:errors]
      # Keep errors if they occurred
      errors.concat(course_errors) unless course_errors.empty?
      # Write the JSON to the folder where the app will pick it up later
      File.write("#{Rails.root}/lib/course_work_xml/#{file_name}", courses.to_json.force_encoding('UTF-8'))
      updated = true
    else
      errors << "request for #{term} returned #{response.status}\n"
    end
  end
  puts errors.to_s
  # Send error message if certain courses failing
  Report.msg(to: Settings.email.reports, subject: "Problem retrieving course results", message: errors).deliver_now if errors.present?
  `touch tmp/restart.txt` if updated
end

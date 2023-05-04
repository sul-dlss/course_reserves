require 'terms'
require 'faraday'
require 'openssl'
require 'course_api'

desc "rake task to fetch course term and individual course information from MaIS APIs"
task fetch_api: :environment do
  current_term = Terms.current_term
  future_term = Terms.future_terms.first
  errors = []
  updated = false

  # Use environment variable with a default value set to a relative path
  # to identify where this file should be
  certs_path = Rails.root.join("config")
  cert_file = "sul-harvester.cert"
  key_file = "sul-harvester.key"
  client_cert = OpenSSL::X509::Certificate.new File.read(cert_file)
  client_key = OpenSSL::PKey.read File.read(key_file)
  connection = Faraday::Connection.new 'https://registry.stanford.edu', :ssl => { :client_cert => client_cert, :client_key => client_key }

  # Original XML retrieval depended on getting the current term and the very next term 
  [current_term, future_term].each do |term|
    url = courseterm_url(term)
    file_name = "course_" + Terms.process_term_for_cw(term) + ".json"
    response = connection.get(url)
    if response.status == 200
      c_api = CourseAPI.new(response.body)
      courses_info = c_api.parse
      courses = courses_info[:courses]
      course_errors = courses_info[:errors]
      if course_errors.length > 0 then errors.concat(course_errors) end
      File.open("#{Rails.root}/lib/course_work_xml/#{file_name}", "w") do |f|
        f.write(courses.to_json.force_encoding('UTF-8'))
      end
      updated = true
    else
      errors << "#{url} returned #{response.status}\n"
    end
  end
 
  # Send error message if certain courses failing
  Report.msg(to: Settings.email.reports, subject: "Problem retrieving course results", message: errors).deliver_now if errors.present?
  %x[touch tmp/restart.txt] if updated
end

# Terms of format "Spring 2023", "Winter 2023", etc.
def courseterm_url(term)
  term_parts = term.split(" ")
  quarter = term_parts[0]
  quarter_code = get_quarter_code(quarter)
  year = term_parts[1][2, 4]
  if quarter == "Fall" then year = year - 1 end
  "/doc/courseterm/1" + year.to_s + quarter_code
end

def get_quarter_code(quarter)
  case quarter
  when "Fall"
      "2"
  when "Winter"
      "4"
  when "Spring"
      "6"
  when "Summer"
      "8"
  else
      ""
  end
end
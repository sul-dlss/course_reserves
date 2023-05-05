require 'terms'
require 'json'
require 'nokogiri'
require 'faraday'

# Get course term information and then parse
class CourseAPI
  def initialize
    @connection = nil
  end

  # Set up Faraday connection
  def setup_connection
    cert_file = Rails.root.join("config/sul-harvester.cert")
    key_file = Rails.root.join("config/sul-harvester.key")
    client_cert = OpenSSL::X509::Certificate.new File.read(cert_file)
    client_key = OpenSSL::PKey.read File.read(key_file)
    @connection = Faraday::Connection.new 'https://registry.stanford.edu', ssl: { client_cert: client_cert, client_key: client_key }
  end

  # Methods for retrieving and parsing course term information
  def course_term_response(term)
    url = courseterm_url(term)
    @connection.get(url)
  end

  # Given the text for a term, i.e. "Spring 2023", generate the term id required by the CourseTerm API
  # Spring 2023 = 1 (year starts with 20) 23 (year) 6(id for quarter) = 1236
  def courseterm_url(term)
    term_parts = term.split
    quarter = term_parts[0]
    quarter_code = get_quarter_code(quarter)
    year = term_parts[1][2, 4].to_i
    year += 1 if quarter == "Fall"
    "/doc/courseterm/1#{year}#{quarter_code}"
  end

  # Map the quarter string name to a number for the term id
  def get_quarter_code(quarter)
    quarter_id = ""
    quarter_map = { "Fall" => "2", "Winter" => "4", "Spring" => "6", "Summer" => "8" }
    quarter_id = quarter_map[quarter] if quarter_map.key?(quarter)
    quarter_id
  end

  # Parse the XML returned by the CourseTerm MaIS API
  def parse_term(course_term_xml)
    courses = []
    all_errors = []
    # Return array of course hash objects
    courses_list = parse_courses(course_term_xml)
    courses_list.each_with_index do |course, index|
      # Build in a wait of a second after every 10,000 requests to the course API
      sleep(1) if (index % 10_000).zero?
      request_class_id = course[:request_class_id]
      # Call the individual Course API to get sections and instructors for this course
      course_info = get_course_info(request_class_id)
      sections = course_info[:sections]
      all_errors.concat(course_info[:errors])
      sections.each do |section|
        section_id = section[:sid]
        instructors = section[:instructors]
        course_hash = { title: course[:title], term: course[:term], cid: course[:cid], cids: course[:cids],
                        sid: section_id, instructors: instructors }
        courses << course_hash
      end
    end
    # Returns any errors encountered plus full list of courses
    { errors: all_errors, courses: courses }
  end

  # parse the course term xml to generate the list of courses for which we must make individual course requests
  def parse_courses(course_term_xml)
    course_term = Nokogiri::XML(course_term_xml)
    root_elem = course_term.xpath("/CourseTerm")[0]
    term = root_elem.attr("term")
    term_display = generate_term(term)
    courses = []
    root_elem.xpath(".//course").each do |course|
      course_title = course[:title]
      cids = extract_cids(course)
      course.xpath(".//class").each do |class_obj|
        request_class_id = class_obj[:id]
        class_id = remove_class_id_prefix(request_class_id)
        course_hash = { title: course_title, term: term_display, cid: class_id, cids: cids, request_class_id: request_class_id }
        courses << course_hash
      end
    end
    # Return list of all courses with the information required from xml
    courses
  end

  def extract_cids(course)
    cids = []
    course.xpath(".//class").each do |cl|
      cids << remove_class_id_prefix(cl[:id])
    end
    cids
  end

  # Generate connection to course API
  def request_course_api(request_class_id)
    errors = []
    spec_course = "/doc/courseclass/#{request_class_id}"
    begin
      response = @connection.get spec_course
    # Timeout error
    rescue Faraday::TimeoutError
      # Retry
      begin
        response = @connection.get spec_course
      rescue Faraday::Error
        errors << "After timeout, retry failed for #{request_class_id}"
      end
    # Connection failed error
    rescue Faraday::ConnectionFailed
      errors << "Connection failed for #{request_class_id}"
    rescue Faraday::ServerError
      errors << "Server error for #{request_class_id}"
    end
    { response: response, errors: errors }
  end

  # Get course information from API request, return sections and any errors that occurred
  def get_course_info(request_class_id)
    response_info = request_course_api(request_class_id)
    response = response_info[:response]
    errors = response_info[:errors]
    sections = []
    # Get sections and instructors for this course if the response status is successful
    errors << "#{request_class_id} returned error #{response.status}" if response.status != 200
    sections = parse_sections(response.body, request_class_id) if response.status == 200
    { sections: sections, errors: errors }
  end

  # Return sections and instructor information for a particular course API response
  def parse_sections(response_xml, request_class_id)
    sections = []
    course_response = Nokogiri::XML(response_xml)
    # Does this section have instructors, if so return the section info and instructors sunet id and name
    # The same course request can return cross listed courses, so we will need to get a specific id
    course_response.xpath("//class[@id='#{request_class_id}']//section[.//instructor]").each do |section|
      section_id = section[:id]
      instructors = []
      section.xpath(".//instructor/person").each do |person|
        sunetid = person[:sunetid]
        name = person.text
        instructors << { sunet: sunetid, name: name }
      end
      sections << { sid: section_id, instructors: instructors }
    end
    sections
  end

  # Based on logic https://github.com/sul-dlss/registry-harvester/blob/main/Course/src/main/java/edu/stanford/BuildTermString.java
  # Term ids are of the form: 1236, where "1" designates the year starts with "20"
  # The 2nd and 3rd digits represent the year. The last digit represents the quarter
  # 1236 represents 2023 Spring.  1182 is Fall 2017
  def generate_term(term_id)
    # if 1, then year 20
    academic_year = term_id[1, 2].to_i
    term_quarter = get_term_quarter(term_id)
    academic_year -= 1 if term_quarter == "Fall"
    academic_year = "20#{academic_year}" if term_id[0, 1]
    "#{term_quarter} #{academic_year}"
  end

  # Term ids are of the form: 1236.  The last digit represents the quarter
  def get_term_quarter(term_id)
    term_quarters = { "2" => "Fall", "4" => "Winter", "6" => "Spring", "8" => "Summer" }
    quarter = ""
    term_suffix = term_id[3, 3]
    quarter = term_quarters[term_suffix] if term_quarters.key?(term_suffix)
    quarter
  end

  # Class ids will look like 1236-ECON-1235. We want to remove the "1236" which is the term id
  def remove_class_id_prefix(class_id)
    class_id.gsub(/^\w{1,2}\d{2}-/, "")
  end
end

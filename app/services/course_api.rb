# Get course term information and then parse
class CourseApi
  # Called on CourseAPI.new
  # Providing parameter for connection enables testing with Faraday connection stub
  def initialize(connection = nil)
    @connection = connection || setup_connection
  end

  # For a given term, retrieve the courses json
  # If there is an error with course term retrieval, an empty array will be returned
  # If there are errors at the individual course API level, the returned object
  # will be { errors: errors, courses: courses }
  def courses_for_term(term)
    # Get the course term information from the API
    response = course_term_response(term)
    # If the response succeeds, return parsed list of courses with additional info
    # from Course API for each individual course
    !response.nil? && response.status == 200 ? parse_term(response.body) : []
  end

  private

  # Set up Faraday connection
  def setup_connection
    cert_file = Rails.root.join("config/sul-harvester.cert")
    key_file = Rails.root.join("config/sul-harvester.key")
    client_cert = OpenSSL::X509::Certificate.new File.read(cert_file)
    client_key = OpenSSL::PKey.read File.read(key_file)
    @connection = Faraday.new(url: "https://registry.stanford.edu") do |faraday|
      faraday.use Faraday::Response::RaiseError
      faraday.ssl[:client_cert] = client_cert
      faraday.ssl[:client_key] = client_key
      # By default, picks up timeout exceptions, but more exceptions can be added by specifying
      # exceptions:[] in the retry options hash
      faraday.request :retry, { max: 1, interval: 0.5 }
    end
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
    courses_list.each do |course|
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
    course.xpath(".//class").map do |cl|
      remove_class_id_prefix(cl[:id])
    end
  end

  # Generate connection to course API
  def request_course_api(request_class_id)
    errors = []
    spec_course = "/doc/courseclass/#{request_class_id}"
    begin
      response = @connection.get spec_course
    rescue Faraday::Error => e
      errors << "#{e.class.name}, #{e} for course id #{request_class_id}"
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
    sections = parse_sections(response.body, request_class_id) if !response.nil? && response.status == 200
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
      # We do not want to duplicate instructor names even if multiple meetings have same instructor
      instructor_sunets = {}
      section.xpath(".//instructor/person").each do |person|
        sunetid = person[:sunetid]
        name = person.text
        instructor_sunets[sunetid] = name unless instructor_sunets.key?(sunetid)
      end
      sections << { sid: section_id, instructors: instructor_sunets.map { |k, v| { sunet: k, name: v } } }
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

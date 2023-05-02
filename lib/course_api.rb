require 'terms'
require 'json'
require 'nokogiri'
require 'faraday'

# Get course term information and then parse
class CourseAPI
    def initialize(xml)
        @course_term = Nokogiri::XML(xml)
    end

    def parse
        root_elem = @course_term.xpath("/CourseTerm")[0]
        term = root_elem.attr("term")
        term_display = generate_term(term)
        quarter = root_elem.attr("quarter")

        courses = []
        counter = 0
        root_elem.xpath(".//course").each do |course|
            course_id = course[:id]
            course_title = course[:title]
            cids = []
            course.xpath(".//class").each do |cl|
                cids << remove_class_id_prefix(cl[:id])
              end
            course.xpath(".//class").each do |class_obj|
                request_class_id = class_obj[:id]
                class_id = remove_class_id_prefix(request_class_id)
                # Get all the sections for this course which have instructors
                #puts "Getting sections for " + request_class_id.to_s
                
                # Get sections using the Course API, look only for sections
                # that have instructors lister
                # After a certain amount of calls, wait a second
                counter += 1
                #puts counter
                if(counter == 10000)
                    puts "reset counter"
                    sleep(1)
                    counter = 0
                end 
                sections = request_course_API(request_class_id)
                sections.each do |section|
                    section_id = section[:sid]
                    instructors = section[:instructors]
                    course_hash = {"title": course_title, "term": term_display, "cid": class_id, "cids": cids, 
                    "sid":section_id, "instructors": instructors}
                    courses << course_hash
                end
            end 
        end
        # Array of course hash objects
        courses
    end

    def request_course_API(request_class_id)
        # Put in some time between calls to help with timeouts
        cert_file = Settings.certs_path + "sul-harvester.cert"
        key_file = Settings.certs_path + "sul-harvester.key"
        sections = []
        errors = []
        client_cert = OpenSSL::X509::Certificate.new File.read(cert_file)
        client_key = OpenSSL::PKey.read File.read(key_file)
        connection = Faraday::Connection.new 'https://registry.stanford.edu', :ssl => { :client_cert => client_cert, :client_key => client_key }
        spec_course = '/doc/courseclass/' + request_class_id
        begin
            response = connection.get spec_course
        # Timeout error
        rescue Faraday::TimeoutError
            errors << "timeout error occurred for first attempt for " + request_class_id.to_s
            # Retry
            begin 
                response = connection.get spec_course
            rescue Faraday::Error
                errors << "retry failed for " + request_class_id.to_s
            end
        # Connection failed error
        rescue Faraday::ConnectionFailed
            errors << "Connection failed occurred for first attempt for " + request_class_id.to_s
        rescue Faraday::ServerError
            errors << "Server Error for " + request_class_id.to_s
        end
        if response.status == 200
            course_response = Nokogiri::XML(response.body)
            # Does this section have instructors, if so return the instructors
            course_response.xpath("//section[.//instructor]").each do |section|
                section_id = section[:id]
                instructors = []
                section.xpath(".//instructor/person").each do |person|
                    sunetid = person[:sunetid]
                    name = person.text
                    instructors << {"sunet": sunetid, "name": name}
                end
                sections << {"sid": section_id, "instructors": instructors}
            end

        else
            errors << "#{request_class_id} returned #{response.status}\n"
        end 

        if errors.length > 0
            # Find a different way to communicate errors
            puts "ERRORS:" + errors.to_s
        end
        sections
    end


    # Based on https://github.com/sul-dlss/registry-harvester/blob/main/Course/src/main/java/edu/stanford/BuildTermString.java
    def generate_term(term_id)
        #if 1, then year 20? what are the other options?
        academic_year = term_id[1, 2].to_i
        term_quarter = get_term_quarter(term_id)
        if(term_quarter == "Fall") then academic_year += 1 end
        if(term_id[0,1] == "1") then academic_year = "20" + academic_year.to_s end
        term_display = term_quarter + " " + academic_year.to_s 
    end

    def get_term_quarter(term_id)
        term_suffix = term_id[3,3]

        #Get last digit
        case term_suffix
        when "2"
            "Fall"
        when "4"
            "Winter"
        when "6"
            "Spring"
        when "8"
            "Summer"
        else
            ""
        end
    end


    def remove_class_id_prefix(class_id)
        class_id.gsub(/^\w{1,2}\d{2}-/, "")
    end

end

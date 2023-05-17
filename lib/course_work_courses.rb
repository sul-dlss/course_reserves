require 'nokogiri'
require 'terms'
class CourseWorkCourses
  class Course
    attr_reader :title, :term, :cid, :cids, :sid, :instructors

    def initialize(title:, term:, cid:, cids:, sid:, instructors:)
      @title = title
      @term = term
      @cid = cid
      @cids = cids
      @sid = sid
      @instructors = instructors
    end

    def key
      "#{cid}-#{instructor_sunets.join('-')}"
    end

    def comp_key
      "#{cids.sort.join(',')},#{instructor_sunets.join(',')}"
    end

    def instructor_sunets
      instructors.pluck(:sunet).compact.sort
    end

    def instructor_names
      instructors.pluck(:name).compact.sort
    end

    def cross_listings
      cids.reject { |c| c == cid }.join(", ")
    end
  end

  def self.instance
    @instance ||= CourseWorkCourses.new
  end

  def initialize(file = nil)
    if Settings.use_course_json
      initialize_json(file)
    else
      initialize_xml(file)
    end
  end

  # These two initialize methods are broken out to enable both approaches
  # until we switch over completely to JSON
  def initialize_xml(xml)
    if xml
      @raw_xml = [Nokogiri::XML(xml)]
    else
      @raw_xml = load_xml_from_coursework
    end
  end

  def raw_xml
    @raw_xml ||= self.raw_xml
  end

  # Handling JSON
  def initialize_json(json_file)
    if json_file
      @json_files = [JSON.parse(json_file)]
    else
      @json_files = load_from_coursework
    end
  end

  def json_files
    @json_files ||= self.json_files
  end

  def find_by_sunet(sunet)
    self.all_courses.select do |course|
      course.instructor_sunets.include?(sunet)
    end
  end

  def find_by_class_id(class_id)
    self.all_courses.select do |course|
      course.cid == class_id
    end
  end

  def find_by_compound_key(key)
    self.course_map[key] || []
  end

  def find_by_class_id_and_section(class_id, section)
    self.all_courses.select do |course|
      course.cid == class_id && course.sid == section
    end
  end

  def find_by_class_id_and_sunet(class_id, sunet)
    self.all_courses.select do |course|
      course.cid == class_id && course.instructor_sunets.include?(sunet)
    end
  end

  def find_by_class_id_and_section_and_sunet(class_id, section, sunet)
    self.all_courses.select do |course|
      course.cid == class_id && course.sid == section && course.instructor_sunets.include?(sunet)
    end
  end

  # TODO: We have tests that are highly sensitive to the order of the courses; this unfortunate
  # logic preserves the bottom-most course from the xml. it's unclear whether this is incidental
  # or a feature.
  # Breaking out into two approaches.  JSON is picked only if the Setting is present
  def all_courses
    # if Settings.use_course_json == true
    if Settings.use_course_json
      @all_courses ||= process_all_courses(self.json_files).to_a.reverse.uniq(&:key).reverse.to_a
    else
      @all_courses ||= process_all_courses_xml(self.raw_xml).to_a.reverse.uniq(&:key).reverse.to_a
    end
  end

  # Efficient lookup of course data by compound key (which is used in a few places around the app)
  def course_map
    @course_map ||= all_courses.each_with_object({}) do |course, map|
      if map[course.comp_key]
        map[course.comp_key] << course
      else
        map[course.comp_key] = [course]
      end
    end
  end

  private

  def load_xml_from_coursework
    if Rails.env.test?
      return [Nokogiri::XML(File.open("#{Rails.root}/spec/fixtures/course_work.xml", 'r'))]
    else
      current = Terms.process_term_for_cw(Terms.current_term)
      next_term = Terms.process_term_for_cw(Terms.future_terms.first)
      xml = []
      ["#{Rails.root}/lib/course_work_xml/courseXML_#{current}.xml", "#{Rails.root}/lib/course_work_xml/courseXML_#{next_term}.xml"].each do |url|
        xml << Nokogiri::XML(File.open(url, 'r')) if File.exist?(url)
      end
      return xml
    end
  end

  def process_all_courses_xml(xml_files)
    return to_enum(:process_all_courses_xml, xml_files) unless block_given?

    xml_files.each do |xml|
      xml.xpath("//courseclass").each_with_index do |course, idx_course|
        course_title = course[:title]
        term = course[:term]
        cids = []
        course.xpath("./class").each do |cl|
          cids << cl[:id].gsub(/^\w{1,2}\d{2}-/, "")
        end
        course.xpath("./class").each_with_index do |cl, idx_cl|
          class_id = cl[:id].gsub(/^\w{1,2}\d{2}-/, "")
          cl.xpath("./section").each_with_index do |sec, idx_sec|
            section_id = sec[:id]
            instructors = []
            sec.xpath("./instructors/instructor").each do |inst|
              sunet = inst[:sunetid]
              name = inst.text
              name = sunet if inst.text.blank?
              instructors << { sunet: sunet, name: name }
            end

            if instructors.present?
              yield Course.new(
                title: course_title,
                term: term,
                cid: class_id,
                cids: cids,
                sid: section_id,
                instructors: instructors
              )
            end
          end
        end
      end
    end
  end

  # Adding JSON processing
  # Will replace load_xml_from_coursework.  Now loads JSON files generated from MAIS course term and course API requests
  def load_from_coursework
    if Rails.env.test?
      return [JSON.parse(File.read("#{Rails.root}/spec/fixtures/course_work.json"))]
    else
      current = Terms.process_term_for_cw(Terms.current_term)
      next_term = Terms.process_term_for_cw(Terms.future_terms.first)
      json_files = []
      ["#{Rails.root}/lib/course_work_content/course_#{current}.json", "#{Rails.root}/lib/course_work_content/course_#{next_term}.json"].each do |url|
        json_files << JSON.parse(File.read(url)) if File.exist?(url)
      end
      return json_files
    end
  end

  # Given JSON representing the information required by a Course object,
  # initialize Course objects
  def process_all_courses(json_files)
    return to_enum(:process_all_courses, json_files) unless block_given?

    # This should be an array of json files being read in
    # For each JSON file, representing a specific term, read in the information
    # and create the objects required by the model
    json_files.each do |json_file|
      json_file.each do |course|
        # Deep transform will also convert the nested instructor hash keys to symbols
        # Symbolized keys are required for the hash to map to the keyword arguments for Course
        course.deep_transform_keys!(&:to_sym)
        yield Course.new(**course) if course[:instructors].present?
      end
    end
  end
end

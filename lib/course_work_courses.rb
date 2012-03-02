require 'nokogiri'
class CourseWorkCourses
  def initialize(xml=nil)
    if xml
      @raw_xml = [Nokogiri::XML(xml)]
    else
      @raw_xml = load_xml_from_coursework
    end
  end
  
  def raw_xml
    @raw_xml ||= self.raw_xml
  end
  
  def find_by_sunet(sunet)
    self.all_courses.map do |course|
      course if course[:instructors].map{|i| i[:sunet]}.include?(sunet)
    end.compact
  end
  
  def find_by_class_id(class_id)
    self.all_courses.map do |course|
      course if course[:cid] == class_id
    end.compact
  end
  
  def find_by_class_id_and_section(class_id, section)
    self.all_courses.map do |course|
      course if course[:cid] == class_id and course[:sid] == section
    end.compact
  end
  
  def find_by_class_id_and_section_and_sunet(class_id, section, sunet)
    self.all_courses.map do |course|
      course if course[:cid] == class_id and course[:sid] == section and course[:instructors].map{|i| i[:sunet]}.include?(sunet)
    end.compact
  end
  
  def all_courses
    # if we end up going w/ a key based hash instead of an array we will need to change this to process_all_courses_xml(self.raw_xml).values
    @all_courses ||= process_all_courses_xml(self.raw_xml)
  end
  
  private
  
  def load_xml_from_coursework
    if Rails.env.test?
      [Nokogiri::XML(File.open("#{Rails.root}/spec/fixtures/course_work.xml", 'r'))]
    else
      [Nokogiri::XML(File.open("#{Rails.root}/lib/course_work_xml/courseXML_F11.xml", 'r')), Nokogiri::XML(File.open("#{Rails.root}/lib/course_work_xml/courseXML_W12.xml", 'r'))]
    end
  end
  
  def process_all_courses_xml(xml_files)
    courses = []
    xml_files.each do |xml|
      xml.xpath("//courseclass").each do |course|
        course_title = course[:title]
        term = course[:term]
        course.xpath("./class").each do |cl|
          class_id = cl[:id].gsub(/^\w{1}\d{2}-/, "")
          cl.xpath("./section").each do |sec|
            section_id = sec[:id]
            instructors = []
            sec.xpath("./instructors/instructor").each do |inst|
              instructors << {:sunet=>inst[:sunetid], :name => inst.text}
            end
            unless instructors.blank?
              # could make courses a hash and assign this hash to the a key for quick lookup.
              # if class_id + instructor is what really makes a unique course an instructor, this will need to be in the unstructor loop above.
              # once we have this key, we can do an unless courses.has_key?("#{class_id}-#{inst[:sunetid]}".to_sym) or unless courses.has_key?("#{term}-#{class_id}-#{section_id}".to_sym)
              courses << {:title       => course_title,
                          :term        => term,
                          :cid         => class_id,
                          :sid         => section_id,
                          :instructors => instructors}
            end
          end        
        end
      end
    end
    return courses
  end
  
end
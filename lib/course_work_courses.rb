require 'nokogiri'
class CourseWorkCourses
  def initialize(xml)
    # Need to load XML.  For now, we'll load from the fixtures directory.
  end
  
  def raw_xml
    @raw_xml ||= Nokogiri::XML(File.open("#{Rails.root}/spec/fixtures/course_work.xml", 'r'))
  end
  
  def find_by_sunet(sunet)
    self.all_courses.map do |course|
      course if course[:instructors].map{|i| i[:sunet]}.include?(sunet)
    end.compact
  end
  
  def all_courses
    @all_course ||= process_all_courses_xml(self.raw_xml)
  end
  
  
  private
  
  def process_all_courses_xml(xml)
    courses = []
    xml.xpath("//courseclass").each do |course|
      course_title = course[:title]      
      course.xpath("./class").each do |cl|
        class_id = cl[:id]
        cl.xpath("./section").each do |sec|
          section_id = sec[:id]
          instructors = []
          sec.xpath("./instructors/instructor").each do |inst|
            instructors << {:sunet=>inst[:sunetid], :name => inst.text}
          end
          courses << { :title=>course_title, 
                       :cid => class_id,
                       :sid => section_id,
                       :instructors => instructors
                     }
        end        
      end
    end
    return courses
  end
  
end
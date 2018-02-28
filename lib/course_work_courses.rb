require 'nokogiri'
require 'terms'
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
  
  def find_by_compound_key(key)
    self.all_courses.map do |course|
      course if course[:comp_key] == key
    end.compact
  end
  
  def find_by_class_id_and_section(class_id, section)
    self.all_courses.map do |course|
      course if course[:cid] == class_id and course[:sid] == section
    end.compact
  end

  def find_by_class_id_and_sunet(class_id, sunet)
    self.all_courses.map do |course|
      course if course[:cid] == class_id and course[:instructors].map{|i| i[:sunet]}.include?(sunet)
    end.compact
  end
  
  def find_by_class_id_and_section_and_sunet(class_id, section, sunet)
    self.all_courses.map do |course|
      course if course[:cid] == class_id and course[:sid] == section and course[:instructors].map{|i| i[:sunet]}.include?(sunet)
    end.compact
  end
  
  def all_courses
    @all_courses ||= process_all_courses_xml(self.raw_xml).values
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
        xml << Nokogiri::XML(File.open(url, 'r')) if File.exists?(url)
      end
      return xml
    end
  end
  
  def process_all_courses_xml(xml_files)
    courses = {}
    xml_files.each do |xml|
      xml.xpath("//courseclass").each do |course|
        course_title = course[:title]
        term = course[:term]
        cids = []
        course.xpath("./class").each do |cl|
          cids << cl[:id].gsub(/^\w{1,2}\d{2}-/, "")
        end
        course.xpath("./class").each do |cl|
          class_id = cl[:id].gsub(/^\w{1,2}\d{2}-/, "")
          cl.xpath("./section").each do |sec|
            section_id = sec[:id]
            instructors = []
            sec.xpath("./instructors/instructor").each do |inst|
              sunet = inst[:sunetid]
              name = inst.text
              name = sunet if inst.text.blank?
              instructors << {:sunet => sunet, :name => name}
            end
            unless instructors.blank?
              instructor_sunets = instructors.map{|i| i[:sunet]}.sort
              key = "#{class_id}-#{instructor_sunets.join("-")}".to_sym
              compound_key = "#{cids.sort.join(",")},#{instructor_sunets.join(",")}"
              cross_listings = cids.map{|c| c unless c == class_id}.compact.join(", ")
              # Not sure if we need this twice or can do a more complicated if logic
              if courses.has_key?(key) and courses[key][:term] == term and section_id == "01"
                courses[key] = {:title          => course_title,
                                :term           => term,
                                :comp_key       => compound_key,
                                :cross_listings => cross_listings,
                                :cid            => class_id,
                                :sid            => section_id,
                                :instructors    => instructors}                
              else
                courses[key] = {:title          => course_title,
                                :term           => term,
                                :comp_key       => compound_key,
                                :cross_listings => cross_listings,
                                :cid            => class_id,
                                :sid            => section_id,
                                :instructors    => instructors}
              end
            end
          end        
        end
      end
    end
    return courses
  end
  
end

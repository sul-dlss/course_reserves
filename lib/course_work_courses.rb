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
      instructors.map { |i| i[:sunet] }.compact.sort
    end

    def instructor_names
      instructors.map { |i| i[:name] }.compact.sort
    end

    def cross_listings
      cids.reject { |c| c == cid }.join(", ")
    end
  end

  def self.instance
    @instance ||= CourseWorkCourses.new
  end

  def initialize(xml = nil)
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
    self.all_courses.select do |course|
      course.comp_key == key
    end
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
  def all_courses
    @all_courses ||= process_all_courses_xml(self.raw_xml).to_a.reverse.uniq(&:key).reverse.to_a
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
end

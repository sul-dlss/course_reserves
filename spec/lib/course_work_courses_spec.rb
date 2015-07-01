require 'spec_helper'
require "course_work_courses"
describe "CourseWorkCourses" do
  before(:all) do
    @courses = CourseWorkCourses.new
  end

  describe "loading raw XML" do
    it "should be a Nokogiri XML Document" do
      @courses.raw_xml.each do |xml|
        expect(xml).to be_a_kind_of(Nokogiri::XML::Document)
      end
    end
    it "should load XML when provided on object initialization" do
      courses = CourseWorkCourses.new('<rsponse><courseclass title="MyTitle"><class id="CLASS-ID"><section id="01"><instructors><instructor sunetid="mysunet">My Teacher</instructor></instructors></section></class></courseclass></response>').all_courses
      expect(courses.length).to eq(1)
      expect(courses.first[:cid]).to eq("CLASS-ID")
      expect(courses.first[:sid]).to eq("01")
    end
  end
  
  describe "listing all courses" do
    before(:each) do
      @course_list = @courses.all_courses
    end
    it "should have all 7 courses in fixture XML" do
      expect(@course_list.length).to eq(7)
    end
    it "should countain the 3 different course titles from the fixture XML" do
      course_titles = @course_list.map{|c| c[:title] }.uniq
      expect(course_titles.length).to eq(3)
      expect(course_titles).to eq(["Residential Racial Segregation and the Education of African-American Youth", "Global Positioning Systems", "Art/Hist Cross Listed Course"])
    end
  end
  
  describe "finders" do
    describe "by SUNet ID" do
      it "should return the subset of courses for the SUNet ID w/ fewer courses" do
        courses_456 = @courses.find_by_sunet("456")
        expect(courses_456.length).to eq(2)
        expect(courses_456.map{|c| c[:title]}).to eq(["Residential Racial Segregation and the Education of African-American Youth", "Global Positioning Systems"])
      end
      it "should return the subset of courses for the SUNet ID that is an instructor for all courses" do
        courses_123 = @courses.find_by_sunet("123")
        expect(courses_123.length).to eq(5)
        expect(courses_123.map{|c| c[:title]}.uniq).to eq(["Residential Racial Segregation and the Education of African-American Youth", "Global Positioning Systems"])
      end
      it "should be blank when a course doesn't exist with the specified SUNet" do
        expect(@courses.find_by_sunet("no-sunet")).to be_blank
      end
    end
  
    describe "by class id" do
      it "should return the appropriate course when passing a class id" do
        two_section_course = @courses.find_by_class_id("EDUC-237X")
        expect(two_section_course.length).to eq(2)
        expect(two_section_course.map{|c| "#{c[:cid]}-#{c[:sid]}"}).to eq(["EDUC-237X-01", "EDUC-237X-02"])
      end
      it "should be blank when a course doesn't exist with the specified class id" do
        expect(@courses.find_by_class_id("DOES-NOT-EXIST")).to be_blank
      end
    end
  
    describe "by class id and section" do
      it "should return the appropriate course when passing a class id and section id" do
        course = @courses.find_by_class_id_and_section("EDUC-237X", "01")
        expect(course.length).to eq(1)
        expect(course.first[:title]).to eq("Residential Racial Segregation and the Education of African-American Youth")
        expect(course.first[:cid]).to eq("EDUC-237X")
        expect(course.first[:sid]).to eq("01")
      end
      it "should be blank when the class id doesn't exist" do
        expect(@courses.find_by_class_id_and_section("DOES-NOT-EXIST", "01")).to be_blank
      end
      it "should be blank when the class id is valid but not the section" do
        expect(@courses.find_by_class_id_and_section("EDUC-237X", "03")).to be_blank
      end
    end
    
    describe "find by class id and sunet" do
      it "should return the appropriate course when passing a class id and sunet" do
        course = @courses.find_by_class_id_and_sunet("EDUC-237X", "456")
        expect(course.length).to eq(1)
        expect(course.first[:title]).to eq("Residential Racial Segregation and the Education of African-American Youth")
        expect(course.first[:cid]).to eq("EDUC-237X")
      end
      it "should be blank when the class id doesn't exist" do
        expect(@courses.find_by_class_id_and_sunet("NOT-A-COURSE", "456")).to be_blank
      end
      it "should be blank when the provided sunet isn't in the course" do
        expect(@courses.find_by_class_id_and_sunet("EDUC-237X", "654")).to be_blank
      end
    end
    
    describe "by class id, section, and SUNet ID" do
      it "should return the appripriate course when passing all valid information" do
        course = @courses.find_by_class_id_and_section_and_sunet("EDUC-237X", "01", "123")
        expect(course.length).to eq(1)
        expect(course.first[:title]).to eq("Residential Racial Segregation and the Education of African-American Youth")
        expect(course.first[:cid]).to eq("EDUC-237X")
        expect(course.first[:sid]).to eq("01")
        expect(course.first[:instructors].map{|i| i[:sunet] }).to include("123")
      end
      it "should return blank when the class id does not exist" do
        expect(@courses.find_by_class_id_and_section_and_sunet("DOES-NOT-EXIST", "01", "123")).to be_blank
      end
      it "should return blank when the section does not exist for the given class id" do
        expect(@courses.find_by_class_id_and_section_and_sunet("EDUC-237X", "03", "123")).to be_blank
      end
      it "should return blank when the section SUNet isn't an instructor in for the given course id and section" do
        expect(@courses.find_by_class_id_and_section_and_sunet("EDUC-237X", "02", "456")).to be_blank
      end
    end
    
  end
  
  describe "XML processing" do
    it "should not add a course that doesn't have an instructor" do
      expect(CourseWorkCourses.new("<response><courseclass term='WINTER'><section id='01'></section></courseclass></response>").all_courses).to be_blank
    end
    it "should remove term prefix on class id" do
      @courses.all_courses.each do |c|
        expect(c[:cid]).not_to match(/W12/)
      end
    end
    it "should return the intructor SUNet as name if there is no name in the XML" do
      course = CourseWorkCourses.new('<rsponse><courseclass title="MyTitle"><class id="CLASS-ID"><section id="01"><instructors><instructor sunetid="mysunet"></instructor></instructors></section></class></courseclass></response>').all_courses.first
      expect(course[:instructors].first[:sunet]).to eq("mysunet")
      expect(course[:instructors].first[:name]).to eq("mysunet")
    end
    it "should de-dup courses on the same class id and normalized sunets" do
      course = @courses.find_by_class_id("AA-272C")
      expect(course.length).to eq(1)
      expect(course.first[:title]).to eq("Global Positioning Systems")
      expect(course.first[:sid]).to eq("01")
    end
    it "should compute the compound key correctly" do
      course = @courses.find_by_class_id("ART-102")
      expect(course.length).to eq(1)
      expect(course.first[:cid]).to eq("ART-102")
      expect(course.first[:comp_key]).to eq("ART-102,HIST-201,789")
      expect(course.first[:cross_listings]).to eq("HIST-201")
    end
    it "should computer the cross listed courses properly" do
      course = @courses.find_by_class_id("HIST-201")
      expect(course.length).to eq(1)
      expect(course.first[:cid]).to eq("HIST-201")
      expect(course.first[:comp_key]).to eq("ART-102,HIST-201,789")
      expect(course.first[:cross_listings]).to eq("ART-102")
    end
  end
  
end

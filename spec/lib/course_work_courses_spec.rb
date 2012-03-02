require 'spec_helper'
require "course_work_courses"
describe "CourseWorkCourses" do
  before(:all) do
    @courses = CourseWorkCourses.new
  end

  describe "loading raw XML" do
    it "should be a Nokogiri XML Document" do
      @courses.raw_xml.each do |xml|
        xml.is_a?(Nokogiri::XML::Document).should be_true
      end
    end
    it "should load XML when provided on object initialization" do
      courses = CourseWorkCourses.new('<rsponse><courseclass title="MyTitle"><class id="CLASS-ID"><section id="01"><instructors><instructor sunetid="mysunet">My Teacher</instructor></instructors></section></class></courseclass></response>').all_courses
      courses.length.should == 1
      courses.first[:cid].should == "CLASS-ID"
      courses.first[:sid].should == "01"
    end
  end
  
  describe "listing all courses" do
    before(:each) do
      @course_list = @courses.all_courses
    end
    it "should have all 5 courses in fixture XML" do
      @course_list.length.should == 5
    end
    it "should countain the 2 different course titles from the fixture XML" do
      course_titles = @course_list.map{|c| c[:title] }.uniq
      course_titles.length.should == 2
      course_titles.should == ["Residential Racial Segregation and the Education of African-American Youth", "Global Positioning Systems"]
    end
  end
  
  describe "finders" do
    describe "by SUNet ID" do
      it "should return the subset of courses for the SUNet ID w/ fewer courses" do
        courses_456 = @courses.find_by_sunet("456")
        courses_456.length.should == 2
        courses_456.map{|c| c[:title]}.should == ["Residential Racial Segregation and the Education of African-American Youth", "Global Positioning Systems"]
      end
      it "should return the subset of courses for the SUNet ID that is an instructor for all courses" do
        courses_123 = @courses.find_by_sunet("123")
        courses_123.length.should == 5
        courses_123.map{|c| c[:title]}.uniq.should == ["Residential Racial Segregation and the Education of African-American Youth", "Global Positioning Systems"]
      end
      it "should be blank when a course doesn't exist with the specified SUNet" do
        @courses.find_by_sunet("no-sunet").should be_blank
      end
    end
  
    describe "by class id" do
      it "should return the appropriate course when passing a class id" do
        two_section_course = @courses.find_by_class_id("EDUC-237X")
        two_section_course.length.should == 2
        two_section_course.map{|c| "#{c[:cid]}-#{c[:sid]}"}.should == ["EDUC-237X-01", "EDUC-237X-02"]
      end
      it "should be blank when a course doesn't exist with the specified class id" do
        @courses.find_by_class_id("DOES-NOT-EXIST").should be_blank
      end
    end
  
    describe "by class id and section" do
      it "should return the appropriate course when passing a class id and section id" do
        course = @courses.find_by_class_id_and_section("EDUC-237X", "01")
        course.length.should == 1
        course.first[:title].should == "Residential Racial Segregation and the Education of African-American Youth"
        course.first[:cid].should == "EDUC-237X"
        course.first[:sid].should == "01"
      end
      it "should be blank when the class id doesn't exist" do
        @courses.find_by_class_id_and_section("DOES-NOT-EXIST", "01").should be_blank
      end
      it "should be blank when the class id is valid but not the section" do
        @courses.find_by_class_id_and_section("EDUC-237X", "03").should be_blank
      end
    end
    
    describe "by class id, section, and SUNet ID" do
      it "should return the appripriate course when passing all valid information" do
        course = @courses.find_by_class_id_and_section_and_sunet("EDUC-237X", "01", "123")
        course.length.should == 1
        course.first[:title].should == "Residential Racial Segregation and the Education of African-American Youth"
        course.first[:cid].should == "EDUC-237X"
        course.first[:sid].should == "01"
        course.first[:instructors].map{|i| i[:sunet] }.include?("123").should be_true
      end
      it "should return blank when the class id does not exist" do
        @courses.find_by_class_id_and_section_and_sunet("DOES-NOT-EXIST", "01", "123").should be_blank
      end
      it "should return blank when the section does not exist for the given class id" do
        @courses.find_by_class_id_and_section_and_sunet("EDUC-237X", "03", "123").should be_blank
      end
      it "should return blank when the section SUNet isn't an instructor in for the given course id and section" do
        @courses.find_by_class_id_and_section_and_sunet("EDUC-237X", "02", "456").should be_blank
      end
    end
    
  end
  
  describe "XML processing" do
    it "should not add a course that doesn't have an instructor" do
      CourseWorkCourses.new("<response><courseclass term='WINTER'><section id='01'></section></courseclass></response>").all_courses.should be_blank
    end
    it "should remove term prefix on class id" do
      @courses.all_courses.each do |c|
        c[:cid].should_not match(/W12/)
      end
    end
  end
  
end
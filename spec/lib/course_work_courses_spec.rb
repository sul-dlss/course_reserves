require 'spec_helper'
require "course_work_courses"
describe "CourseWorkCourses" do
  before(:all) do
    @courses = CourseWorkCourses.new("xml")
  end
  describe "raw xml from course works" do
    it "should be a Nokogiri XML Document" do
      @courses.raw_xml.is_a?(Nokogiri::XML::Document).should be_true
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
  
  describe "getting a course by SUNet ID" do
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
  end
  
end
require 'rails_helper'
require 'course_api'

RSpec.describe CourseAPI do
  let(:course_term) { CourseAPI.new(File.read("#{Rails.root}/spec/fixtures/course_term.xml")) }
  let(:courses) {course_term.parse_courses()}
  let(:sections) {course_term.parse_sections(File.read("#{Rails.root}/spec/fixtures/course_individual.xml"))}

  describe "course term XML processing" do    
    it "retrieves correct number of courses from course term XML" do
      expect(courses.length).to eq(2)
    end
    it "reads in course id as expected" do
      expect(courses[0]).to have_key(:cid)
      expect(courses[0][:cid]).to eq("SPEC-802")
      expect(courses[1]).to have_key(:cid)
      expect(courses[1][:cid]).to eq("MGTECON-300")
    end

  end

  describe "individual course XML processing" do    
    it "does not add a course that doesn't have an instructor" do
      expect(sections.length).to eq(1)
    end
    it "reads in information about the section with instructors as expected" do
      expect(sections[0]).to have_key(:instructors)
      expect(sections[0][:instructors].length).to eq(1)
      expect(sections[0][:instructors][0]).to have_key(:sunet)
      expect(sections[0][:instructors][0][:sunet]).to eq("test instructor")
      expect(sections[0][:instructors][0]).to have_key(:name)
      expect(sections[0][:instructors][0][:name]).to eq("Instructor, Test")
    end
  end

end

require 'rails_helper'
require 'course_api'

RSpec.describe CourseAPI do
  let(:course_term) { described_class.new }
  let(:courses) { course_term.parse_courses(Rails.root.join("spec/fixtures/course_term.xml").read) }
  let(:sections) { course_term.parse_sections(Rails.root.join("spec/fixtures/course_individual.xml").read, "1236-PEDS-199") }

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

  describe "processing term info" do
    it "converts a string term to the correct course term API URL" do
      expect(course_term.courseterm_url("Spring 2023")).to eq("/doc/courseterm/1236")
      expect(course_term.courseterm_url("Fall 2017")).to eq("/doc/courseterm/1182")
    end

    it "parses a term id to get the string term" do
      expect(course_term.generate_term("1236")).to eq("Spring 2023")
      expect(course_term.generate_term("1182")).to eq("Fall 2017")
    end
  end
end

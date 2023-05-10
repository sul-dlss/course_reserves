require 'rails_helper'
require 'course_api'

RSpec.describe CourseAPI do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:conn) { Faraday.new { |b| b.adapter(:test, stubs) } }
  let(:course_api_client) { described_class.new(conn) }

  describe "retrieve course information based on course term and individual courses" do
    before do
      stubs.get('/doc/courseterm/1236') do
        [200, { 'Content-Type': 'application/xml' }, Rails.root.join("spec/fixtures/course_term.xml").read]
      end
      stubs.get('/doc/courseclass/1236-SPEC-802') do
        [200, { 'Content-Type': 'application/xml' }, Rails.root.join("spec/fixtures/course_spec802.xml").read]
      end
      stubs.get('/doc/courseclass/1236-MGTECON-300') do
        [200, { 'Content-Type': 'application/xml' }, Rails.root.join("spec/fixtures/course_individual.xml").read]
      end
    end

    let(:courses) { course_api_client.courses_for_term("Spring 2023")[:courses] }

    it "retrieves correct number of courses from course term XML" do
      puts courses.to_json
      expect(courses.length).to eq(2)
    end

    it "reads in course id as expected" do
      expect(courses[0]).to have_key(:cid)
      expect(courses[0][:cid]).to eq("SPEC-802")
      expect(courses[1]).to have_key(:cid)
      expect(courses[1][:cid]).to eq("MGTECON-300")
    end

    it "adds only section ids with instructors" do
      expect(courses[0][:sid]).to eq("345")
      expect(courses[1][:sid]).to eq("412")
    end

    it "reads in information about the first course's instructors as expected" do
      expect(courses[0]).to have_key(:instructors)
      expect(courses[0][:instructors].length).to eq(1)
      expect(courses[0][:instructors][0]).to have_key(:sunet)
      expect(courses[0][:instructors][0][:sunet]).to eq("test instructor")
      expect(courses[0][:instructors][0]).to have_key(:name)
      expect(courses[0][:instructors][0][:name]).to eq("Instructor, Test")
    end

    it "reads in information about the seconds course's instructors as expected" do
      expect(courses[1]).to have_key(:instructors)
      expect(courses[1][:instructors].length).to eq(1)
      expect(courses[1][:instructors][0]).to have_key(:sunet)
      expect(courses[1][:instructors][0][:sunet]).to eq("best professor")
      expect(courses[1][:instructors][0]).to have_key(:name)
      expect(courses[1][:instructors][0][:name]).to eq("Professor, Best")
    end
  end
end

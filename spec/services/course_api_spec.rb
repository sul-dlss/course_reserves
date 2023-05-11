require 'rails_helper'

RSpec.describe CourseApi do
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

    it "retrieves the correct objects with keys and values" do
      expect(courses.length).to eq(2)
      expect(courses[0]).to include(
        cid: "SPEC-802",
        sid: "345",
        instructors: [hash_including(
          sunet: "test instructor",
          name: "Instructor, Test"
        )]
      )
      expect(courses[1]).to include(
        cid: "MGTECON-300",
        sid: "412",
        instructors: [hash_including(
          sunet: "best professor",
          name: "Professor, Best"
        )]
      )
    end
  end
end

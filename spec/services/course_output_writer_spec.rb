require 'rails_helper'

RSpec.describe CourseOutputWriter do
  describe "Creating a file based on term and saving output" do
    let(:courses_list) do
      [
        { title: "Graduation Quarter", term: "Spring 2023",
          cid: "SPEC-802", cids: ["SPEC-802"], sid: "01",
          instructors: [{ sunet: "testinst", name: "Instructor, Test" }] }
      ]
    end
    let(:course_writer) do
      described_class.new("Sp23", courses_list)
    end
    let(:filename) { Rails.root.join("lib/course_work_content/course_Sp23.json").to_s }

    it "outputs a JSON file with the correct filename" do
      expect(File).to receive(:write).with(filename, courses_list.to_json)
      course_writer.write
    end
  end
end

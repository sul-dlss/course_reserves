require 'rails_helper'
require "course_work_courses"
# This has been updated to focus on JSON loading and not XML
RSpec.describe CourseWorkCourses do
  let(:courses) { CourseWorkCourses.new }

  describe "loading JSON from fixture file" do
    it "is an array of JSON arrays where each object has certain attributes" do
      courses.json_files.each do |json_file|
        expect(json_file).not_to be_empty
        json_file.each do |j_obj|
          expect(j_obj).to include("title", "cid", "cids", "sid", "instructors")
        end
      end
    end

    it "loads JSON when provided on object initialization" do
      init_courses = CourseWorkCourses.new('[{"title":"MyTitle","term":null,"cid":"CLASS-ID","cids":["CLASS-ID"],"sid":"01","instructors":[{"sunet":"mysunet","name":"My Teacher"}]}]').all_courses
      expect(init_courses.length).to eq(1)
      expect(init_courses[0]).to have_attributes(title: "MyTitle", cid: "CLASS-ID", cids: ["CLASS-ID"], sid: "01", instructors: [hash_including(sunet: "mysunet", name: "My Teacher")])
    end
  end

  describe "#all_courses" do
    subject(:course_list) { courses.all_courses }

    it "has all 7 courses in fixture JSON" do
      expect(course_list.length).to eq(7)
    end

    it "countains the 3 different course titles from the fixture JSON" do
      course_titles = course_list.map { |c| c.title }.uniq
      expect(course_titles.length).to eq(3)
      expect(course_titles).to eq(["Residential Racial Segregation and the Education of African-American Youth", "Global Positioning Systems",
                                   "Art/Hist Cross Listed Course"])
    end
  end

  describe '#course_map' do
    subject(:course_map) { courses.course_map }

    it 'is a hash of all courses indexed by the compound key (for efficient lookup)' do
      expect(course_map.keys).to eq [
        'AFRICAAM-165E,EDUC-237X,ETHICSOC-165E,123,456',
        'AFRICAAM-165E,EDUC-237X,ETHICSOC-165E,123',
        'AA-272C,123,456',
        'ART-102,HIST-201,789'
      ]

      expect(course_map.values.flatten).to all(be_a_kind_of(CourseWorkCourses::Course))
      expect(course_map['AA-272C,123,456'].length).to eq 1
      expect(course_map['ART-102,HIST-201,789'].length).to eq 2
    end
  end

  describe ".find_by_sunet" do
    describe "by SUNet ID" do
      it "returns the subset of courses for the SUNet ID w/ fewer courses" do
        courses_456 = courses.find_by_sunet("456")
        expect(courses_456.length).to eq(2)
        expect(courses_456.map do |c|
                 c.title
               end).to eq(["Residential Racial Segregation and the Education of African-American Youth", "Global Positioning Systems"])
      end

      it "returns the subset of courses for the SUNet ID that is an instructor for all courses" do
        courses_123 = courses.find_by_sunet("123")
        expect(courses_123.length).to eq(5)
        expect(courses_123.map do |c|
                 c.title
               end.uniq).to eq(["Residential Racial Segregation and the Education of African-American Youth", "Global Positioning Systems"])
      end

      it "is blank when a course doesn't exist with the specified SUNet" do
        expect(courses.find_by_sunet("no-sunet")).to be_blank
      end
    end

    describe ".find_by_class_id" do
      it "returns the appropriate course when passing a class id" do
        two_section_course = courses.find_by_class_id("EDUC-237X")
        expect(two_section_course.length).to eq(2)
        expect(two_section_course.map { |c| "#{c.cid}-#{c.sid}" }).to eq(["EDUC-237X-01", "EDUC-237X-02"])
      end

      it "is blank when a course doesn't exist with the specified class id" do
        expect(courses.find_by_class_id("DOES-NOT-EXIST")).to be_blank
      end
    end

    describe ".find_by_class_id_and_section" do
      it "returns the appropriate course when passing a class id and section id" do
        course = courses.find_by_class_id_and_section("EDUC-237X", "01")
        expect(course.length).to eq(1)
        expect(course.first.title).to eq("Residential Racial Segregation and the Education of African-American Youth")
        expect(course.first.cid).to eq("EDUC-237X")
        expect(course.first.sid).to eq("01")
      end

      it "is blank when the class id doesn't exist" do
        expect(courses.find_by_class_id_and_section("DOES-NOT-EXIST", "01")).to be_blank
      end

      it "is blank when the class id is valid but not the section" do
        expect(courses.find_by_class_id_and_section("EDUC-237X", "03")).to be_blank
      end
    end

    describe "find by class id and sunet" do
      it "returns the appropriate course when passing a class id and sunet" do
        course = courses.find_by_class_id_and_sunet("EDUC-237X", "456")
        expect(course.length).to eq(1)
        expect(course.first.title).to eq("Residential Racial Segregation and the Education of African-American Youth")
        expect(course.first.cid).to eq("EDUC-237X")
      end

      it "is blank when the class id doesn't exist" do
        expect(courses.find_by_class_id_and_sunet("NOT-A-COURSE", "456")).to be_blank
      end

      it "is blank when the provided sunet isn't in the course" do
        expect(courses.find_by_class_id_and_sunet("EDUC-237X", "654")).to be_blank
      end
    end

    describe "by class id, section, and SUNet ID" do
      it "returns the appripriate course when passing all valid information" do
        course = courses.find_by_class_id_and_section_and_sunet("EDUC-237X", "01", "123")
        expect(course.length).to eq(1)
        expect(course.first.title).to eq("Residential Racial Segregation and the Education of African-American Youth")
        expect(course.first.cid).to eq("EDUC-237X")
        expect(course.first.sid).to eq("01")
        expect(course.first.instructors.pluck(:sunet)).to include("123")
      end

      it "returns blank when the class id does not exist" do
        expect(courses.find_by_class_id_and_section_and_sunet("DOES-NOT-EXIST", "01", "123")).to be_blank
      end

      it "returns blank when the section does not exist for the given class id" do
        expect(courses.find_by_class_id_and_section_and_sunet("EDUC-237X", "03", "123")).to be_blank
      end

      it "returns blank when the section SUNet isn't an instructor in for the given course id and section" do
        expect(courses.find_by_class_id_and_section_and_sunet("EDUC-237X", "02", "456")).to be_blank
      end
    end
  end

  describe "JSON processing" do
    it "does not add a course that doesn't have an instructor" do
      expect(CourseWorkCourses.new('[{"title":"MyTitle","term":"WINTER","sid":"01"}]').all_courses).to be_blank
    end

    it "removes term prefix on class id" do
      courses.all_courses.each do |c|
        expect(c.cid).not_to match(/W12/)
      end
    end

    it "de-dups courses on the same class id and normalized sunets" do
      course = courses.find_by_class_id("AA-272C")
      expect(course.length).to eq(1)
      expect(course.first.title).to eq("Global Positioning Systems")
      expect(course.first.sid).to eq("01")
    end

    it "computes the compound key correctly" do
      course = courses.find_by_class_id("ART-102")
      expect(course.length).to eq(1)
      expect(course.first.cid).to eq("ART-102")
      expect(course.first.comp_key).to eq("ART-102,HIST-201,789")
      expect(course.first.cross_listings).to eq("HIST-201")
    end

    it "computers the cross listed courses properly" do
      course = courses.find_by_class_id("HIST-201")
      expect(course.length).to eq(1)
      expect(course.first.cid).to eq("HIST-201")
      expect(course.first.comp_key).to eq("ART-102,HIST-201,789")
      expect(course.first.cross_listings).to eq("ART-102")
    end
  end
end

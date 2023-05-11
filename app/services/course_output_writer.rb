# Write out output from Course APIs to a JSON file to be read in by the app
class CourseOutputWriter
  # Called on CourseOutputWriter.new
  def initialize(file_term, courses)
    @file_term = file_term
    @courses = courses
  end

  # Generate the file name to use based on term input
  def write
    file_name = "course_#{@file_term}.json"
    # Write the JSON to the course_work_content folder where the app will pick it up later
    Rails.root.join("lib/course_work_content", file_name).write(@courses.to_json)
  end
end

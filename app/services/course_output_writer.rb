# Write out output from Course APIs to a JSON file to be read in by the app
class CourseOutputWriter
  # Called on CourseOutputWriter.new
  def initialize(file_term, courses)
    @file_term = file_term
    @courses = courses
  end

  # Providing parameter for connection enables testing with Faraday connection stub
  def write
    file_name = "course_#{@file_term}.json"
    # Write the JSON to the course_work_content folder where the app will pick it up later
    File.write("#{Rails.root}/lib/course_work_content/#{file_name}", @courses.to_json)
  end
end

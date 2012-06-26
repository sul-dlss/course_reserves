require "course_work_courses"
require "terms"
include Terms
CourseReserves::Application.config.courses = CourseWorkCourses.new
CourseReserves::Application.config.courses.all_courses
if future_terms.length != 2 or current_term.blank?
  Report.msg(:to=>"searchworks-reports@lists.stanford.edu", :subject => "Issue with CourseReserves terms.", :message=>"There is an issue with the terms in the Course Reserves form. The current term is #{current_term.inspect} and the future terms are: #{future_terms.inspect}").deliver
end
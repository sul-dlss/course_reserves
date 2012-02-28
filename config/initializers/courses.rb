require "course_work_courses"
CourseReserves::Application.config.courses = CourseWorkCourses.new
CourseReserves::Application.config.courses.all_courses

require "course_work_courses"
require "terms"

if Terms.future_terms.length != 2 or Terms.current_term.blank?
  ReportMailer.msg(to: "searchworks-reports@lists.stanford.edu", subject: "Issue with CourseReserves terms.", :message=>"There is an issue with the terms in the Course Reserves form. The current term is #{Terms.current_term.inspect} and the future terms are: #{Terms.future_terms.inspect}").deliver_now
end

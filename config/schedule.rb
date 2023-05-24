every :day, :at => '3:30am', :roles => [:app] do
  rake "fetch_courses"
end

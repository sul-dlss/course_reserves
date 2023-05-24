every :day, :at => '4:30am', :roles => [:app] do
  rake "fetch_courses"
end

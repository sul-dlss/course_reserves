require "terms"
require 'faraday'
desc "rake task to fetch XML from CourseWork"
task fetch_xml: :environment do
  term1 = Terms.process_term_for_cw(Terms.current_term)
  term2 = Terms.process_term_for_cw(Terms.future_terms.first)
  errors = ""
  updated = false
  [coursework_url(term1),coursework_url(term2)].each do |url|
    response = Faraday.get(url)
    if response.status == 200
      file_name = url[/coursereserves\/(.*)$/,1]
      File.open("#{Rails.root}/lib/course_work_xml/#{file_name}", "w") do |f|
        f.write(response.body.to_s.force_encoding('UTF-8'))
      end
      updated = true
    else
      errors << "#{url} returned #{response.status}\n"
    end
  end
  Report.msg(to: Settings.email.reports, subject: "Problem downloading XML file(s) from CourseWork", message: errors).deliver_now unless errors.blank?
  %x[touch tmp/restart.txt] if updated
end

def coursework_url(term)
  Settings.courseworks.coursexml_url % { term: term }
end

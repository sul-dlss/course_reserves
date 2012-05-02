require "terms"
require 'net/http'
include Terms
desc "rake task to fetch XML from CourseWork"
task :fetch_xml => :environment do
  term1 = process_term_for_cw(current_term)
  term2 = process_term_for_cw(future_terms.first)
  errors = ""
  updated = false
  [coursework_url(term1),coursework_url(term2)].each do |url|
    cw_url = URI.parse(url)
    http = Net::HTTP.new(cw_url.host, cw_url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(cw_url.request_uri)
    response = http.request(request)
    if response.code == "200"
      file_name = url[/public\/(.*)$/,1]
      File.open("#{Rails.root}/lib/course_work_xml/#{file_name}", "w") do |f|
        f.write(response.body)
      end
      updated = true
    else
      errors << "#{url} returned #{response.code}\n"
    end
  end
  Report.msg(:to=>"searchworks-ops@lists.stanford.edu", :subject => "Problem downloading XML file(s) from CourseWork", :message => errors).deliver unless errors.blank?
  %x[touch tmp/restart.txt] if updated
end

def coursework_url(term)
  "https://coursework.stanford.edu/access/content/public/courseXML_#{term}.xml"
end
class Report < ActionMailer::Base
  default from: "no-reply@reserves.stanford.edu"
  
  def msg(opts={})
    @txt = opts[:message] || ""
    mail(:to => opts[:to], :subject => opts[:subject])
  end
end

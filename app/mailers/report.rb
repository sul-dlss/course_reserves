class Report < ActionMailer::Base
  default from: Settings.email.from

  def msg(opts = {})
    @txt = opts[:message] || ""
    mail(to: opts[:to], subject: opts[:subject])
  end
end

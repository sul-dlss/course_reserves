class Report < ApplicationMailer
  default from: Settings.email.from

  def msg(opts = {})
    @txt = opts[:message] || ""
    mail(to: opts[:to], subject: opts[:subject])
  end
end

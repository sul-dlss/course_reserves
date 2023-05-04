class Report < ApplicationMailer
  def msg(opts = {})
    @txt = opts[:message] || ""
    mail(to: opts[:to], subject: opts[:subject])
  end
end

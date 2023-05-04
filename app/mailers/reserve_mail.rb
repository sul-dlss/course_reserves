class ReserveMail < ApplicationMailer
  default from: Settings.email.from

  def submit_request(reserve, address, current_user)
    @reserve = reserve
    @current_user = current_user
    mail(to: address, subject: "#{reserve.has_been_sent ? 'Updated' : 'New'} Reserve Form: #{reserve.cid}-#{reserve.sid} - #{reserve.term}")
  end
end

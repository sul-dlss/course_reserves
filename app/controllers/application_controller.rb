class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    if request.env['REMOTE_USER']
      request.env['REMOTE_USER']
    elsif Rails.env.development? && ENV['REMOTE_USER']
      ENV['REMOTE_USER']
    end
  end
  helper_method(:current_user)

  def superuser?
    privgroups.include?(Settings.workgroups.superuser)
  end

  def privgroups
    if request.env['WEBAUTH_LDAPPRIVGROUP']
      request.env['WEBAUTH_LDAPPRIVGROUP'].split('|')
    elsif Rails.env.development? && ENV['WEBAUTH_LDAPPRIVGROUP']
      ENV['WEBAUTH_LDAPPRIVGROUP'].split('|')
    else
      []
    end
  end
end

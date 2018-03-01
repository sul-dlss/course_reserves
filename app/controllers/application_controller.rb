class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    @current_user ||= CurrentUser.new(remote_user_id, remote_privgroups)
  end
  helper_method(:current_user)

  private

  def remote_user_id
    if request.env['REMOTE_USER']
      request.env['REMOTE_USER']
    elsif Rails.env.development? && ENV['REMOTE_USER']
      ENV['REMOTE_USER']
    end
  end

  def remote_privgroups
    if request.env['WEBAUTH_LDAPPRIVGROUP']
      request.env['WEBAUTH_LDAPPRIVGROUP'].split('|')
    elsif Rails.env.development? && ENV['WEBAUTH_LDAPPRIVGROUP']
      ENV['WEBAUTH_LDAPPRIVGROUP'].split('|')
    else
      []
    end
  end
end

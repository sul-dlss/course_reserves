class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def current_user
    Rails.env.production? ? request.env["WEBAUTH_USER"] : "jkeck"
  end
  
  helper_method(:current_user)
end

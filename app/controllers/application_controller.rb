class ApplicationController < ActionController::Base
  protect_from_forgery
  include Squash::Ruby::ControllerMethods
  enable_squash_client

  def current_user
    Rails.env.production? ? request.env["WEBAUTH_USER"] : "jdoe"
  end
  helper_method(:current_user)

  def superuser?
    Rails.env.production? ? request.env["WEBAUTH_LDAPPRIVGROUP"].include?("sulair:course-resv-admins") : Rails.env.development?
  end

end

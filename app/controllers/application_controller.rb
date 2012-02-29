class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def current_user
    params[:usr] || "jdoe"
  end
  
  helper_method(:current_user)
end

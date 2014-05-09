require Rails.root.join('lib/security_helper')

class ApplicationController < ActionController::Base
  include SecurityHelper
  protect_from_forgery

  # catch access denied and redirect to the home page
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_url
  end

end

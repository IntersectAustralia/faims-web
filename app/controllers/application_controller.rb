class ApplicationController < ActionController::Base
  protect_from_forgery
  # catch access denied and redirect to the home page
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_url
  end

  before_filter :crumbs

  def crumbs
    @crumbs =
      {
          :pages_home => {title: 'Home', url: pages_home_path},
      }
  end

  def project_name

  end


end

class PagesController < ApplicationController
  include UserBreadCrumbs
  before_filter :crumbs

  def home
    page_crumbs :pages_home
    redirect_to project_modules_path if user_signed_in?
  end

end

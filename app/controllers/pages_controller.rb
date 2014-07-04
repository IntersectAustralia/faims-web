class PagesController < ApplicationController
  include UserBreadCrumbs
  before_filter :crumbs

  def home
    page_crumbs :pages_home
    if user_signed_in?
      flash.keep
      redirect_to project_modules_path
    end
  end

end

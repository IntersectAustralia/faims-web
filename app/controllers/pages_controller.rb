class PagesController < ApplicationController
  include UserBreadCrumbs
  before_filter :crumbs

  def home
    page_crumbs :pages_home
  end

end

class PagesController < ApplicationController

  def home
    @page_crumbs = [:pages_home]
  end

end

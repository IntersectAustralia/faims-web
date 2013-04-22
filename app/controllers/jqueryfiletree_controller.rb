class JqueryfiletreeController < ApplicationController
  protect_from_forgery :only => []
  before_filter :authenticate_user!

  def content
    @parent = params[:dir]
    @dir = Jqueryfiletree.new(@parent).get_content
    html = "<ul class='jqueryFileTree' style='display: none;'>"
    @dir[0].each do |dir|
      html += "<li class='directory collapsed'>"
      html += "<a href='#' rel='#{@parent}/#{dir}/'>#{dir}</a></li>"
    end

    @dir[1].each do |file|
      html += "<li class='file ext_#{File.extname(file)[1..-1]}'><a href='#' rel='#{@parent+file}'>#{file}</a></li>"
    end

    html += "</ul>"

    render :text => html
  end
end
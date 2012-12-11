class AndroidController < ApplicationController

  def projects
    render :json => Project.all.to_json
  end

  def archive
    project = Project.find(params[:id])
    info = project.archive_info
    render :json => info.to_json
  end

  def download
    project = Project.find(params[:id])
    send_file project.archive_info[:file]
  end

end

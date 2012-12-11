class AndroidController < ApplicationController

  def projects
    respond_to do |format|
      format.html do
        render :json => Project.all.to_json
      end
      format.json do
        render :json => Project.all.to_json
      end
    end
  end

  def download
    project = Project.find(params[:id])
    send_file Rails.root.join('projects', project.name, 'db.sqlite3')
  end

end

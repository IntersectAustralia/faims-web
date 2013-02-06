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
    send_file Rails.root.join(project_dir, project.archive_info[:file])
  end

  def upload_db
    project = Project.find(params[:id])
    file = params[:file]
    md5 = Digest::MD5.hexdigest(file.read)
    #logger.debug md5
    #logger.debug params[:md5]
    if params[:md5] == md5
      project.merge_database(params[:file])
      render :json => {}.to_json, :status => 200
    else
      render :json => {}.to_json, :status => 400
    end

    # rearchive the project
    project.archive
  end

  private

    def project_dir
      return Rails.env == 'test' ? 'tmp/projects' : 'projects'
    end

end

class AndroidController < ApplicationController

  def projects
    projects = Project.all.map { |p| {key:p.key, name:p.name} }
    render :json => projects.to_json
  end

  def archive
    project = Project.find_by_key(params[:key])
    info = project.archive_info
    render :json => info.to_json
  end

  def download
    project = Project.find_by_key(params[:key])
    send_file project.filepath
  end

  def upload_db
    project = Project.find_by_key(params[:key])
    file = params[:file]
    md5 = params[:md5]
    #logger.debug md5
    #logger.debug params[:md5]
    if project.check_sum(file,md5)
      project.merge_database(file)
      render :json => {}.to_json, :status => 200
    else
      render :json => {}.to_json, :status => 400
    end

    # rearchive the project and database
    project.update_archives
  end

  def archive_db
    project = Project.find_by_key(params[:key])
    info = project.archive_db_info
    render :json => info.to_json
  end

  def download_db
    project = Project.find_by_key(params[:key])
    send_file project.db_file_path
  end

  private

    def project_dir
      return Rails.env == 'test' ? 'tmp/projects' : 'projects'
    end

end

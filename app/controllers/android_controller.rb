class AndroidController < ApplicationController

  before_filter :check_valid_project
  skip_before_filter :check_valid_project, :only => [:projects]

  def check_valid_project
    project = Project.find_by_key(params[:key])
    return render :json => "bad request", :status => 400 unless project
  end

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

    # TODO start merge daemon if not running
    if `rake merge_daemon:status` =~ /no instances running/
      return render :json => {message: "database cannot be merge at this time"}.to_json, :status => 400
    end

    file = params[:file]
    user = params[:user]
    md5 = params[:md5]

    if project.check_sum(file, md5)

      project.store_database(file, user)

      render :json => {message: "successfully uploaded database"}.to_json, :status => 200
    else
      render :json => {message: "database is corrupted"}.to_json, :status => 400
    end

  end

  def archive_db
    project = Project.find_by_key(params[:key])

    unless project.validate_version(params[:version])
      info = project.archive_db_info
    else
      info = project.archive_db_version_info(params[:version])
    end
    render :json => info.to_json
  end

  def download_db
    project = Project.find_by_key(params[:key])

    unless project.validate_version(params[:version])
      send_file project.db_file_path
    else
      project.archive_db_version_info(params[:version])
      temp_db_file = project.temp_db_version_file_path(params[:version])
      send_file temp_db_file
    end
  end

  def server_file_list
    project = Project.find_by_key(params[:key])

    files = project.server_file_list
    render :json => {files:files}.to_json
  end

  def server_file_archive

  end

  def server_file_download

  end

  def app_file_list
    project = Project.find_by_key(params[:key])

    files = project.app_file_list
    render :json => {files:files}.to_json
  end

  def app_file_archive

  end

  def app_file_download

  end

end

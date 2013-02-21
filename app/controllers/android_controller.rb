class AndroidController < ApplicationController

  def projects
    projects = Project.all.map { |p| {key:p.key, name:p.name} }
    render :json => projects.to_json
  end

  def archive
    project = Project.find_by_key(params[:key])
    return render :json => "bad request", :status => 400 unless project

    info = project.archive_info
    render :json => info.to_json
  end

  def download
    project = Project.find_by_key(params[:key])
    return render :json => "bad request", :status => 400 unless project

    send_file project.filepath
  end

  def upload_db
    # TODO start merge daemon if not running
    if `rake merge_daemon:status` =~ /no instances running/
      return render :json => {message: "database cannot be merge at this time"}.to_json, :status => 400
    end

    project = Project.find_by_key(params[:key])
    return render :json => "bad request", :status => 400 unless project

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
    return render :json => "bad request", :status => 400 unless project

    unless project.validate_version(params[:version])
      info = project.archive_db_info
    else
      info = project.archive_db_version_info(params[:version])
    end
    render :json => info.to_json
  end

  def download_db
    project = Project.find_by_key(params[:key])
    return render :json => "bad request", :status => 400 unless project

    unless project.validate_version(params[:version])
      send_file project.db_file_path
    else
      project.archive_db_version_info(params[:version])
      temp_db_file = Project.temp_db_version_file_path(params[:version])
      send_file temp_db_file
    end
  end

end

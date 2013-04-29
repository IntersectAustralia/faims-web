class AndroidController < ApplicationController

  before_filter :check_valid_project
  skip_before_filter :check_valid_project, :only => [:projects]

  def check_valid_project
    project = Project.find_by_key(params[:key])
    return render :json => 'bad request', :status => 400 unless project
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
    send_file project.get_path(:project_archive)
  end

  def db_archive
    project = Project.find_by_key(params[:key])

    unless project.validate_version(params[:version])
      info = project.db_archive_info
    else
      info = project.db_version_archive_info(params[:version])
    end
    render :json => info.to_json
  end

  def db_download
    project = Project.find_by_key(params[:key])

    unless project.validate_version(params[:version])
      send_file project.get_path(:db_archive)
    else
      project.db_version_archive_info(params[:version])
      temp_db_file = project.temp_db_version_file_path(params[:version])
      send_file temp_db_file
    end
  end

  def db_upload
    project = Project.find_by_key(params[:key])

    # TODO start merge daemon if not running
    if `rake merge_daemon:status` =~ /no instances running/
      return render :json => {message: 'database cannot be merge at this time'}.to_json, :status => 400
    end

    file = params[:file]
    user = params[:user]
    md5 = params[:md5]

    if project.check_sum(file, md5)

      project.store_database(file, user)

      render :json => {message: 'successfully uploaded database'}.to_json, :status => 200
    else
      render :json => {message: 'database is corrupted'}.to_json, :status => 400
    end

  end

  def server_file_list
    project = Project.find_by_key(params[:key])

    files = project.server_file_list
    render :json => {files:files}.to_json
  end

  def server_file_archive
    project = Project.find_by_key(params[:key])
    files = params[:files]

    return render :json => {message: 'no files to download' }.to_json, :status => 400 if project.server_file_list.size == 0

    info = project.server_file_archive_info(files)
    render :json => info.to_json
  end

  def server_file_download
    file = params[:file]

    return render :json => {message: 'bad request'}.to_json, :status => 400 if file == nil
    return render :json => {message: 'file does not exist'}.to_json, :status => 400 unless File.exists? file

    send_file file
  end

  def server_file_upload
    file = params[:file]
    md5 = params[:md5]

    return render :json => {message: 'bad request'}.to_json, :status => 400 if file == nil

    project = Project.find_by_key(params[:key])

    if project.check_sum(file, md5)

      project.server_file_upload(file)

      render :json => {message: 'successfully upload file'}.to_json, :status => 200
    else
      render :json => {message: 'upload file is corrupted'}.to_json, :status => 400
    end

  end

  def app_file_list
    project = Project.find_by_key(params[:key])

    files = project.app_file_list
    render :json => {files:files}.to_json
  end

  def app_file_archive
    project = Project.find_by_key(params[:key])
    files = params[:files]

    return render :json => {message: 'no files to download' }.to_json, :status => 400 if project.app_file_list.size == 0

    info = project.app_file_archive_info(files)
    render :json => info.to_json
  end

  def app_file_download
    file = params[:file]

    return render :json => {message: 'bad request'}.to_json, :status => 400 if file.nil?
    return render :json => {message: 'file does not exist'}.to_json, :status => 400 unless File.exists? file

    send_file file
  end

  def app_file_upload
    file = params[:file]
    md5 = params[:md5]

    return render :json => {message: 'bad request'}.to_json, :status => 400 if file == nil

    project = Project.find_by_key(params[:key])

    if project.check_sum(file, md5)

      project.app_file_upload(file)

      render :json => {message: 'successfully upload file'}.to_json, :status => 200
    else
      render :json => {message: 'upload file is corrupted'}.to_json, :status => 400
    end
  end

end

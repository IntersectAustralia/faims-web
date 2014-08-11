class AndroidController < ApplicationController

  ANDROID_USER = 'faimsandroidapp'
  ANDROID_TOKEN = 'YiQIeV39sdhb2ltRmOyGN'

  http_basic_authenticate_with name: ANDROID_USER, password: ANDROID_TOKEN

  before_filter :check_valid_project_module
  skip_before_filter :check_valid_project_module, :only => [:project_modules]

  def check_valid_project_module
    @project_module = ProjectModule.find_by_key(params[:key])
    return render :json => 'bad request', :status => 400 unless @project_module
  end

  def project_modules
    project_modules = ProjectModule.where(created: true).map { |p| { key: p.key, name: p.name } }
    render :json => project_modules.to_json
  end

  def settings_info
    render :json => @project_module.settings_info.to_json, :status => 200
  end

  def settings_download
    file = params[:request_file]
    return render :json => { message: 'bad request' }.to_json, :status => 400 if file.blank?
    return render :json => { message: 'file does not exist' }.to_json, :status => 400 unless @project_module.settings_request_file(file)

    @project_module.settings_mgr.with_lock do
      send_file @project_module.settings_request_file(file), :status => 200
    end
  end

  def db_info
    version = params[:version]
    version = version.blank? ? nil : version.to_i

    return render :json => { message: 'bad request' }.to_json, :status => 400 if @project_module.db_version_invalid?(version)

    if not File.exists? @project_module.db_version_file_path(version)
      @project_module.delay.generate_database_cache(version)
      render :json => { message: 'generating caches' }.to_json, :status => 202
    else
      render :json => @project_module.db_version_info(version).to_json, :status => 200
    end
  end

  def db_download
    version = params[:version]
    version = version.blank? ? nil : version.to_i

    return render :json => { message: 'bad request' }.to_json, :status => 400 if @project_module.db_version_invalid?(version)

    if not File.exists? @project_module.db_version_file_path(version)
      @project_module.delay.generate_database_cache(version)
      render :json => { message: 'generating caches' }.to_json, :status => 202
    else
      send_file @project_module.db_version_file_path(version), :status => 200
    end
  end

  def db_upload
    file = params[:file]
    user = params[:user]
    md5 = params[:md5]

    return render :json => { message: 'bad request' }.to_json, :status => 400 if file.blank? or user.blank? or md5.blank?

    if MD5Checksum.compute_checksum(file.tempfile.path) == md5
      @project_module.store_database(file.tempfile, user)
      render :json => { message: 'successfully uploaded file' }.to_json, :status => 200
    else
      render :json => { message: 'uploaded file is corrupted' }.to_json, :status => 400
    end
  end

  def server_files_info
    render :json => @project_module.server_files_info.to_json, :status => 200
  end

  def server_file_upload
    file = params[:file]
    request_file = params[:request_file]
    md5 = params[:md5]

    return render :json => { message: 'bad request' }.to_json, :status => 400 if file.blank? or request_file.blank? or md5.blank?

    if MD5Checksum.compute_checksum(file.tempfile.path) == md5
      @project_module.server_mgr.with_lock do
        @project_module.add_server_file(request_file, file.tempfile)
        render :json => { message: 'successfully uploaded file' }.to_json, :status => 200
      end
    else
      render :json => { message: 'uploaded file is corrupted' }.to_json, :status => 400
    end
  end

  def app_files_info
    render :json => @project_module.app_files_info.to_json, :status => 200
  end

  def app_file_download
    file = params[:request_file]
    return render :json => { message: 'bad request' }.to_json, :status => 400 if file.blank?
    return render :json => { message: 'file does not exist' }.to_json, :status => 400 unless @project_module.app_request_file(file)

    @project_module.app_mgr.with_lock do
      send_file @project_module.app_request_file(file), :status => 200
    end
  end

  def app_file_upload
    file = params[:file]
    request_file = params[:request_file]
    md5 = params[:md5]

    return render :json => { message: 'bad request' }.to_json, :status => 400 if file.blank? or request_file.blank? or md5.blank?

    if MD5Checksum.compute_checksum(file.tempfile.path) == md5
      @project_module.app_mgr.with_lock do
        @project_module.add_app_file(request_file, file.tempfile)
        render :json => { message: 'successfully uploaded file' }.to_json, :status => 200
      end
    else
      render :json => { message: 'uploaded file is corrupted' }.to_json, :status => 400
    end
  end

  def data_files_info
    render :json => @project_module.data_files_info.to_json, :status => 200
  end

  def data_file_download
    file = params[:request_file]
    return render :json => { message: 'bad request' }.to_json, :status => 400 if file.blank?
    return render :json => { message: 'file does not exist' }.to_json, :status => 400 unless @project_module.data_request_file(file)

    @project_module.data_mgr.with_lock do
      send_file @project_module.data_request_file(file), :status => 200
    end
  end

end

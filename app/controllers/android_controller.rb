class AndroidController < ApplicationController

  http_basic_authenticate_with name: Rails.application.config.android[:user], password: Rails.application.config.android[:token]

  before_filter :check_valid_project_module
  skip_before_filter :check_valid_project_module, :only => [:project_modules]

  def check_valid_project_module
    @project_module = ProjectModule.find_by_key(params[:key])

    return render :json => 'bad request', :status => 400 unless @project_module
  end

  def project_modules
    project_modules = ProjectModule.where(created: true).map { |p| { key: p.key, name: p.name } }

    render :json => project_modules.to_json, :status => 200
  end

  def settings_info
    render :json => @project_module.settings_info.to_json, :status => 200
  end

  def settings_download
    file = params[:request_file]
    return render :json => { message: 'bad request' }.to_json, :status => 400 if file.blank?
    return render :json => { message: 'file does not exist' }.to_json, :status => 400 unless @project_module.settings_request_file(file)

    @project_module.settings_mgr.with_shared_lock do
      safe_send_file @project_module.settings_request_file(file), :status => 200
    end
  rescue FileManager::TimeoutException => e
    logger.warn e
    render :json => { message: 'request timeout' }.to_json, :status => 408
  end

  def db_info
    version = params[:version]
    version = nil if version.blank?

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
    version = nil if version.blank?

    return render :json => { message: 'bad request' }.to_json, :status => 400 if @project_module.db_version_invalid?(version)

    if not File.exists? @project_module.db_version_file_path(version)
      @project_module.delay.generate_database_cache(version)
      render :json => { message: 'generating caches' }.to_json, :status => 202
    else
      safe_send_file @project_module.db_version_file_path(version), :status => 200
    end
  end

  def db_upload
    file = params[:file]
    user = params[:user]
    md5 = params[:md5]

    return render :json => { message: 'bad request' }.to_json, :status => 400 if file.blank? or user.blank? or md5.blank?

    if MD5Checksum.compute_checksum(file) == md5
      begin
        @project_module.store_database_from_android(file, user)
        render :json => { message: 'successfully uploaded file' }.to_json, :status => 200
      rescue Exception => e
        logger.error e
        render :json => { message: 'internal server error' }.to_json, :status => 500
      end
    else
      render :json => { message: 'uploaded file is corrupted' }.to_json, :status => 400
    end
  end

  def server_file_upload
    file = params[:file]
    path = params[:path]
    md5 = params[:md5]

    return render :json => { message: 'bad request' }.to_json, :status => 400 if file.blank? or path.blank? or md5.blank?

    if MD5Checksum.compute_checksum(file) == md5
      begin
        @project_module.server_mgr.with_shared_lock do
          @project_module.add_server_file(path, file)
          render :json => { message: 'successfully uploaded file' }.to_json, :status => 200
        end
      rescue FileManager::TimeoutException => e
        logger.warn e
        render :json => { message: 'request timeout' }.to_json, :status => 408
      rescue Exception => e
        logger.error e
        render :json => { message: 'internal server error' }.to_json, :status => 500
      end
    else
      render :json => { message: 'uploaded file is corrupted' }.to_json, :status => 400
    end
  end

  def app_file_info
    render :json => @project_module.app_files_info.to_json, :status => 200
  end

  def app_file_download
    file = params[:request_file]
    return render :json => { message: 'bad request' }.to_json, :status => 400 if file.blank?
    return render :json => { message: 'file does not exist' }.to_json, :status => 400 unless @project_module.app_request_file(file)

    @project_module.app_mgr.with_shared_lock do
      safe_send_file @project_module.app_request_file(file), :status => 200
    end
  rescue FileManager::TimeoutException => e
    logger.warn e
    render :json => { message: 'request timeout' }.to_json, :status => 408
  end

  def app_file_upload
    file = params[:file]
    path = params[:path]
    md5 = params[:md5]

    return render :json => { message: 'bad request' }.to_json, :status => 400 if file.blank? or path.blank? or md5.blank?

    if MD5Checksum.compute_checksum(file) == md5
      begin
        @project_module.app_mgr.with_shared_lock do
          @project_module.add_app_file(path, file)
          render :json => { message: 'successfully uploaded file' }.to_json, :status => 200
        end
      rescue FileManager::TimeoutException => e
        logger.warn e
        render :json => { message: 'request timeout' }.to_json, :status => 408
      rescue Exception => e
        logger.error e
        render :json => { message: 'internal server error' }.to_json, :status => 500
      end
    else
      render :json => { message: 'uploaded file is corrupted' }.to_json, :status => 400
    end
  end

  def data_file_info
    render :json => @project_module.data_files_info.to_json, :status => 200
  end

  def data_file_download
    file = params[:request_file]
    return render :json => { message: 'bad request' }.to_json, :status => 400 if file.blank?
    return render :json => { message: 'file does not exist' }.to_json, :status => 400 unless @project_module.data_request_file(file)

    @project_module.data_mgr.with_shared_lock do
      safe_send_file @project_module.data_request_file(file), :status => 200
    end
  rescue FileManager::TimeoutException => e
    logger.warn e
    render :json => { message: 'request timeout' }.to_json, :status => 408
  end

end

class ProjectModuleFileController < ProjectModuleBaseController

  def file_list
    render_file_list
  end

  def download_file
    @project_module = ProjectModule.find(params[:id])

    if params[:path].blank?
      flash.now[:error] = 'Please select file to download.'
    else
      file = File.join(@project_module.get_path(:data_files_dir), params[:path])
      if not File.exists? file
        flash.now[:error] = 'File does not exist.'
      elsif File.directory? file and FileHelper.get_file_list(file).size == 0
        flash.now[:error] = 'No files to download.'
      else
        @project_module.data_mgr.with_shared_lock do
          if File.directory? file
            archive = @project_module.create_data_archive(file)
            safe_send_file archive
          else
            safe_send_file file
          end
        end
      end
    end
  rescue FileManager::TimeoutException => e
    logger.warn e
    flash.now[:error] = 'Could not process request as project is currently locked.'

    render_file_list
  rescue ProjectModule::ProjectModuleException => e
    logger.error e
    flash.now[:error] = e.message

    render_file_list
  end

  def upload_file
    @project_module = ProjectModule.find(params[:id])

    if params[:file_manager].blank? or params[:file_manager][:file].blank?
      flash.now[:error] = 'Please select a file to upload.'
    else
      @project_module.data_mgr.with_exclusive_lock do
        file = params[:file_manager][:file]
        @project_module.add_data_file(File.join(params[:path], file.original_filename), file.tempfile)
        flash.now[:notice] = 'File uploaded.'
      end
    end
  rescue FileManager::TimeoutException => e
    logger.warn e
    flash.now[:error] = 'Could not process request as project is currently locked.'
  rescue ProjectModule::ProjectModuleException => e
    logger.error e
    flash.now[:error] = e.message
  ensure
    render_file_list
  end

  def create_dir
    @project_module = ProjectModule.find(params[:id])

    if params[:file_manager].blank? or not @project_module.is_valid_filename?(params[:file_manager][:dir].strip)
      flash.now[:error] = 'Please enter a valid directory name.'
    else
      @project_module.data_mgr.with_exclusive_lock do
        dir = params[:file_manager][:dir].strip
        @project_module.add_data_dir(File.join(File.join(params[:path], dir)))
        flash.now[:notice] = 'Created directory.'
      end
    end
  rescue FileManager::TimeoutException => e
    logger.warn e
    flash.now[:error] = 'Could not process request as project is currently locked.'
  rescue ProjectModule::ProjectModuleException => e
    logger.error e
    flash.now[:error] = e.message
  ensure
    render_file_list
  end

  def delete_file
    @project_module = ProjectModule.find(params[:id])

    if params[:path].blank?
      flash.now[:error] = 'Please select file to delete.'
    else
      file = File.join(@project_module.get_path(:data_files_dir), params[:path])
      if not File.exists? file and not File.directory? file
        flash.now[:error] = 'File does not exist.'
      else
        @project_module.data_mgr.with_exclusive_lock do
          if params[:path] == '.'
            @project_module.remove_data_dir(@project_module.get_path(:data_files_dir))
            flash.now[:notice] = 'Deleted directory.'
          elsif File.directory? file
            @project_module.remove_data_dir file
            flash.now[:notice] = 'Deleted directory.'
          else
            @project_module.remove_data_file file
            flash.now[:notice] = 'Deleted file.'
          end

          @project_module.destroy_project_module_archive
        end
      end
    end
  rescue FileManager::TimeoutException => e
    logger.warn e
    flash.now[:error] = 'Could not process request as project is currently locked.'
  ensure
    render_file_list
  end

  def batch_upload_file
    @project_module = ProjectModule.find(params[:id])

    if params[:project_module].blank? or params[:project_module][:file].blank?
      flash.now[:error] = 'Please select a file to upload.'
    else
      @project_module.data_mgr.with_exclusive_lock do
        file = params[:project_module][:file]
        @project_module.add_data_batch_file(file.path)
        flash.now[:notice] = 'File uploaded.'
      end
    end
  rescue FileManager::TimeoutException => e
    logger.warn e
    flash.now[:error] = 'Could not process request as project is currently locked.'
  rescue ProjectModule::ProjectModuleException => e
    logger.error e
    flash.now[:error] = e.message
  ensure
    render_file_list
  end

  private

  def render_file_list
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_files

    @project_module = ProjectModule.find(params[:id])
    @dir = FileHelper.get_file_list_by_dir(@project_module.get_path(:data_files_dir), '.')
    render 'file_list'
  end

end

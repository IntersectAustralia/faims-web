class FileManagerController < ApplicationController
  include ProjectModuleBreadCrumbs
  before_filter :crumbs
  before_filter :authenticate_user!
  load_and_authorize_resource :project_module

  def file_list
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_files

    @project_module = ProjectModule.find(params[:id])
    @dir = FileHelper.get_file_list_by_dir(@project_module.get_path(:data_files_dir), '.')

    if params[:notice]
      flash[:notice] = params[:notice]
    elsif params[:error]
      flash[:error] = params[:error]
    end
  end

  def download_file
    @project_module = ProjectModule.find(params[:id])

    if params[:path].blank?
      redirect_to :action => 'file_list', :error => 'Please select file to download'
    else
      file = File.join(@project_module.get_path(:data_files_dir), params[:path])
      if not File.exists? file
        redirect_to :action => 'file_list', :error => 'File does not exist'
      elsif File.directory? file and FileHelper.get_file_list(file).size == 0
        redirect_to :action => 'file_list', :error => 'No files to download'
      else
        @project_module.data_mgr.with_shared_lock do
          if File.directory? file
            begin
              archive = @project_module.create_data_archive(file)
              safe_send_file archive
            rescue Exception => e
              logger.error e
              redirect_to :action => 'file_list', :error => e.message
            end
          else
            safe_send_file file
          end
        end
      end
    end
  rescue TimeoutException
    logger.warn e
    redirect_to :action => 'file_list', :error => 'Could not process request as project is current locked'
  end

  def upload_file
    @project_module = ProjectModule.find(params[:id])

    if params[:file_manager].blank? or params[:file_manager][:file].blank?
      redirect_to :action => 'file_list', :error => 'Please select a file to upload'  
    else
      @project_module.data_mgr.with_exclusive_lock do
        file = params[:file_manager][:file]
        begin
          @project_module.add_data_file(File.join(params[:path], file.original_filename), file.tempfile)
          redirect_to :action => 'file_list', :notice => 'File upload success'
        rescue Exception => e
          logger.error e
          redirect_to :action => 'file_list', :error => e.message
        end
      end
    end
  rescue TimeoutException
    logger.warn e
    redirect_to :action => 'file_list', :error => 'Could not process request as project is current locked'
  end

  def create_dir
    @project_module = ProjectModule.find(params[:id])

    if params[:file_manager].blank? or !ProjectModule.validate_directory(params[:file_manager][:dir].strip)
      redirect_to :action => 'file_list', :error => 'Please enter a valid directory name'
    else
      @project_module.data_mgr.with_exclusive_lock do
        dir = params[:file_manager][:dir].strip
        begin
          @project_module.add_data_dir(File.join(File.join(params[:path], dir)))
          redirect_to :action => 'file_list', :notice => 'Create directory success'
        rescue Exception => e
          logger.error e
          redirect_to :action => 'file_list', :error => e.message
        end
      end
    end
  rescue TimeoutException
    logger.warn e
    redirect_to :action => 'file_list', :error => 'Could not process request as project is current locked'
  end

  def delete_file
    @project_module = ProjectModule.find(params[:id])

    if params[:path].blank?
      redirect_to :action => 'file_list', :error => 'Please select file to delete'
    else
      file = File.join(@project_module.get_path(:data_files_dir), params[:path])
      if not File.exists? file and not File.directory? file
        redirect_to :action => 'file_list', :error => 'Could not find anything to delete'
      else
        @project_module.data_mgr.with_exclusive_lock do
          if params[:path] == '.'
            safe_delete_directory @project_module.get_path(:data_files_dir)
            safe_create_directory @project_module.get_path(:data_files_dir)
            redirect_to :action => 'file_list', :notice => 'Deleted directory'
          elsif File.directory? file
            safe_delete_directory file
            redirect_to :action => 'file_list', :notice => 'Deleted directory'
          else
            safe_delete_file file
            redirect_to :action => 'file_list', :notice => 'Deleted file'
          end
        end
      end
    end
  rescue TimeoutException
    logger.warn e
    redirect_to :action => 'file_list', :error => 'Could not process request as project is current locked'
  end

  def batch_upload_file
    @project_module = ProjectModule.find(params[:id])

    if params[:project_module].blank? or params[:project_module][:file].blank?
      redirect_to :action => 'file_list', :error => 'Please select a file to upload'
    elsif not @project_module.data_mgr.can_write?
      redirect_to :action => 'file_list', :error => 'Could not upload archive. Files are currently locked'
    else
      @projet_module.data_mgr.with_exclusive_lock do
        file = params[:project_module][:file]
        begin
          @project_module.add_data_batch_file(file.path)
          redirect_to :action => 'file_list', :notice => 'Create directory success'
        rescue Exception => e
          logger.error e
          redirect_to :action => 'file_list', :error => e.message
        end
      end
    end
  rescue TimeoutException
    logger.warn e
    redirect_to :action => 'file_list', :error => 'Could not process request as project is current locked'
  end

end

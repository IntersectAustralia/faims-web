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
      if !File.exists? file
        redirect_to :action => 'file_list', :error => 'File does not exist'
      elsif File.directory? file and FileHelper.get_file_list(file).size == 0
        redirect_to :action => 'file_list', :error => 'No files to download'
      else
        @project_module.data_mgr.with_lock do
          if File.directory? file
            archive = @project_module.create_temp_dir_archive(file)
            safe_send_file archive
          else
            safe_send_file file
          end
        end
      end
    end
  end

  def upload_file
    @project_module = ProjectModule.find(params[:id])

    if params[:file_manager].blank? or params[:file_manager][:file].blank?
      redirect_to :action => 'file_list', :error => 'Please select a file to upload'
    elsif @project_module.data_mgr.locked?
      redirect_to :action => 'file_list', :error => 'Could not upload file. Files are currently locked'
    else
      file = params[:file_manager][:file]
      error = @project_module.add_data_file(file.tempfile, File.join(params[:path], file.original_filename))

      if error
        redirect_to :action => 'file_list', :error => error
      else
        redirect_to :action => 'file_list', :notice => 'File upload success'
      end
    end
  end

  def create_dir
    @project_module = ProjectModule.find(params[:id])

    if params[:file_manager].blank? or !ProjectModule.validate_directory(params[:file_manager][:dir].strip)
      redirect_to :action => 'file_list', :error => 'Please enter a valid directory name'
    elsif @project_module.data_mgr.locked?
      redirect_to :action => 'file_list', :error => 'Could not create directory. Files are currently locked'
    else
      dir = params[:file_manager][:dir].strip
      error = @project_module.create_data_dir(File.join(File.join(params[:path], dir)))

      if error
        redirect_to :action => 'file_list', :error => error
      else
        redirect_to :action => 'file_list', :notice => 'Create directory success'
      end
    end
  end

  def delete_file
    @project_module = ProjectModule.find(params[:id])

    if params[:path].blank?
      redirect_to :action => 'file_list', :error => 'Please select file to delete'
    else
      file = File.join(@project_module.get_path(:data_files_dir), params[:path])
      if !File.exists? file and !File.directory? file
        redirect_to :action => 'file_list', :error => 'Could not find anything to delete'
      elsif @project_module.data_mgr.locked?
        if File.directory? file
          redirect_to :action => 'file_list', :error => 'Could not delete directory. Files are currently locked'
        else
          redirect_to :action => 'file_list', :error => 'Could not delete file. Files are currently locked'
        end
      else
        @project_module.data_mgr.with_lock do
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
  end

  def batch_upload_file
    @project_module = ProjectModule.find(params[:id])

    if params[:project_module].blank? or params[:project_module][:file].blank?
      redirect_to :action => 'file_list', :error => 'Please select a file to upload'
    elsif @project_module.data_mgr.locked?
      redirect_to :action => 'file_list', :error => 'Could not upload archive. Files are currently locked'
    else
      file = params[:project_module][:file]
      error = @project_module.add_batch_file(file.tempfile)
      if error
        redirect_to :action => 'file_list', :error => error
      else
        redirect_to :action => 'file_list', :notice => 'File upload success'
      end
    end
  end

end

class FileManagerController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :project

  def crumbs
    project = Project.find(params[:id]) if params[:id]
    @crumbs =
      {
          :pages_home => {title: 'Home', url: pages_home_path},
          :projects_index => {title: 'Projects', url: projects_path},
          :projects_show => {title: project ? project.name : nil, url: project ? project_path(project) : nil},
          :projects_files => {title: 'Files', url: project ? project_file_list_path(project) : nil},
      }
  end

  def file_list
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_files]

    @project = Project.find_by_id(params[:id])
    @dir = FileHelper.get_file_list_by_dir(@project.get_path(:data_files_dir), '.')

    if params[:notice]
      flash[:notice] = params[:notice]
    elsif params[:error]
      flash[:error] = params[:error]
    end
  end

  def download_file
    @project = Project.find_by_id(params[:id])

    if params[:path].nil?
      redirect_to :action => 'file_list', :error => 'Please select file to download'
    else
      file = File.join(@project.get_path(:data_files_dir), params[:path])
      if !File.exists? file
        redirect_to :action => 'file_list', :error => 'File does not exist'
      elsif File.directory? file and FileHelper.get_file_list(file).size == 0
        redirect_to :action => 'file_list', :error => 'No files to download'
      else
        @project.data_mgr.with_lock do
          if File.directory? file
            archive = @project.create_temp_dir_archive(file)
            send_file archive
          else
            send_file file
          end
        end
      end
    end
  end

  def upload_file
    @project = Project.find_by_id(params[:id])

    if params[:file_manager].nil? or params[:file_manager][:file].nil?
      redirect_to :action => 'file_list', :error => 'Please select a file to upload'
    elsif @project.data_mgr.locked?
      redirect_to :action => 'file_list', :error => 'Could not upload file. Files are currently locked'
    else
      file = params[:file_manager][:file]
      error = @project.add_data_file(file.tempfile, File.join(params[:path], file.original_filename))

      if error
        redirect_to :action => 'file_list', :error => error
      else
        redirect_to :action => 'file_list', :notice => 'File upload success'
      end
    end
  end

  def create_dir
    @project = Project.find_by_id(params[:id])

    if params[:file_manager].nil? or !Project.validate_directory(params[:file_manager][:dir].strip)
      redirect_to :action => 'file_list', :error => 'Please enter a valid directory name'
    elsif @project.data_mgr.locked?
      redirect_to :action => 'file_list', :error => 'Could not create directory. Files are currently locked'
    else
      dir = params[:file_manager][:dir].strip

      error = @project.create_data_dir(File.join(File.join(params[:path], dir)))

      if error
        redirect_to :action => 'file_list', :error => error
      else
        redirect_to :action => 'file_list', :notice => 'Create directory success'
      end
    end
  end

  def delete_file
    @project = Project.find_by_id(params[:id])

    if params[:path].nil? or params[:path] == '.'
      redirect_to :action => 'file_list', :error => 'Please select file to delete'
    else
      file = File.join(@project.get_path(:data_files_dir), params[:path])
      if !File.exists? file
        redirect_to :action => 'file_list', :error => 'File does not exist'
      elsif File.directory? file and FileHelper.get_file_list(file).size > 0
        redirect_to :action => 'file_list', :error => 'Cannot delete directory with files'
      elsif @project.data_mgr.locked?
        if File.directory? file
          redirect_to :action => 'file_list', :error => 'Could not delete directory. Files are currently locked'
        else
          redirect_to :action => 'file_list', :error => 'Could not delete file. Files are currently locked'
        end
      else
        file = File.join(@project.get_path(:data_files_dir), params[:path])
        @project.data_mgr.with_lock do
          if File.directory? file
            FileUtils.rm_rf file
            redirect_to :action => 'file_list', :notice => 'Deleted directory'
          else
            File.delete file
            redirect_to :action => 'file_list', :notice => 'Deleted file'
          end
        end
      end
    end
  end

  def batch_upload_file
    @project = Project.find_by_id(params[:id])

    if params[:project].nil? or params[:project][:file].nil?
      redirect_to :action => 'file_list', :error => 'Please select a file to upload'
    elsif @project.data_mgr.locked?
      redirect_to :action => 'file_list', :error => 'Could not upload archive. Files are currently locked'
    else
      file = params[:project][:file]
      error = @project.add_batch_file(file.tempfile)
      if error
        redirect_to :action => 'file_list', :error => error
      else
        redirect_to :action => 'file_list', :notice => 'File upload success'
      end
    end
  end

end

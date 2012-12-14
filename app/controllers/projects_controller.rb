class ProjectsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource

  def index

  end

  def new
    @project = Project.new

    # make temp directory and store its path in session
    create_tmp_dir
  end

  def create
    # create project if valid and schemas uploaded
    
    valid = create_project

    if valid

      @project.transaction do
        @project.save

        @project.create_project_from(session[:tmpdir])
        FileUtils.remove_entry_secure session[:tmpdir]
      end

      flash[:notice] = t 'projects.new.success'
      redirect_to :projects
    else
      flash.now[:error] = t 'projects.new.failure'
      render 'new'
    end
  end

  def show
    @project = Project.find(params[:id])
  end

  def update

  end

  private

    def create_tmp_dir
      clear_tmp_dir
      tmpdir = Dir.mktmpdir
      session[:tmpdir] = tmpdir
      session[:data_schema] = false
      session[:ui_schema] = false
    end

    def clear_tmp_dir
      FileUtils.remove_entry_secure session[:tmpdir] if 
        !session[:tmpdir].blank? and File.directory? session[:tmpdir]
      session[:tmpdir] = nil
    end

    def create_project
      # check if project is valid

      valid = false     
      if params[:project]
        @project = Project.new(:name => params[:project][:name]) if params[:project]
        valid = @project.valid?
      end
      
      # check if data schema is valid
      if !session[:data_schema]
        error = if params[:project].nil?
                  "can't be blank."
                else
                  Project.validate_data_schema(params[:project][:data_schema])
                end
        if error
          @project.errors.add(:data_schema, error)
          valid = false
        else
          create_temp_file("data_schema.xml", params[:project][:data_schema])
          session[:data_schema] = true
        end
      end

      # check if ui schema is valid
      if !session[:ui_schema]
        error = if params[:project].nil?
                  "can't be blank."
                else
                  Project.validate_ui_schema(params[:project][:ui_schema])
                end
        if error
          @project.errors.add(:ui_schema, error)
          valid = false
        else
          create_temp_file("ui_schema.xml", params[:project][:ui_schema])
          session[:ui_schema] = true
        end
      end
      
      valid
    end

    def create_temp_file(filename, upload)
      tmpdir = session[:tmpdir]
      #logger.debug tmpdir + "/" + filename
      File.open(upload.tempfile, 'r') do |upload_file|
        File.open(tmpdir + "/" + filename, 'w') do |temp_file|
          temp_file.write(upload_file.read)
        end
      end
    end

end
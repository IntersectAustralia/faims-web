class ProjectsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource

  def index

  end

  def new
    @project = Project.new

    # make temp directory and store its path in session
    clear_tmp_dir

    tmpdir = Dir.mktmpdir
    session[:tmpdir] = tmpdir
  end

  def create
    # create project project valid and schemas uploaded
    @project = Project.new(:name => params[:project][:name])
    valid = @project.valid?

    unless session[:data_schema]
      @project.errors.add(:data_schema, "can't be blank")
      valid = false
    end

    unless session[:ui_schema]
      @project.errors.add(:ui_schema, "can't be blank")
      valid = false
    end

    if valid
      @project.save

      @project.create_project_from(session[:tmpdir])
      FileUtils.remove_entry_secure session[:tmpdir]

      flash[:notice] = t 'projects.new.success'
      redirect_to :projects
    else
      flash.now[:error] = t 'projects.new.failure'
      render 'new'
    end
  end

  def show

  end

  def update

  end

  def upload_data_schema
    respond_to do |format|
      format.json do
        error = "can't be blank" if params[:project].nil?
        error ||= Project.validate_data_schema(params[:project][:data_schema]) if params[:project]
        if error
          render :json => {message:error, status: "failure"}
        else
          add_temp_file("data_schema.xml", params[:project][:data_schema])
          session[:data_schema] = true
          render :json => {message:"data schema uploaded!", status: "success"}.to_json
        end
      end
    end
  end

  def upload_ui_schema
    respond_to do |format|
      format.json do
        error = "can't be blank" if params[:project].nil?
        error ||= Project.validate_ui_schema(params[:project][:ui_schema]) if params[:project]
        if error
          render :json => {message:error, status: "failure"}
        else
          add_temp_file("ui_schema.xml", params[:project][:ui_schema])
          session[:ui_schema] = true
          render :json => {message:"ui schema uploaded!", status: "success"}.to_json
        end
      end
    end
  end

  private

    def clear_tmp_dir
      FileUtils.remove_entry_secure session[:tmpdir] if session[:tmpdir]
      session[:data_schema] = false
      session[:ui_schema] = false
    end

    def add_temp_file(filename, upload)
      tmpdir = session[:tmpdir]
      #logger.debug tmpdir + "/" + filename
      File.open(tmpdir + "/" + filename, 'w') do |file|
        file.write(upload.read)
      end
    end

end

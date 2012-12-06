class ProjectsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource

  def index

  end

  def new
    @project = Project.new
    # make temp directory and store its path in session
    tmpdir = Dir.mktmpdir
    session[:tmpdir] = tmpdir
    session[:data_schema] = false
    session[:ui_schema] = false
  end

  def create
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
      # create project directory, sqlite database and copy schemas from tmp directory
      dir_name = Rails.root.join('projects', @project.name)
      Dir.mkdir(dir_name)
      dir_name = Rails.root.join('projects', @project.name)
      logger.debug dir_name.to_s + "/data_schema.xml"
      logger.debug session[:tmpdir] + "/data_schema.xml"
      FileUtils.mv(session[:tmpdir] + "/data_schema.xml", dir_name.to_s + "/data_schema.xml")
      FileUtils.mv(session[:tmpdir] + "/ui_schema.xml", dir_name.to_s + "/ui_schema.xml")
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

  def valid_name
    respond_to do |format|
      format.json do
        status = "failure"
        status = "success" if Project.find_by_name(params[:projects][:name]).nil?
        render :json => {status: status}.to_json
      end
    end
  end

  def upload_data_schema
    respond_to do |format|
      format.json do
        not_valid = params[:project].nil? ||
            params[:project][:data_schema].nil? ||
            params[:project][:data_schema].blank?
        if not_valid
          render :json => {message:"can't be blank", status: "failed"}.to_json
        else
          data_schema = params[:project][:data_schema]
          if data_schema.content_type != "text/xml"
            render :json => {message:"must be of xml format", status: "failed"}.to_json
          else
            tmpdir = session[:tmpdir]
            logger.debug tmpdir + "/data_schema.xml"
            File.open(tmpdir + "/data_schema.xml", 'w') do |file|
              file.write(data_schema.read)
            end
            session[:data_schema] = true
            render :json => {message:"data schema uploaded!", status: "success"}.to_json
          end
        end
      end
    end
  end

  def upload_ui_schema

    respond_to do |format|
      format.json do
        not_valid = params[:project].nil? ||
            params[:project][:ui_schema].nil? ||
            params[:project][:ui_schema].blank?
        if not_valid
          render :json => {message:"can't be blank", status: "failed"}.to_json
        else
          ui_schema = params[:project][:ui_schema]
          if ui_schema.content_type != "text/xml"
            render :json => {message:"must be of xml format", status: "failed"}.to_json
          else
            tmpdir = session[:tmpdir]
            logger.debug tmpdir + "/ui_schema.xml"
            File.open(tmpdir + "/ui_schema.xml", 'w') do |file|
              file.write(ui_schema.read)
            end
            session[:ui_schema] = true
            render :json => {message:"ui schema uploaded!", status: "success"}.to_json
          end
        end
      end
    end
  end

end

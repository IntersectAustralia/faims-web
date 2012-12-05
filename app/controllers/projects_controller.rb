class ProjectsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource

  def index

  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(:name => params[:project][:name])
    if @project.save
      flash.now[:notice] = t 'projects.new.success'
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

end

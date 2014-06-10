class ProjectExporterController < ApplicationController
  include ProjectExporterBreadCrumbs
  before_filter :crumbs
  before_filter :authenticate_user!
  load_and_authorize_resource :project_exporter

  def index

  end

  def new

  end

  def create

  end

  def show

  end

  def delete

  end

end
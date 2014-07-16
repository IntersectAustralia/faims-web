class ProjectExporterController < ApplicationController
  include ProjectExporterBreadCrumbs
  before_filter :crumbs
  before_filter :authenticate_user!
  load_and_authorize_resource :project_exporter

  def index
    page_crumbs :pages_home, :exporters_index
    @project_exporters = ProjectExporter.all
  end

  def new
    page_crumbs :pages_home, :exporters_index, :exporters_add
    @project_exporter = ProjectExporter.new
  end

  def create
    unless params[:project_exporter] and params[:project_exporter][:tarball]
      flash.now[:error] = 'Please choose an exporter to export.'
      return render 'new'
    end
    tarball = params[:project_exporter][:tarball]

    begin
      dir = ProjectExporter.extract_exporter(tarball.tempfile.path)
      @project_exporter = ProjectExporter.new(dir)
      if @project_exporter.valid?
        if @project_exporter.install
          flash[:notice] = 'Exporter installed.'
          return redirect_to project_exporters_path
        else
          flash.now[:error] = 'Exporter failed to install. Please correct the errors in the install script.'
        end
      else
        flash.now[:error] = 'Please correct the errors in the exporter.'
      end
      render 'new'
    rescue ProjectExporter::ProjectExporterException => e
      logger.error e
      flash.now[:error] = e.message
      return render 'new'
    end
  end

  def delete
    @project_exporter = ProjectExporter.find_by_key(params[:key])
    unless @project_exporter
      flash[:error] = 'Exporter does not exist.'
      return redirect_to project_exporters_path
    end

    begin
      result = @project_exporter.uninstall
      logger.debug result
      if result
        flash[:notice] = 'Exporter uninstalled.'
      else
        flash[:error] = 'Exporter failed to uninstall. Please correct the errors in the uninstall script.'
      end
    rescue ProjectExporter::ProjectExporterException => e
      logger.error e
      flash[:error] = e.message
    end
    redirect_to project_exporters_path
  end

end
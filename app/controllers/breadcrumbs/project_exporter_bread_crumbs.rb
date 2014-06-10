module ProjectExporterBreadCrumbs

  def crumbs
    exporter = ProjectExporter.find_by_id(params[:key]) if params[:key]

    @crumbs =
        {
            :pages_home => {title: 'Home', url: pages_home_path},

        }
  end

  def page_crumbs(*value)
    @page_crumbs = value
  end

end
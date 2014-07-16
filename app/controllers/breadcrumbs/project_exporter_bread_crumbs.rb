module ProjectExporterBreadCrumbs

  def crumbs
    @crumbs =
        {
            :pages_home => {title: 'Home', url: pages_home_path},

            :exporters_index => {title: 'Exporters', url: project_exporters_path},
            :exporters_add => {title: 'Add', url: new_project_exporter_path}
        }
  end

  def page_crumbs(*value)
    @page_crumbs = value
  end

end
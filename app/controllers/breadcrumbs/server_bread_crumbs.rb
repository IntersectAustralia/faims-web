module ServerBreadCrumbs

  def crumbs
    @crumbs =
        {
            :pages_home => {title: 'Home', url: pages_home_path},
            :server_update => {title: 'Server Update', url: nil}
        }
  end

  def page_crumbs(*value)
    @page_crumbs = value
  end

end
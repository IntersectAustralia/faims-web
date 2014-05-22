module UserBreadCrumbs

  def crumbs
    user = User.find(params[:id]) if params[:id]

    @crumbs =
        {
            :pages_home => {title: 'Home', url: pages_home_path},

            :users_index => {title: 'Users', url: users_path },
            :users_add => {title: 'Add', url: new_user_path },
            :users_show => {title: 'Details', url: user ? user_path(user) : nil },
            :users_edit_role => {title: 'Edit Role', url: user ? edit_role_user_path(user) : nil },
            :users_edit_details => {title: 'Edit Details', url: user ? users_edit_path(user) : nil },
            :users_current_show => {title: 'Details', url: current_user ? user_path(current_user) : nil },
            :users_edit_password => {title: 'Edit Password', url: user ? change_password_user_path(user) : nil },
        }
  end

  def page_crumbs(*value)
    @page_crumbs = value
  end

end
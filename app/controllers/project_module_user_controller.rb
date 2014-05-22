class ProjectModuleUserController < ProjectModuleBaseController

  def edit_project_module_user
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_users

    @project_module = ProjectModule.find(params[:id])

    render_users_list
  end

  def update_project_module_user
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_users

    @project_module = ProjectModule.find(params[:id])

    authenticate_project_module_user

    user = User.find(params[:user_id])
    @project_module.db_mgr.with_shared_lock do
      @project_module.db.update_list_of_users(user, @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Successfully updated user.'

      redirect_to :edit_project_module_user
    end
  rescue MemberException, FileManager::TimeoutException => e
    logger.warn e
    flash.now[:error] = get_error_message(e)

    render_users_list
  end

  private

  def render_users_list
    @users = @project_module.db.get_list_of_users
    user_transpose = @users.transpose
    @server_user = User.all.select { |x| user_transpose.empty? or !user_transpose.last.include? x.email }

    render 'edit_project_module_user'
  end

end
class UsersController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource

  def crumbs
    user = User.find(params[:id]) if params[:id]
    @crumbs =
        {
            :pages_home => {title: 'Home', url: pages_home_path},

            :users_index => {title: 'Users', url: users_path },
            :users_add => {title: 'Add', url: new_user_path },
            :users_show => {title: 'Details', url: user ? user_path(user) : nil },
            :users_edit_role => {title: 'Edit Role', url: user ? edit_role_user_path(user) : nil },
        }
  end

  def index
    @page_crumbs = [:pages_home, :users_index]

    @users = User.all
  end

  def show
    @page_crumbs = [:pages_home, :users_index, :users_show]
  end

  def admin

  end

  def access_requests
    @users = User.pending_approval
  end

  def deactivate
    if !@user.check_number_of_superusers(params[:id], current_user.id)
      redirect_to(@user, :alert => "You cannot deactivate this account as it is the only account with superuser privileges.")
    else
      @user.deactivate
      redirect_to(@user, :notice => "The user has been deactivated.")
    end
  end

  def activate
    @user.activate
    redirect_to(@user, :notice => "The user has been activated.")
  end

  def reject
    @user.reject_access_request
    @user.destroy
    redirect_to(access_requests_users_path, :notice => "The access request for #{@user.email} was rejected.")
  end

  def reject_as_spam
    @user.reject_access_request
    redirect_to(access_requests_users_path, :notice => "The access request for #{@user.email} was rejected and this email address will be permanently blocked.")
  end

  def edit_role
    @page_crumbs = [:pages_home, :users_index, :users_show, :users_edit_role]

    if @user == current_user
      flash.now[:alert] = "You are changing the role of the user you are logged in as."
    elsif @user.rejected?
      redirect_to(users_path, :alert => "Role can not be set. This user has previously been rejected as a spammer.")
    end
    @roles = Role.by_name
  end

  def edit_approval
    @roles = Role.by_name
  end

  def update_role
    if params[:user][:role].blank?
      redirect_to(edit_role_user_path(@user), :alert => "Please select a role for the user.")
    else
      @user.role_id = params[:user][:role]
      if !@user.check_number_of_superusers(params[:id], current_user.id)
        redirect_to(edit_role_user_path(@user), :alert => "Only one superuser exists. You cannot change this role.")
      elsif @user.save
        redirect_to(@user, :notice => "The role for #{@user.email} was successfully updated.")
      end
    end
  end

  def approve
    if !params[:user][:role].blank?
      @user.role_id = params[:user][:role]
      @user.save
      @user.approve_access_request

      redirect_to(access_requests_users_path, :notice => "The access request for #{@user.email} was approved.")
    else
      redirect_to(edit_approval_user_path(@user), :alert => "Please select a role for the user.")
    end
  end

  def new
    @page_crumbs = [:pages_home, :users_index, :users_add]

    @user = User.new
  end

  def create
    @page_crumbs = [:pages_home, :users_index, :users_add]

    @user = User.new(params[:user])
    if @user.valid?
      @user.activate
      @user.role = Role.find_by_name('user')
      @user.save

      flash[:notice] = "New user created."
      redirect_to :users
    else
      flash[:error] = "Please correct the errors in this form."
      render 'new'
    end
  end

  def destroy
    user = User.find(params[:id])
    if user
      if current_user.id == user.id
        flash[:error] = "Cannot delete yourself."
      else
        user.destroy
        flash[:notice] = "User deleted."
      end
    else
      flash[:error] = "Cannot find user."
    end
    redirect_to :users
  end

end

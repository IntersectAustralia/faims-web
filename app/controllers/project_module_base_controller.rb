class ProjectModuleBaseController < ApplicationController
  include ProjectModuleBreadCrumbs
  before_filter :crumbs
  before_filter :authenticate_user!
  load_and_authorize_resource :project_module

  class MemberException < Exception
  end

  def get_error_message(exception)
    if exception.instance_of? MemberException
      'You are not a member of the module you are editing. Please ask a member to add you to the module before continuing.'
    else exception.instance_of? FileManager::TimeoutException
    'Could not process request as project is currently locked.'
    end
  end

  def authenticate_project_module_user
    @project_module = ProjectModule.find(params[:id])
    redirect_to :project_modules unless @project_module

    user_emails = @project_module.db.get_list_of_users.map { |x| x.last }
    raise MemberException unless user_emails.include? current_user.email
  end

end

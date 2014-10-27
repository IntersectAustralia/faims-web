class ServerController < ApplicationController
  include ServerBreadCrumbs
  before_filter :crumbs
  before_filter :authenticate_user!

  def check_for_updates
    page_crumbs :pages_home, :server_update
    @project_modules = ProjectModule.all
    flash.now[:notice] = 'Everything is update to date.' unless ServerUpdater.check_server_updates
  rescue Exception => e
    logger.error e
    flash.now[:error] = e.message
  end

  def update
    jobid = ServerUpdater.delay.update_server
    render json: { result: 'success', url: check_server_updated_path(jobid: jobid) }
  end

  def check_updated
    job = Delayed::Job.find_by_id(params[:jobid])
    if job
      if job.last_error?
        logger.error job.last_error if job.last_error?
        render json: { result: 'failure', message: 'Encountered an unexpected error trying to check for updates. Please contact a system administrator to resolve this problem.' }
      else
        render json: { result: 'waiting' }
      end
    else
      if ServerUpdater.has_server_updates
        render json: { result: 'failure', message: 'The server failed to update properly. Please contact a system administrator to resolve this problem.' }
      else
        render json: { result: 'success', message: 'The server has been successfully updated. The server will now reboot in 60 seconds please press ok to continue.', url: project_modules_path, restart_url: restart_server_path }
      end
    end
  end

  def restart
    ServerUpdater.restart_server
    sign_out :user
    render json: { result: 'success' }
  end

end

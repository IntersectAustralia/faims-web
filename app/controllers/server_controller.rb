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

  def check_server_updated
    job = Delayed::Job.find_by_id(params[:jobid])
    if job
      logger.error job.last_error if job.last_error
      render json: { result: job.last_error? ? 'failure' : 'waiting', message: 'Encountered an unexpected error trying to check for updates.' }
    else
      render json: { result: 'success', message: 'Your server has been successfully updated. The server will need to be restarted please click ok to restart the server and continue.', url: restart_server_path }
    end
  end

  def restart
    ServerUpdater.restart_server
    sign_out user
    redirect_to root_path
  end

end

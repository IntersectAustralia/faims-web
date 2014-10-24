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
    result = ServerUpdater.update_server_in_background

    if result == 0 or result == 2
      render json: { result: 'success', url: has_updated_server_path }
    else
      render json: { result: 'failure', message: 'Encountered an error trying to update server.' }
    end
  rescue Exception => e
    logger.error e

    render json: { result: 'failure', message: e.message }
  end

  def has_updated
    render json: { result: 'success', url: project_modules_path(notice: 'Finished updating server.') } unless ServerUpdater.has_server_updates
  end

end

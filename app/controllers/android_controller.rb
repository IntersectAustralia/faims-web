class AndroidController < ApplicationController

  def projects
    projects = Project.all.map { |p| {key:p.key, name:p.name} }
    render :json => projects.to_json
  end

  def archive
    project = Project.find_by_key(params[:key])
    info = project.archive_info
    render :json => info.to_json
  end

  def download
    project = Project.find_by_key(params[:key])
    send_file project.filepath
  end

  def upload_db
    # TODO for now fail if merge daemon is not running
    if `rake merge_daemon:status` =~ /no instances running/
      return render :json => {}.to_json, :status => 400
    end

    project = Project.find_by_key(params[:key])
    file = params[:file]
    user = params[:user]
    md5 = params[:md5]

    if project.check_sum(file, md5)

      project.store_database(file, user)

      render :json => {}.to_json, :status => 200
    else
      render :json => {}.to_json, :status => 400
    end

  end

  def archive_db
    project = Project.find_by_key(params[:key])
    info = project.archive_db_info
    render :json => info.to_json
  end

  def download_db
    project = Project.find_by_key(params[:key])
    send_file project.db_file_path
  end

  private

    def project_dir
      return Rails.env == 'test' ? 'tmp/projects' : 'projects'
    end

end

class ProjectModulesController < ProjectModuleBaseController

  def index
    page_crumbs :pages_home, :project_modules_index
    @project_modules = ProjectModule.created
  end

  def new
    page_crumbs :pages_home, :project_modules_index, :project_modules_create
    
    @project_module = ProjectModule.new
    
    @spatial_list = Database.get_spatial_ref_list

    create_project_module_tmp_dir
  end

  def create
    page_crumbs :pages_home, :project_modules_index, :project_modules_create

    @project_module = ProjectModule.new
    
    @spatial_list = Database.get_spatial_ref_list

    parse_settings_from_params(params)

    # check if spatialite exists?
    unless SpatialiteDB.library_exists?
      flash.now[:error] = 'Cannot find library libspatialite. Please install library to create module.'
      return render 'new'
    end

    if create_project_module(@tmpdir)
      begin
        @project_module.save
        @project_module.set_settings(params[:project_module])
        @project_module.create_project_module_from(@tmpdir, current_user)
        @project_module.created = true
        @project_module.save

        flash[:notice] = 'New module created.'
      rescue Exception => e
        logger.error e

        # cleanup
        @project_module.destroy

        flash[:error] = 'Failed to create module.'
      ensure
        FileUtils.remove_entry_secure @tmpdir
      end
      
      redirect_to :project_modules
    else
      flash.now[:error] = 'Please correct the errors in this form.'
      render 'new'
    end
  end

  def show
    page_crumbs :pages_home, :project_modules_index, :project_modules_show

    @project_module = ProjectModule.find(params[:id])
  end

  def edit_project_module
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_edit

    @project_module = ProjectModule.find(params[:id])
    @spatial_list = Database.get_spatial_ref_list

    create_project_module_tmp_dir

    project_module_setting = JSON.parse(safe_file_read(@project_module.get_path(:settings)))
    @name = @project_module.name
    @version = project_module_setting['version']
    @season = project_module_setting['season']
    @description = project_module_setting['description']
    @permit_no = project_module_setting['permit_no']
    @permit_holder = project_module_setting['permit_holder']
    @contact_address = project_module_setting['contact_address']
    @participant = project_module_setting['participant']
    @srid = project_module_setting['srid']
    @permit_issued_by = project_module_setting['permit_issued_by']
    @permit_type = project_module_setting['permit_type']
    @copyright_holder = project_module_setting['copyright_holder']
    @client_sponsor = project_module_setting['client_sponsor']
    @land_owner = project_module_setting['land_owner']
    @has_sensitive_data = project_module_setting['has_sensitive_data']
  end

  def update_project_module
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_edit

    @project_module = ProjectModule.find(params[:id])
    @spatial_list = Database.get_spatial_ref_list

    parse_settings_from_params(params)

    @project_module.settings_mgr.with_exclusive_lock do
      if change_project_module(@tmpdir)
        begin
          @project_module.save
          @project_module.set_settings(params[:project_module])
          @project_module.update_project_module_from(@tmpdir)
          flash[:notice] = 'Updated module.'
        rescue Exception => e
          logger.error e

          flash[:error] = 'Failed to update module.'
        end

        return redirect_to :project_module
      else
        flash.now[:error] = 'Please correct the errors in this form.'
        return render 'edit_project_module'
      end
    end
  rescue MemberException, FileManager::TimeoutException => e
    logger.warn e

    flash.now[:error] = get_error_message(e)

    return render 'edit_project_module'
  end

  def delete_project_module
    @project_module = ProjectModule.find(params[:id])

    if not @project_module.deleted
      @project_module.with_exclusive_lock do
        @project_module.deleted = true
        @project_module.save

        flash[:notice] = 'Module Deleted.'
        redirect_to :project_modules
      end
    else
      flash[:error] = 'Cannot delete module.'
      redirect_to :project_modules
    end
  rescue FileManager::TimeoutException => e
    logger.warn e
    flash[:notice] = get_error_message(e)
    redirect_to :project_modules
  end

  def list_deleted_modules
    page_crumbs :pages_home, :project_modules_index, :project_modules_deleted
    @project_modules = ProjectModule.deleted
  end

  def restore_project_module
    @project_module = ProjectModule.deleted.find(params[:restore_id])

    if @project_module.deleted
      @project_module.deleted = false
      @project_module.save

      flash[:notice] = 'Module Restored.'
      redirect_to :project_modules
    else
      flash[:error] = 'Cannot restore module.'
      redirect_to :project_modules
    end
  end

  def archive_project_module
    @project_module = ProjectModule.find(params[:id])

    if @project_module.package_mgr.has_changes?
      job = @project_module.delay.archive_project_module
      render json: { result: 'waiting', jobid: job.id }
    else
      render json: { result: 'success', url: download_project_module_path(@project_module) }
    end
  end

  def check_archive_status
    @project_module = ProjectModule.find(params[:id])

    job = Delayed::Job.find_by_id(params[:jobid])
    if !job.nil? and job.last_error?
      logger.error job.last_error
      job.destroy
    end
    render json: { result: job.nil? ? 'success' : (job.last_error? ? 'failure' : 'waiting'), url: download_project_module_path(@project_module) }
  end

  def download_project_module
    @project_module = ProjectModule.find(params[:id])

    if File.exists? @project_module.get_path(:package_archive)
      @project_module.with_shared_lock do
        safe_send_file @project_module.get_path(:package_archive), :type => 'application/bzip2', :x_sendfile => true, :stream => false
      end
    else
      flash[:error] = 'Failed to archive module.'

      redirect_to project_module_path(@project_module)
    end
  rescue MemberException, FileManager::TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)

    redirect_to project_module_path(@project_module)
  end

  def upload_project_module
    page_crumbs :pages_home, :project_modules_index, :project_modules_upload

    @project_module = ProjectModule.new
  end

  def upload_new_project_module
    page_crumbs :pages_home, :project_modules_index, :project_modules_upload

    @project_module = ProjectModule.new

    unless SpatialiteDB.library_exists?
      flash.now[:error] = 'Cannot find library libspatialite. Please install library to upload module.'
      return render 'upload_project_module'
    end

    if params[:project_module]
      ProjectModule.upload_project_module(params[:project_module][:project_module_file].tempfile.to_path.to_s)
      flash[:notice] = 'Module has been successfully uploaded.'
      redirect_to :project_modules
    else
      flash.now[:error] = 'Please upload an archive of the module.'
      render 'upload_project_module'
    end
  rescue ProjectModule::ProjectModuleException => e
    logger.error e

    flash.now[:error] = e.message

    render 'upload_project_module'
  end

  def export_project_module
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_export

    @exporters = ProjectExporter.all.sort_by &:name

    render 'export_project_module'
  end

  def run_export_project_module
    @project_module = ProjectModule.find(params[:id])

    exporter = ProjectExporter.find_by_key(params[:exporter_key])
    input = params[:exporter_interface].present? ? params[:exporter_interface] : nil
    attributes = exporter.parse_interface_inputs(input)

    download_dir = File.join("/tmp", "download_export_" + SecureRandom.uuid)
    Dir.mkdir(download_dir)
    markup_file = File.open(File.join("/tmp", "export_markup_" + SecureRandom.uuid), "w+").path

    session[:export_download] = download_dir
    session[:export_markup] = markup_file

    job = @project_module.delay.export_project_module(exporter, attributes, download_dir, markup_file)
    render json: { result: 'waiting', jobid: job.id }
  end

  def check_export_status
    @project_module = ProjectModule.find(params[:id])

    job = Delayed::Job.find_by_id(params[:jobid])
    code = 1 if job.nil?
    if !job.nil? and job.last_error?
      logger.error job.last_error
      job.destroy
    end
    render json: { result: job.nil? ? 'success' : (job.last_error? ? 'failure' : 'waiting'), url: show_export_results_path(@project_module, :code => code) }
  end

  def show_export_results
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_export, :project_modules_export_results

    markup_file = session[:export_markup]
    if markup_file.present? and File.exist? markup_file
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(escape_html: true))
      @markup = markdown.render(File.open(session[:export_markup], "r").read)
    end

    download_entries = (Dir.entries(session[:export_download]) - %w{ . .. }) unless !File.exist? session[:export_download]
    @has_download_file = !download_entries.nil? && !download_entries.empty?

    if params[:code].to_i == 1
      flash.now[:notice] = "Module exported successfully"
    else
      flash[:error] = "Failed to export module"
      redirect_to export_project_module_path(@project_module) and return
    end

    render 'show_export_results'
  end

  def download_export_file
    @project_module = ProjectModule.find(params[:id])
    if session[:export_download].present? and File.exist? session[:export_download] and File.directory? session[:export_download]
      download_file = (Dir.entries(session[:export_download]) - %w{ . .. }).first
      if download_file.present?
        send_file File.join(session[:export_download], download_file), :filename => download_file
        return
      end
    end
    flash[:error] = 'Export file does not exist'
    redirect_to export_project_module_path(@project_module)
  end

  def download_attached_file
    safe_send_file safe_root_join("modules/#{ProjectModule.find(params[:id]).key}/#{params[:path]}"), :filename => params[:name]
  end
  
  private

  def create_project_module_tmp_dir
    @tmpdir = Dir.mktmpdir
    session[:data_schema] = false
    session[:ui_schema] = false
    session[:ui_logic] = false
    session[:arch16n] = false
    session[:validation_schema] = false
    session[:css_style] = false
  end

  def create_project_module(tmpdir)
    if params[:project_module]
      @project_module = ProjectModule.new(:name => params[:project_module][:name], :key => SecureRandom.uuid) if params[:project_module]
      @project_module.valid?
    end

    validate_data_schema(tmpdir)
    validate_ui_schema(tmpdir)
    validate_ui_logic(tmpdir)
    validate_arch16n(tmpdir)
    validate_validation_schema(tmpdir)
    validate_css_style(tmpdir)
    
    @project_module.errors.empty?
  end

  def change_project_module(tmpdir)
    if params[:project_module]
      @project_module.assign_attributes(:name => params[:project_module][:name]) if params[:project_module]
      @project_module.valid?
    end

    validate_ui_schema(tmpdir) unless params[:project_module][:ui_schema].blank?
    validate_ui_logic(tmpdir) unless params[:project_module][:ui_logic].blank?
    validate_arch16n(tmpdir) unless params[:project_module][:arch16n].blank?
    validate_validation_schema(tmpdir) unless params[:project_module][:validation_schema].blank?
    validate_css_style(tmpdir) unless params[:project_module][:css_style].blank?

    @project_module.errors.empty?
  end

  def validate_data_schema(tmpdir)
    validate_file(:data_schema, :data_schema, tmpdir)
  end

  def validate_ui_schema(tmpdir)
    validate_file(:ui_schema, :ui_schema, tmpdir)
  end

  def validate_ui_logic(tmpdir)
    validate_file(:ui_logic, :ui_logic, tmpdir)
  end

  def validate_validation_schema(tmpdir)
    validate_file(:validation_schema, :validation_schema, tmpdir)
  end

  def validate_css_style(tmpdir)
    validate_file(:css_style, :css_style, tmpdir)
  end

  def validate_arch16n(tmpdir)
    validate_file(:arch16n, :properties, tmpdir)
  end

  def validate_file(filetype, filename, tmpdir)
    if !session[filetype]
      @project_module.send("validate_#{filetype}", params[:project_module][filetype])
      if @project_module.errors[filetype].empty?
        if !params[:project_module][filetype].nil?
          create_temp_file(@project_module.get_name(filename), params[:project_module][filetype], tmpdir)
          session[filetype] = true
        end
      end
    end
  end

  def create_temp_file(filename, upload, tmpdir)
    File.open(upload.tempfile, 'r') do |upload_file|
      File.open(tmpdir + '/' + filename, 'w') do |temp_file|
        temp_file.write(upload_file.read)
      end
    end
  end

  def parse_settings_from_params(params)
    @tmpdir = params[:project_module][:tmpdir]
    @name = params[:project_module][:name]
    @version = params[:project_module][:version]
    @season = params[:project_module][:season]
    @description = params[:project_module][:description]
    @permit_no = params[:project_module][:permit_no]
    @permit_holder = params[:project_module][:permit_holder]
    @contact_address = params[:project_module][:contact_address]
    @participant = params[:project_module][:participant]
    @srid = params[:project_module][:srid]
    @permit_issued_by = params[:project_module][:permit_issued_by]
    @permit_type = params[:project_module][:permit_type]
    @copyright_holder = params[:project_module][:copyright_holder]
    @client_sponsor = params[:project_module][:client_sponsor]
    @land_owner = params[:project_module][:land_owner]
    @has_sensitive_data = params[:project_module][:has_sensitive_data]
  end

end

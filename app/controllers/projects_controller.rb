class ProjectsController < ApplicationController

  require File.expand_path("../../projects/models/database",__FILE__)
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index

  end

  def new
    @project = Project.new

    # make temp directory and store its path in session
    create_tmp_dir
  end

  def create
    # create project if valid and schemas uploaded

    valid = create_project

    if valid

      @project.transaction do
        @project.save

        @project.create_project_from(session[:tmpdir])
        FileUtils.remove_entry_secure session[:tmpdir]
      end

      flash[:notice] = t 'projects.new.success'
      redirect_to :projects
    else
      flash.now[:error] = t 'projects.new.failure'
      render 'new'
    end
  end

  def show
    @project = Project.find(params[:id])
  end

  def list_arch_ent_records
    @project = Project.find(params[:id])
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    @type = Database.get_arch_ent_types(@project.db_path)
    session.delete(:values)
    session.delete(:type)
    session.delete(:query)
    session.delete(:cur_offset)
    session.delete(:prev_offset)
    session.delete(:next_offset)
  end

  def list_typed_arch_ent_records
    @project = Project.find(params[:id])
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    limit = 25
    type = params[:type]
    offset = params[:offset]
    session[:type] = type
    session[:cur_offset] = offset
    session[:prev_offset] = Integer(offset) - Integer(limit)
    session[:next_offset] = Integer(offset) + Integer(limit)
    @uuid = Database.load_arch_entity(@project.db_path,type,limit,offset)
  end

  def search_arch_ent_records
    @project = Project.find(params[:id])
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    session.delete(:values)
    session.delete(:type)
    session.delete(:query)
    session.delete(:cur_offset)
    session.delete(:prev_offset)
    session.delete(:next_offset)
  end

  def show_arch_ent_records
    @project = Project.find(params[:id])
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    limit = 25
    query = params[:query]
    offset = params[:offset]
    session[:query] = query
    session[:cur_offset] = offset
    session[:prev_offset] = Integer(offset) - Integer(limit)
    session[:next_offset] = Integer(offset) + Integer(limit)
    @uuid = Database.search_arch_entity(@project.db_path,limit,offset,query)
  end

  def edit_arch_ent_records
    @project = Project.find(params[:id])
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    uuid = params[:uuid]
    session[:uuid] = uuid
    @attributes = Database.get_arch_entity_attributes(@project.db_path,uuid)
    @vocab_name = {}
    for attribute in @attributes
      @vocab_name[attribute[1]] = Database.get_vocab(@project.db_path,attribute[1])
    end
  end

  def update_arch_ent_records
    @project = Project.find(params[:id])
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    uuid = params[:uuid]
    vocab_id = !params[:project][:vocab_id].blank? ? params[:project][:vocab_id] : nil
    attribute_id = !params[:project][:attribute_id].blank? ? params[:project][:attribute_id] : nil
    measure = !params[:project][:measure].blank? ? params[:project][:measure] : nil
    freetext = !params[:project][:freetext].blank? ? params[:project][:freetext] : nil
    certainty = !params[:project][:certainty].blank? ? params[:project][:certainty] : nil

    Database.update_arch_entity_attribute(@project.key, @project.db_path,uuid,vocab_id,attribute_id, measure, freetext, certainty)
    @project.update_archives

    @attributes = Database.get_arch_entity_attributes(@project.db_path,uuid)
    @vocab_name = {}
    for attribute in @attributes
      @vocab_name[attribute[1]] = Database.get_vocab(@project.db_path,attribute[1])
    end
    render 'edit_arch_ent_records'
  end

  def delete_arch_ent_records
    @project = Project.find(params[:id])
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    uuid = params[:uuid]
    Database.delete_arch_entity(@project.key, @project.db_path,uuid)
    @project.update_archives

    if session[:type]
      redirect_to(list_typed_arch_ent_records_path(@project) + "?type=" + session[:type] + "&offset=0")
    else
      redirect_to(show_arch_ent_records_path(@project) + "?query=" + session[:query] + "&offset=0")
    end

  end

  def list_rel_records
    @project = Project.find(params[:id])
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    @type = Database.get_rel_types(@project.db_path)
    session[:values] = []
  end

  def list_typed_rel_records
    @project = Project.find(params[:id])
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    limit = 25
    type=params[:type]
    offset = params[:offset]
    session[:type] = type
    session[:cur_offset] = offset
    session[:prev_offset] = Integer(offset) - Integer(limit)
    session[:next_offset] = Integer(offset) + Integer(limit)
    @relationshipid = Database.load_rel(@project.db_path,type,limit,offset)
  end

  def search_rel_records
    @project = Project.find(params[:id])
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    session.delete(:values)
    session.delete(:type)
    session.delete(:query)
    session.delete(:cur_offset)
    session.delete(:prev_offset)
    session.delete(:next_offset)
  end

  def show_rel_records
    @project = Project.find(params[:id])
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    limit = 25
    query = params[:query]
    offset = params[:offset]
    session[:query] = query
    session[:cur_offset] = offset
    session[:prev_offset] = Integer(offset) - Integer(limit)
    session[:next_offset] = Integer(offset) + Integer(limit)
    @relationshipid = Database.search_rel(@project.db_path,limit,offset,query)
  end

  def edit_rel_records
    @project = Project.find(params[:id])
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    relationshipid = params[:relationshipid]
    session[:relationshipid] = relationshipid
    @attributes = Database.get_rel_attributes(@project.db_path,relationshipid)
    @vocab_name = {}
    for attribute in @attributes
      @vocab_name[attribute[2]] = Database.get_vocab(@project.db_path,attribute[2])
    end
  end

  def update_rel_records
    @project = Project.find(params[:id])
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    relationshipid = params[:relationshipid]
    vocab_id = !params[:project][:vocab_id].blank? ? params[:project][:vocab_id] : nil
    attribute_id = !params[:project][:attribute_id].blank? ? params[:project][:attribute_id] : nil
    freetext = !params[:project][:freetext].blank? ? params[:project][:freetext] : nil
    certainty = !params[:project][:certainty].blank? ? params[:project][:certainty] : nil

    Database.update_rel_attribute(@project.key, @project.db_path,relationshipid,vocab_id,attribute_id, freetext, certainty)
    @project.update_archives

    @attributes = Database.get_rel_attributes(@project.db_path,relationshipid)
    @vocab_name = {}
    for attribute in @attributes
      @vocab_name[attribute[2]] = Database.get_vocab(@project.db_path,attribute[2])
    end
    render 'edit_rel_records'
  end

  def delete_rel_records
    @project = Project.find(params[:id])
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    relationshipid = params[:relationshipid]
    Database.delete_relationship(@project.key, @project.db_path,relationshipid)
    @project.update_archives
    if session[:type]
      redirect_to(list_typed_rel_records_path(@project) + "?type=" + session[:type] + "&offset=0")
    else
      redirect_to(show_rel_records_path(@project) + "?query=" + session[:query] + "&offset=0")
    end
  end

  def add_entity_to_compare
    if !session[:values]
      session[:values] = []
    end
    if !session[:values].include?(params[:value])
      session[:values].push(params[:value])
    end

    render :nothing => true
  end

  def remove_entity_to_compare
    if(session[:values])
      session[:values].delete(params[:value])
    end
    render :nothing => true
  end

  def compare_arch_ents
    @project = Project.find(params[:id])
    session[:values] = []
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    ids = params[:ids]
    @first_arch_ent = Database.get_arch_entity_attributes(@project.db_path, ids[0])
    @second_arch_ent = Database.get_arch_entity_attributes(@project.db_path, ids[1])
  end

  def select_arch_ents
    @project = Project.find(params[:id])
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    deleted_id = params[:deleted_id]
    Database.delete_arch_entity(@project.key, @project.db_path, deleted_id)
    redirect_to(list_typed_arch_ent_records_path(@project) + "?type=" + session[:type] + "&offset=0")
  end

  def compare_rel
    @project = Project.find(params[:id])
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    ids = params[:ids]
    session[:values] = []
    @first_rel = Database.get_rel_attributes(@project.db_path, ids[0])
    @second_rel = Database.get_rel_attributes(@project.db_path, ids[1])
  end

  def select_rel
    @project = Project.find(params[:id])
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    deleted_id = params[:deleted_id]
    Database.delete_relationship(@project.key, @project.db_path, deleted_id)
    redirect_to(list_typed_rel_records_path(@project) + "?type=" + session[:type] + "&offset=0")
  end

  def edit_project_setting
    @project = Project.find(params[:id])
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    @project_setting = JSON.parse(@project.project_setting)
  end

  def update_project_setting
    if @project.is_locked
      flash.now[:error] = 'Project is locked because archiving process is in progress'
      render 'show'
    end
    if @project.update_attributes(:name => params[:project][:name])
        File.open(@project.dir_path + "/project.settings", 'w') do |file|
        file.write({:name => params[:project][:name], key:@project.key,
                    :season => params[:project][:season],
                    :description => params[:project][:description],
                    :permit_no => params[:project][:permit_no],
                    :permit_holder => params[:project][:permit_holder],
                    :contact_address => params[:project][:contact_address],
                    :participant => params[:project][:participant]
                   }.to_json)
      end
      @project.update_archives
      session[:name] = ""
      flash[:notice] = "Static data updated"
      redirect_to :project
    else
      @project_setting = JSON.parse(@project.project_setting)
      render 'edit_project_setting'
    end
  end

  def update

  end

  def archive_project
    @project = Project.find(params[:id])
    begin
      session[:job] = Project.delay.package_project_for(@project.key)
    rescue Exception => e
      puts "Error archiving project"
      FileUtils.rm (@project.dir_path + '/lock') if File.exists?(@project.dir_path + '/lock')
      raise e
    end
    respond_to do |format|
      format.json { render :json => {:archive => 'false'} } if @project.is_locked
      format.json { render :json => {:archive => 'true'} } if !@project.is_locked
    end
  end

  def check_archive_status
    @project = Project.find(params[:id])
    jobid = session[:job].id
    if !Delayed::Job.exists?(jobid)
      FileUtils.rm (@project.dir_path + '/lock') if File.exists?(@project.dir_path + '/lock')
      session[:job] = nil
    end
    respond_to do |format|
      format.json { render :json => {:finish => 'false'} } if Delayed::Job.exists?(jobid)
      format.json { render :json => {:finish => 'true'} } if !Delayed::Job.exists?(jobid)
    end
  end

  def download_project
    @project = Project.find(params[:id])

    send_file @project.temp_project_file_path, :type => "application/bzip2", :x_sendfile => true, :stream => false
  end

  def upload_project
    @project = Project.new
  end

  def upload_new_project
    if params[:project]
      tar_file = params[:project][:project_file]
      if !(tar_file.content_type.eql?('application/x-bzip') || tar_file.content_type.eql?('application/x-bzip2'))
        @project = Project.new
        flash.now[:error] = 'Unsupported format of file, please upload the correct file'
        render 'upload_project'
      else
        tmp_dir = Dir.mktmpdir(Project.projects_path + "/") + "/";
        `tar xjf #{tar_file.tempfile.to_path.to_s} -C #{tmp_dir}`
        project_settings = JSON.parse(File.read(tmp_dir + 'project/' + Project.project_settings_name).as_json)
        if !Project.find_by_key(project_settings['key']).blank?
          FileUtils.rm_rf tmp_dir
          @project = Project.new
          flash.now[:error] = 'This project already exists in the system'
          render 'upload_project'
        elsif !Project.checksum_uploaded_file(tmp_dir + 'project/')
          FileUtils.rm_rf tmp_dir
          @project = Project.new
          flash.now[:error] = 'Wrong hash sum for the project'
          render 'upload_project'
        else
          @project = Project.new(:name => project_settings['name'], :key => project_settings['key'])
          @project.transaction do
            @project.save
            @project.create_project_from_compressed_file(tmp_dir + 'project')
          end
          FileUtils.rm_rf tmp_dir
          flash[:notice] = 'Project has been successfully uploaded'
          redirect_to :projects
        end
      end
    else
      @project = Project.new
      flash.now[:error] = 'Please upload an archive of the project'
      render 'upload_project'
    end
  end
  private

  def create_tmp_dir
    clear_tmp_dir
    tmpdir = Dir.mktmpdir
    session[:tmpdir] = tmpdir
    session[:data_schema] = false
    session[:ui_schema] = false
    session[:ui_logic] = false
    session[:arch16n] = false
  end

  def clear_tmp_dir
    FileUtils.remove_entry_secure session[:tmpdir] if !session[:tmpdir].blank? and File.directory? session[:tmpdir]
    session[:tmpdir] = nil
  end

  def create_project
    # check if project is valid

    valid = false
    if params[:project]
      @project = Project.new(:name => params[:project][:name], :key => SecureRandom.uuid) if params[:project]
      valid = @project.valid?
      tmpdir = session[:tmpdir]
      File.open(tmpdir + "/project.settings", 'w') do |file|
        file.write({:name => @project.name, key:@project.key,
                    :season => params[:project][:season],
                    :description => params[:project][:description],
                    :permit_no => params[:project][:permit_no],
                    :permit_holder => params[:project][:permit_holder],
                    :contact_address => params[:project][:contact_address],
                    :participant => params[:project][:participant]
                   }.to_json)
      end
    end

    # check if data schema is valid
    if !session[:data_schema]
      error = if params[:project].nil?
                "can't be blank."
              else
                Project.validate_data_schema(params[:project][:data_schema])
              end
      if error
        @project.errors.add(:data_schema, error)
        valid = false
      else
        create_temp_file("data_schema.xml", params[:project][:data_schema])
        session[:data_schema] = true
      end
    end

    # check if ui schema is valid
    if !session[:ui_schema]
      error = if params[:project].nil?
                "can't be blank."
              else
                Project.validate_ui_schema(params[:project][:ui_schema])
              end
      if error
        @project.errors.add(:ui_schema, error)
        valid = false
      else
        create_temp_file("ui_schema.xml", params[:project][:ui_schema])
        session[:ui_schema] = true
      end
    end

    # check if ui logic is valid
    if !session[:ui_logic]
      error = nil
      if params[:project].nil? ||
          params[:project][:ui_logic].nil?
        error = "can't be blank"
      end

      # TODO: what is the content type of the file? should it be checked?

      if error
        @project.errors.add(:ui_logic, error)
        valid = false
      else
        create_temp_file("ui_logic.bsh", params[:project][:ui_logic])
        session[:ui_logic] = true
      end
    end

    # check if arch16n is valid
    if !session[:arch16n]
      error = if !params[:project][:arch16n].nil?
                Project.validate_arch16n(params[:project][:arch16n],params[:project][:name])
              end

      if error
        @project.errors.add(:arch16n, error)
        valid = false
      else
        if !params[:project][:arch16n].nil?
          create_temp_file("faims_"+params[:project][:name].gsub(/\s+/, '_')+".properties", params[:project][:arch16n])
          session[:arch16n] = true
        end
      end
    end
    if !valid
      session[:season] = params[:project][:season]
      session[:description] = params[:project][:description]
      session[:permit_no] = params[:project][:permit_no]
      session[:permit_holder] = params[:project][:permit_holder]
      session[:contact_address] = params[:project][:contact_address]
      session[:participant] = params[:project][:participant]
    else
      session[:season] = ""
      session[:description] = ""
      session[:permit_no] = ""
      session[:permit_holder] = ""
      session[:contact_address] = ""
      session[:participant] = ""
    end
    valid
  end

  def create_temp_file(filename, upload)
    tmpdir = session[:tmpdir]
    #logger.debug tmpdir + "/" + filename
    File.open(upload.tempfile, 'r') do |upload_file|
      File.open(tmpdir + "/" + filename, 'w') do |temp_file|
        temp_file.write(upload_file.read)
      end
    end
  end

end

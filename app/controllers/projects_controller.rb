require Rails.root.join('app/models/projects/database')

class ProjectsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource

  before_filter :authenticate_project_user, only: [:update_project_user,
                                                   :update_arch_ent_records,
                                                   :delete_arch_ent_records,
                                                   :undelete_arch_ent_records,
                                                   :merge_arch_ents,
                                                   :revert_arch_ent_to_timestamp,
                                                   :update_rel_records,
                                                   :revert_rel_to_timestamp,
                                                   :delete_rel_records,
                                                   :undelete_rel_records,
                                                   :remove_arch_ent_member,
                                                   :add_arch_ent_member,
                                                   :add_rel_association,
                                                   :update_attributes_vocab]

  def crumbs
    project = Project.find(params[:id]) if params[:id]
    uuid = params[:uuid]
    relationshipid = params[:relationshipid]

    #TODO fix paths to use url params instead of session params
    type = session[:type]
    query = session[:query]
    offset = session[:cur_offset]

    list_arch_ent = session[:action].eql?('list_typed_arch_ent_records')
    list_rel = session[:action].eql?('list_typed_rel_records')

    query_params = '?'
    query_params << "type=#{type}&" if type
    query_params << "query=#{query}&" if query
    query_params << "offset=#{offset}&" if offset

    @crumbs =
      {
          :pages_home => {title: 'Home', url: pages_home_path},
          :projects_index => {title: 'Projects', url: projects_path},
          :projects_create => {title: 'Create', url: new_project_path},
          :projects_upload => {title: 'Upload', url: upload_project_path},
          :projects_show => {title: project ? project.name : nil, url: project ? project_path(project) : nil},
          :projects_edit => {title: 'Edit', url: project ? edit_project_path(project) : nil},
          :projects_vocabulary => {title: 'Vocabulary', url: project ? list_attributes_with_vocab_path(project) : nil},
          :projects_users => {title: 'Users', url: project ? edit_project_user_path(project) : nil},
          :projects_files => {title: 'Files', url: project ? project_file_list_path(project) : nil},

          :projects_search_or_list_arch_ent => !list_arch_ent ? {title: 'Search Entity', url: project ? search_arch_ent_records_path(project) : nil} : {title: 'List Entity', url: project ? list_arch_ent_records_path(project) : nil},
          :projects_search_arch_ent => {title: 'Search Entity', url: project ? search_arch_ent_records_path(project) : nil},
          :projects_list_arch_ent => {title: 'List Entity', url: project ? list_arch_ent_records_path(project) : nil},
          :projects_show_arch_ent => {title: 'Entities', url: project ? (query ? show_arch_ent_records_path(project) : list_typed_arch_ent_records_path(project)) + query_params : nil},
          :projects_compare_arch_ent => {title: 'Compare', url: project ? compare_arch_ents_path(project) : nil},
          :projects_edit_arch_ent => {title: 'Edit', url: (project and uuid) ? edit_arch_ent_records_path(project, uuid) : nil},
          :projects_show_arch_ent_history => {title: 'History', url: (project and uuid) ? show_arch_ent_history_path(project, uuid) : nil},
          :projects_show_arch_ent_associations => {title: 'Associations', url: (project and uuid) ? show_rel_association_path(project, uuid) : nil},
          :projects_search_arch_ent_associations => {title: 'Search Association', url: (project and uuid) ? search_rel_association_path(project, uuid) : nil},

          :projects_search_or_list_rel => !list_rel ? {title: 'Search Relationship', url: project ? search_rel_records_path(project) : nil} : {title: 'List Relationship', url: project ? list_rel_records_path(project) : nil},
          :projects_search_rel => {title: 'Search Relationship', url: project ? search_rel_records_path(project) : nil},
          :projects_list_rel => {title: 'List Relationship', url: project ? list_rel_records_path(project) : nil},
          :projects_show_rel => {title: 'Relationships', url: project ? (query ? show_rel_records_path(project) : list_typed_rel_records_path(project)) + query_params : nil},
          :projects_compare_rel => {title: 'Compare', url: project ? compare_rel_path(project) : nil},
          :projects_edit_rel => {title: 'Edit', url: (project and relationshipid) ? edit_rel_records_path(project, relationshipid) : nil},
          :projects_show_rel_history => {title: 'History', url: (project and relationshipid) ? show_rel_history_path(project, relationshipid) : nil},
          :projects_show_rel_associations => {title: 'Associations', url: (project and relationshipid) ? show_rel_association_path(project, relationshipid) : nil},
          :projects_search_rel_associations => {title: 'Search Association', url: (project and relationshipid) ? search_rel_association_path(project, relationshipid) : nil},
      }
  end

  def authenticate_project_user
    @project = Project.find(params[:id])
    redirect_to :projects unless @project
    userids = @project.db.get_list_of_users.map { |x| x.first }
    unless userids.include? current_user.id
      flash[:error] = "Only project users can edit the database. Please get a project user to add you to the project."
      redirect_to :projects
    end
  end

  def index
    @page_crumbs = [:pages_home, :projects_index]
  end

  def new
    @page_crumbs = [:pages_home, :projects_index, :projects_create]

    @project = Project.new
    @spatial_list = Database.get_spatial_ref_list

    # make temp directory and store its path in session
    create_tmp_dir
  end

  def create
    @page_crumbs = [:pages_home, :projects_index, :projects_create]

    # create project if valid and schemas uploaded

    unless SpatialiteDB.library_exists?
      @spatial_list = Database.get_spatial_ref_list
      flash.now[:error] = 'Cannot find library libspatialite. Please install library to create project.'
      render 'new'
      return
    end

    valid = create_project

    if valid

      begin
        @project.save
        @project.update_settings(params)
        @project.create_project_from(session[:tmpdir], current_user)
      rescue
        FileUtils.rm_rf @project.get_path(:project_dir) if File.directory? @project.get_path(:project_dir)
        @project.destroy
      ensure
        FileUtils.remove_entry_secure session[:tmpdir]
      end

      flash[:notice] = t 'projects.new.success'
      redirect_to :projects
    else
      @spatial_list = Database.get_spatial_ref_list
      flash.now[:error] = t 'projects.new.failure'
      render 'new'
    end
  end

  def show
    @page_crumbs = [:pages_home, :projects_index, :projects_show]

    @project = Project.find(params[:id])
    session[:has_attached_files] = @project.has_attached_files
  end

  def edit_project_user
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_users]

    @project = Project.find(params[:id])
    @users = @project.db.get_list_of_users
    user_transpose = @users.transpose
    @server_user = User.all.select { |x| user_transpose.empty? or !user_transpose[0].include? x.id }
  end

  def update_project_user
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_users]

    @project = Project.find(params[:id])
    user = User.find(params[:user_id])
    @project.db.update_list_of_users(user, current_user.id)
    @users = @project.db.get_list_of_users
    user_transpose = @users.transpose
    @server_user = User.all.select { |x| user_transpose.empty? or !user_transpose[0].include? x.id }
    flash[:notice] = 'Successfully updated user'
    render 'edit_project_user'
  end

  # Arch entity functionalities

  def list_arch_ent_records
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_list_arch_ent]

    @project = Project.find(params[:id])
    @type = @project.db.get_arch_ent_types
    session.delete(:values)
    session.delete(:type)
    session.delete(:query)
    session.delete(:action)
    session.delete(:show)
    session.delete(:cur_offset)
    session.delete(:prev_offset)
    session.delete(:next_offset)
    session.delete(:show_deleted)
    session.delete(:prev_id)
  end

  def list_typed_arch_ent_records
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_list_arch_ent, :projects_show_arch_ent]

    @project = Project.find(params[:id])
    limit = 25
    type = params[:type]
    offset = params[:offset] ? params[:offset] : '0'
    show_deleted = params[:show_deleted].nil? ||params[:show_deleted].empty? ? false : true
    session[:show_deleted] = show_deleted ? 'true' : nil
    session[:type] = type
    session[:cur_offset] = offset
    session[:prev_offset] = Integer(offset) - Integer(limit)
    session[:next_offset] = Integer(offset) + Integer(limit)
    session[:action] = 'list_typed_arch_ent_records'
    @uuid = @project.db.load_arch_entity(type,limit,offset, show_deleted)

    @entity_dirty_map = {}
    @entity_forked_map = {}
    @uuid.each do |row|
      @entity_dirty_map[row[0]] = @project.db.is_arch_entity_dirty(row[0]) unless @entity_dirty_map[row[0]]
      @entity_forked_map[row[0]] = @project.db.is_arch_entity_forked(row[0]) unless @entity_forked_map[row[0]]
    end

  end

  def search_arch_ent_records
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_search_arch_ent]

    @project = Project.find(params[:id])
    session.delete(:values)
    session.delete(:type)
    session.delete(:query)
    session.delete(:action)
    session.delete(:show)
    session.delete(:cur_offset)
    session.delete(:prev_offset)
    session.delete(:next_offset)
    session.delete(:show_deleted)
    session.delete(:prev_id)
  end

  def show_arch_ent_records
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_search_arch_ent, :projects_show_arch_ent]

    @project = Project.find(params[:id])
    limit = 25
    query = params[:query]
    offset = params[:offset] ? params[:offset] : '0'
    show_deleted = params[:show_deleted].nil? ||params[:show_deleted].empty? ? false : true
    session[:show_deleted] = show_deleted ? 'true' : nil
    session[:query] = query
    session[:cur_offset] = offset
    session[:prev_offset] = Integer(offset) - Integer(limit)
    session[:next_offset] = Integer(offset) + Integer(limit)
    session[:action] = 'show_arch_ent_records'
    @uuid = @project.db.search_arch_entity(limit,offset,query,show_deleted)

    @entity_dirty_map = {}
    @entity_forked_map = {}
    @uuid.each do |row|
      @entity_dirty_map[row[0]] = @project.db.is_arch_entity_dirty(row[0]) unless @entity_dirty_map[row[0]]
      @entity_forked_map[row[0]] = @project.db.is_arch_entity_forked(row[0]) unless @entity_forked_map[row[0]]
    end
  end

  def edit_arch_ent_records
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_search_or_list_arch_ent, :projects_show_arch_ent, :projects_edit_arch_ent]

    @project = Project.find(params[:id])
    uuid = params[:uuid]
    session[:uuid] = uuid
    if !session[:show].nil? and session[:show][-1].eql?('show_rel_associations')
      session[:show].pop()
    end
    @attributes = @project.db.get_arch_entity_attributes(uuid)
    @vocab_name = {}
    for attribute in @attributes
      @vocab_name[attribute[1]] = @project.db.get_vocab(attribute[1])
    end

    if @project.db.is_arch_entity_forked(uuid)
      flash.now[:warning] = "This Archaeological Entity record contains conflicting data. Please click 'Show History' to resolve the conflicts."
    end

    @deleted = @project.db.get_arch_entity_deleted_status(uuid)
    @related_arch_ents = @project.db.get_related_arch_entities(uuid)
    prev_id = params[:prev_id]
    if prev_id.nil?
      if !session[:prev_id].nil?
        session[:prev_id].pop()
      end
    else
      if session[:prev_id].nil?
        session[:prev_id] = []
      end
      if !session[:prev_id][-1].eql?(prev_id)
        session[:prev_id].push(prev_id)
      end
    end
  end

  def update_arch_ent_records
    @project = Project.find(params[:id])
    if @project.db_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
      return
    else
      uuid = params[:uuid]
      vocab_id = !params[:attr][:vocab_id].blank? ? params[:attr][:vocab_id] : nil
      attribute_id = !params[:attr][:attribute_id].blank? ? params[:attr][:attribute_id] : nil
      measure = !params[:attr][:measure].blank? ? params[:attr][:measure] : nil
      freetext = !params[:attr][:freetext].blank? ? params[:attr][:freetext] : nil
      certainty = !params[:attr][:certainty].blank? ? params[:attr][:certainty] : nil

      ignore_errors = !params[:attr][:ignore_errors].blank? ? params[:attr][:ignore_errors] : nil

      @project.db.update_arch_entity_attribute(uuid,current_user.id,vocab_id,attribute_id, measure, freetext, certainty, ignore_errors)

      redirect_to edit_arch_ent_records_path(@project, uuid)
    end

  end

  def delete_arch_ent_records
    @project = Project.find(params[:id])
    if @project.db_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
      return
    end

    uuid = params[:uuid]
    @project.db.delete_arch_entity(uuid,current_user.id)

    show_deleted = session[:show_deleted].nil? ? '' : session[:show_deleted]
    if session[:type]
      redirect_to(list_typed_arch_ent_records_path(@project) + '?type=' + session[:type] + '&offset=0&show_deleted=' + show_deleted)
    else
      redirect_to(show_arch_ent_records_path(@project) + '?query=' + session[:query] + '&offset=0&show_deleted=' + show_deleted)
    end

  end

  def undelete_arch_ent_records
    @project = Project.find(params[:id])
    if @project.db_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
      return
    end

    uuid = params[:uuid]
    @project.db.undelete_arch_entity(uuid,current_user.id)

    flash[:notice] = 'Successfully restored archaeological entity record'
    redirect_to edit_arch_ent_records_path(@project,uuid)

  end

  def compare_arch_ents
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_search_or_list_arch_ent, :projects_show_arch_ent, :projects_compare_arch_ent]

    @project = Project.find(params[:id])
    session[:values] = []
    session[:identifiers] = []
    session[:timestamps] = []
    ids = params[:ids]
    @identifiers = params[:identifiers]
    @timestamps = params[:timestamps]
    @first_uuid = ids[0]
    @second_uuid = ids[1]

    unless @project.db.is_arch_ent_same_type(@first_uuid, @second_uuid)
      flash[:error] = "Cannot compare Archaeological Entities of different types"
      redirect_to @project
    end
  end

  def merge_arch_ents
    @project = Project.find(params[:id])
    if @project.db_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
      return
    end

    @project.db.delete_arch_entity(params[:deleted_id],current_user.id)

    @project.db.insert_updated_arch_entity(params[:uuid],current_user.id, params[:vocab_id],params[:attribute_id], params[:measure], params[:freetext], params[:certainty])
    show_deleted = session[:show_deleted].nil? ? '' : session[:show_deleted]
    if session[:type]
      redirect_to(list_typed_arch_ent_records_path(@project) + '?type=' + session[:type] + '&offset=0&show_deleted=' + show_deleted)
      return
    else
      redirect_to(show_arch_ent_records_path(@project) + '?query=' + session[:query] + '&offset=0&show_deleted=' + show_deleted)
      return
    end
  end

  def show_arch_ent_history
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_search_or_list_arch_ent, :projects_show_arch_ent, :projects_edit_arch_ent, :projects_show_arch_ent_history]

    @project = Project.find(params[:id])
    uuid = params[:uuid]
    @timestamps = @project.db.get_arch_ent_history(uuid)
  end

  def revert_arch_ent_to_timestamp
    @project = Project.find(params[:id])

    data = params[:data].map { |x, y| y }

    entity = data.select { |x| x[:attributeid] == nil }.first
    attributes = data.select { |x| x[:attributeid] != nil }

    timestamp =  @project.db.current_timestamp

    @project.db.revert_arch_ent_to_timestamp(entity[:uuid], current_user.id, entity[:timestamp], timestamp)

    attributes.each do | attribute |
      @project.db.revert_aentvalues_to_timestamp(attribute[:uuid], current_user.id, attribute[:attributeid], attribute[:timestamp], timestamp)
    end

    # clear conflicts
    @project.db.resolve_arch_ent_conflicts(entity[:uuid]) if params[:resolve] == 'true'

    redirect_to show_arch_ent_history_path(@project, params[:uuid])
  end

  # Relationship functionalities

  def list_rel_records
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_list_rel]

    @project = Project.find(params[:id])
    @type = @project.db.get_rel_types
    session.delete(:values)
    session.delete(:type)
    session.delete(:query)
    session.delete(:action)
    session.delete(:show)
    session.delete(:cur_offset)
    session.delete(:prev_offset)
    session.delete(:next_offset)
    session.delete(:show_deleted)
  end

  def list_typed_rel_records
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_list_rel, :projects_show_rel]

    @project = Project.find(params[:id])
    limit = 25
    type=params[:type]
    offset = params[:offset] ? params[:offset] : '0'
    show_deleted = params[:show_deleted].nil? ||params[:show_deleted].empty? ? false : true
    session[:show_deleted] = show_deleted ? 'true' : nil
    session[:type] = type
    session[:cur_offset] = offset
    session[:prev_offset] = Integer(offset) - Integer(limit)
    session[:next_offset] = Integer(offset) + Integer(limit)
    session[:action] = 'list_typed_rel_records'
    @relationshipid = @project.db.load_rel(type,limit,offset,show_deleted)

    @rel_dirty_map = {}
    @rel_forked_map = {}
    @relationshipid.each do |row|
      @rel_dirty_map[row[0]] = @project.db.is_relationship_dirty(row[0]) unless @rel_dirty_map[row[0]]
      @rel_forked_map[row[0]] = @project.db.is_relationship_forked(row[0]) unless @rel_forked_map[row[0]]
    end
  end

  def search_rel_records
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_search_rel]

    @project = Project.find(params[:id])
    session.delete(:values)
    session.delete(:type)
    session.delete(:query)
    session.delete(:action)
    session.delete(:show)
    session.delete(:cur_offset)
    session.delete(:prev_offset)
    session.delete(:next_offset)
    session.delete(:show_deleted)
  end

  def show_rel_records
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_search_rel, :projects_show_rel]

    @project = Project.find(params[:id])
    limit = 25
    query = params[:query]
    offset = params[:offset] ? params[:offset] : '0'
    relationshipid = params[:relationshipid]
    show_deleted = params[:show_deleted].nil? ||params[:show_deleted].empty? ? false : true
    session[:show_deleted] = show_deleted ? 'true' : nil
    session[:relationshipid] = relationshipid
    session[:query] = query
    session[:cur_offset] = offset
    session[:prev_offset] = Integer(offset) - Integer(limit)
    session[:next_offset] = Integer(offset) + Integer(limit)
    session[:action] = 'show_rel_records'
    @relationshipid = @project.db.search_rel(limit,offset,query,show_deleted)

    @rel_dirty_map = {}
    @rel_forked_map = {}
    @relationshipid.each do |row|
      @rel_dirty_map[row[0]] = @project.db.is_relationship_dirty(row[0]) unless @rel_dirty_map[row[0]]
      @rel_forked_map[row[0]] = @project.db.is_relationship_forked(row[0]) unless @rel_forked_map[row[0]]
    end
  end

  def edit_rel_records
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_search_or_list_rel, :projects_show_rel, :projects_edit_rel]

    @project = Project.find(params[:id])
    relationshipid = params[:relationshipid]
    session[:relationshipid] = relationshipid
    if !session[:show].nil? and session[:show][-1].eql?('show_rel_members')
      session[:show].pop()
      p session[:show]
    end
    @attributes = @project.db.get_rel_attributes(relationshipid)
    @vocab_name = {}
    for attribute in @attributes
      @vocab_name[attribute[2]] = @project.db.get_vocab(attribute[2])
    end

    if @project.db.is_relationship_forked(relationshipid)
      flash.now[:warning] = "This Relationship record contains conflicting data. Please click 'Show History' to resolve the conflicts."
    end

    @deleted = @project.db.get_rel_deleted_status(relationshipid)

  end

  def update_rel_records
    @project = Project.find(params[:id])
    if @project.db_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
      return
    else
      relationshipid = params[:relationshipid]
      vocab_id = !params[:attr][:vocab_id].blank? ? params[:attr][:vocab_id] : nil
      attribute_id = !params[:attr][:attribute_id].blank? ? params[:attr][:attribute_id] : nil
      freetext = !params[:attr][:freetext].blank? ? params[:attr][:freetext] : nil
      certainty = !params[:attr][:certainty].blank? ? params[:attr][:certainty] : nil

      ignore_errors = !params[:attr][:ignore_errors].blank? ? params[:attr][:ignore_errors] : nil

      @project.db.update_rel_attribute(relationshipid,current_user.id,vocab_id,attribute_id, freetext, certainty, ignore_errors)

      redirect_to edit_rel_records_path(@project, relationshipid)
    end

  end

  def show_rel_history
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_search_or_list_rel, :projects_show_rel, :projects_edit_rel, :projects_show_rel_history]

    @project = Project.find(params[:id])
    relid = params[:relid]
    @timestamps = @project.db.get_rel_history(relid)
  end

  def revert_rel_to_timestamp
    @project = Project.find(params[:id])

    data = params[:data].map { |x, y| y }

    rel = data.select { |x| x[:attributeid] == nil }.first
    attributes = data.select { |x| x[:attributeid] != nil }

    timestamp = @project.db.current_timestamp

    @project.db.revert_rel_to_timestamp(rel[:relationshipid], current_user.id, rel[:timestamp], timestamp)

    attributes.each do | attribute |
      @project.db.revert_relnvalues_to_timestamp(attribute[:relationshipid], current_user.id, attribute[:attributeid], attribute[:timestamp], timestamp)
    end

    # clear conflicts
    @project.db.resolve_rel_conflicts(rel[:relationshipid]) if params[:resolve] == 'true'

    redirect_to show_rel_history_path(@project, params[:relid])
  end

  def delete_rel_records
    @project = Project.find(params[:id])
    if @project.db_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
      return
    end

    relationshipid = params[:relationshipid]
    @project.db.delete_relationship(relationshipid,current_user.id)
    show_deleted = session[:show_deleted].nil? ? '' : session[:show_deleted]
    if session[:type]
      redirect_to(list_typed_rel_records_path(@project) + '?type=' + session[:type] + '&offset=0&show_deleted=' + show_deleted)
    else
      redirect_to(show_rel_records_path(@project) + '?query=' + session[:query] + '&offset=0&show_deleted=' + show_deleted)
    end
  end

  def undelete_rel_records
    @project = Project.find(params[:id])
    if @project.db_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
      return
    end

    relationshipid = params[:relationshipid]
    @project.db.undelete_relationship(relationshipid,current_user.id)
    flash[:notice] = 'Successfully restored relationship record'
    redirect_to edit_rel_records_path(@project,relationshipid)
  end

  def show_rel_members
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_search_or_list_rel, :projects_show_rel, :projects_edit_rel, :projects_show_rel_associations]

    @project = Project.find(params[:id])
    session[:relationshipid] = params[:relationshipid]
    limit = 25
    offset = params[:offset] ? params[:offset] : '0'
    session[:relntypeid] = params[:relntypeid]
    session[:cur_offset] = offset
    session[:prev_offset] = Integer(offset) - Integer(limit)
    session[:next_offset] = Integer(offset) + Integer(limit)
    if session[:show].nil?
      session[:show] = []
      session[:show].push('show_rel_members')
    else
      if !session[:show][-1].eql?('show_rel_members')
        session[:show].push('show_rel_members')
      end
    end
    @uuid = @project.db.get_rel_arch_ent_members(params[:relationshipid], limit, offset)
  end

  def remove_arch_ent_member
    @project = Project.find(params[:id])
    relationshipid = params[:relationshipid]
    uuid = params[:uuid]
    @project.db.delete_member(relationshipid,current_user.id,uuid)
    render :nothing => true
  end

  def search_arch_ent_member
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_search_or_list_rel, :projects_show_rel, :projects_edit_rel, :projects_search_rel_associations]

    @project = Project.find(params[:id])
    session[:relationshipid] = params[:relationshipid]
    session[:relntypeid] = params[:relntypeid]
    if params[:search_query].nil?
      @uuid = nil
      @status = 'init'
      session.delete(:search_query)
    else
      limit = 25
      offset = params[:offset] ? params[:offset] : '0'
      session[:search_query] = params[:search_query]
      session[:cur_offset] = offset
      session[:prev_offset] = Integer(offset) - Integer(limit)
      session[:next_offset] = Integer(offset) + Integer(limit)
      @uuid = @project.db.get_non_member_arch_ent(params[:relationshipid],params[:search_query],limit,offset)
    end
    @verb = @project.db.get_verbs_for_relation(params[:relntypeid])
  end

  def add_arch_ent_member
    @project = Project.find(params[:id])
    @project.db.add_member(params[:relationshipid],current_user.id,params[:uuid],params[:verb])
    respond_to do |format|
      format.json { render :json => {:result => 'success', :url => show_rel_members_path(@project,params[:relationshipid])+'?offset=0&relntypeid='+params[:relntypeid]} }
    end
  end

  def show_rel_association
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_search_or_list_arch_ent, :projects_show_arch_ent, :projects_edit_arch_ent, :projects_show_arch_ent_associations]

    @project = Project.find(params[:id])
    session[:uuid] = params[:uuid]
    limit = 25
    offset = params[:offset] ? params[:offset] : '0'
    session[:cur_offset] = offset
    session[:prev_offset] = Integer(offset) - Integer(limit) if offset and limit
    session[:next_offset] = Integer(offset) + Integer(limit) if offset and limit
    if session[:show].nil?
      session[:show] = []
      session[:show].push('show_rel_associations')
    else
      if !session[:show][-1].eql?('show_rel_associations')
        session[:show].push('show_rel_associations')
      end
    end
    @relationships = @project.db.get_arch_ent_rel_associations(params[:uuid], limit, offset)
  end

  def search_rel_association
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_search_or_list_arch_ent, :projects_show_arch_ent, :projects_edit_arch_ent, :projects_show_arch_ent_associations,
      :projects_search_arch_ent_associations]

    @project = Project.find(params[:id])
    session[:uuid] = params[:uuid]
    if params[:search_query].nil?
      @uuid = nil
      @status = 'init'
      session.delete(:search_query)
    else
      limit = 25
      offset = params[:offset] ? params[:offset] : '0'
      session[:search_query] = params[:search_query]
      session[:cur_offset] = offset
      session[:prev_offset] = Integer(offset) - Integer(limit)
      session[:next_offset] = Integer(offset) + Integer(limit)
      @relationships = @project.db.get_non_arch_ent_rel_associations(params[:uuid],params[:search_query],limit,offset)
    end
  end

  def get_verbs_for_rel_association
    verbs = @project.db.get_verbs_for_relation(params[:relntypeid])
    respond_to do |format|
      format.json { render :json => verbs.to_json }
    end
  end

  def add_rel_association
    @project = Project.find(params[:id])
    @project.db.add_member(params[:relationshipid],current_user.id,params[:uuid],params[:verb])
    respond_to do |format|
      format.json { render :json => {:result => 'success', :url => show_rel_association_path(@project,params[:uuid])+'?offset=0'} }
    end
  end

  def add_entity_to_compare
    if !session[:values]
      session[:values] = []
    end
    if !session[:values].include?(params[:value])
      session[:values].push(params[:value])
    end
    if !session[:identifiers]
      session[:identifiers] = []
    end
    if !session[:identifiers].include?(params[:identifier])
      session[:identifiers].push(params[:identifier])
    end
    if !session[:timestamps]
      session[:timestamps] = []
    end
    if !session[:timestamps].include?(params[:timestamp])
      session[:timestamps].push(params[:timestamp])
    end

    render :nothing => true
  end

  def remove_entity_to_compare
    if(session[:values])
      session[:values].delete(params[:value])
    end
    if !session[:identifiers]
      session[:identifiers].delete(params[:identifier])
    end
    if !session[:timestamps]
      session[:timestamps].delete(params[:timestamp])
    end
    render :nothing => true
  end

  def compare_rel
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_search_or_list_rel, :projects_compare_rel]

    @project = Project.find(params[:id])
    ids = params[:ids]
    session[:values] = []
    session[:identifiers] = []
    session[:timestamps] = []
    @identifiers = params[:identifiers]
    @timestamps = params[:timestamps]
    @first_rel_id = ids[0]
    @second_rel_id = ids[1]

    unless @project.db.is_rel_same_type(@first_rel_id, @second_rel_id)
      flash[:error] = "Cannot compare Relationships of different types"
      redirect_to @project
    end
  end

  def merge_rel
    @project = Project.find(params[:id])
    if @project.db_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
      return
    end
    @project.db.delete_relationship(params[:deleted_id],current_user.id)

    @project.db.insert_updated_rel(params[:rel_id],current_user.id, params[:vocab_id], params[:attribute_id],  params[:freetext], params[:certainty])
    show_deleted = session[:show_deleted].nil? ? '' : session[:show_deleted]
    if session[:type]
      redirect_to(list_typed_rel_records_path(@project) + '?type=' + session[:type] + '&offset=0&show_deleted=' + show_deleted)
      return
    else
      redirect_to(show_rel_records_path(@project) + '?query=' + session[:query] + '&offset=0&show_deleted=' + show_deleted)
      return
    end
  end

  def list_attributes_with_vocab
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_vocabulary]

    @project = Project.find(params[:id])
    @attributes = @project.db.get_attributes_containing_vocab()
  end

  def list_vocab_for_attribute
    @project = Project.find(params[:id])
    attribute_id = params[:attribute_id]
    vocabs = @project.db.get_vocabs_for_attribute(attribute_id)
    vocabularies = []
    vocabs.each do |vocab|
      vocabulary = {}
      vocabulary['vocab_id'] = vocab[1]
      vocabulary['vocab_name'] = vocab[2]
      vocabularies.push(vocabulary)
    end
    respond_to do |format|
      format.json { render :json => vocabularies.to_json }
    end
  end

  def update_attributes_vocab
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_vocabulary]

    @project = Project.find(params[:id])
    if @project.db_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
      return
    end
    vocab_id = params[:vocab_id]
    vocab_name = params[:vocab_name]
    @attribute_id = params[:attribute_id]
    @project.db.update_attributes_vocab(@attribute_id, vocab_id, vocab_name, current_user.id)
    @attributes = @project.db.get_attributes_containing_vocab()
    flash[:notice] = 'Successfully updated vocabulary'
    render 'list_attributes_with_vocab'
  end

  def edit_project
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_edit]

    @project = Project.find(params[:id])
    project_setting = JSON.parse(File.read(@project.get_path(:settings)))
    session[:name] = @project.name
    session[:season] = project_setting['season']
    session[:description] = project_setting['description']
    session[:permit_no] = project_setting['permit_no']
    session[:permit_holder] = project_setting['permit_holder']
    session[:contact_address] = project_setting['contact_address']
    session[:participant] = project_setting['participant']
    session[:srid] = project_setting['srid']
    create_tmp_dir
    @spatial_list = Database.get_spatial_ref_list
  end

  def update_project
    @page_crumbs = [:pages_home, :projects_index, :projects_show, :projects_edit]

    if @project.settings_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
      return
    end
    valid = validate_project_update
    if valid
      if @project.update_attributes(:name => params[:project][:name])
        @project.update_settings(params)

        @project.update_project_from(session[:tmpdir])

        FileUtils.remove_entry_secure session[:tmpdir]

        flash[:notice] = 'Successfully updated project'
        redirect_to :project
        return
      else
        session[:name] = params[:project][:name]
        session[:season] = params[:project][:season]
        session[:description] = params[:project][:description]
        session[:permit_no] = params[:project][:permit_no]
        session[:permit_holder] = params[:project][:permit_holder]
        session[:contact_address] = params[:project][:contact_address]
        session[:participant] = params[:project][:participant]
        session[:srid] = params[:project][:srid]
        @spatial_list = Database.get_spatial_ref_list
        flash.now[:error] = 'Error updating project'
        render 'edit_project'
        return
      end
    else
      session[:name] = params[:project][:name]
      session[:season] = params[:project][:season]
      session[:description] = params[:project][:description]
      session[:permit_no] = params[:project][:permit_no]
      session[:permit_holder] = params[:project][:permit_holder]
      session[:contact_address] = params[:project][:contact_address]
      session[:participant] = params[:project][:participant]
      session[:srid] = params[:project][:srid]
      @spatial_list = Database.get_spatial_ref_list
      flash.now[:error] = 'Error updating project'
      render 'edit_project'
      return
    end
  end

  def download_attached_file
    send_file Rails.root.join("projects/#{Project.find(params[:id]).key}/#{params[:path]}"), :filename => params[:name]
  end

  def update

  end

  def archive_project
    @project = Project.find(params[:id])
    if !@project.package_mgr.locked?
      begin
        job = @project.delay.package_project
        session[:job] = job.id
      rescue Exception => e
        raise e
      end
    end
    respond_to do |format|
      format.json { render :json => {:archive => 'false'} } if @project.package_mgr.locked?
      format.json { render :json => {:archive => 'true'} } if !@project.package_mgr.locked?
    end
  end

  def check_archive_status
    @project = Project.find(params[:id])
    jobid = session[:job]
    if !Delayed::Job.exists?(jobid)
      session[:job] = nil
    end
    respond_to do |format|
      format.json { render :json => {:finish => 'false'} } if Delayed::Job.exists?(jobid)
      format.json { render :json => {:finish => 'true'} } if !Delayed::Job.exists?(jobid)
    end
  end

  def download_project
    @project = Project.find(params[:id])
    if @project.package_mgr.locked?
      flash.now[:error] = 'Could not process request as project is currently locked'
      render 'show'
    end

    @project.package_mgr.with_lock do
      send_file @project.get_path(:package_archive), :type => 'application/bzip2', :x_sendfile => true, :stream => false
    end
  end

  def upload_project
    @page_crumbs = [:pages_home, :projects_index, :projects_upload]

    @project = Project.new
  end

  def upload_new_project
    @page_crumbs = [:pages_home, :projects_index, :projects_upload]

    unless SpatialiteDB.library_exists?
      @project = Project.new
      flash.now[:error] = 'Cannot find library libspatialite. Please install library to upload project.'
      render 'upload_project'
      return
    end

    if params[:project]
      project_or_error = Project.upload_project(params)
      if project_or_error.class == String
        @project = Project.new
        flash.now[:error] = project_or_error
        render 'upload_project'
      else
        @project = project_or_error
        flash[:notice] = 'Project has been successfully uploaded'
        redirect_to :projects
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
    session[:validation_schema] = false
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
    end

    # check if data schema is valid
    if !session[:data_schema]
      error = Project.validate_data_schema(params[:project][:data_schema])
      if error
        @project.errors.add(:data_schema, error)
        valid = false
      else
        create_temp_file(@project.get_name(:data_schema), params[:project][:data_schema])
        session[:data_schema] = true
      end
    end

    # check if ui schema is valid
    if !session[:ui_schema]
      error = Project.validate_ui_schema(params[:project][:ui_schema])
      if error
        @project.errors.add(:ui_schema, error)
        valid = false
      else
        create_temp_file(@project.get_name(:ui_schema), params[:project][:ui_schema])
        session[:ui_schema] = true
      end
    end

    # check if ui logic is valid
    if !session[:ui_logic]
      error = Project.validate_ui_logic(params[:project][:ui_logic])
      if error
        @project.errors.add(:ui_logic, error)
        valid = false
      else
        create_temp_file(@project.get_name(:ui_logic), params[:project][:ui_logic])
        session[:ui_logic] = true
      end
    end

    # check if arch16n is valid
    if !session[:arch16n]
      error = Project.validate_arch16n(params[:project][:arch16n],params[:project][:name])
      if error
        @project.errors.add(:arch16n, error)
        valid = false
      else
        if !params[:project][:arch16n].nil?
          create_temp_file(@project.get_name(:properties), params[:project][:arch16n])
          session[:arch16n] = true
        end
      end
    end

    # check if validation schema is valid
    if !session[:validation_schema]
      error = Project.validate_validation_schema(params[:project][:validation_schema])
      if error
        @project.errors.add(:validation_schema, error)
        valid = false
      else
        if !params[:project][:validation_schema].nil?
          create_temp_file(@project.get_name(:validation_schema), params[:project][:validation_schema])
          session[:validation_schema] = true
        end
      end
    end

    if valid
      session[:season] = ''
      session[:description] = ''
      session[:permit_no] = ''
      session[:permit_holder] = ''
      session[:contact_address] = ''
      session[:participant] = ''
      session[:srid] = ''
    else
      session[:season] = params[:project][:season]
      session[:description] = params[:project][:description]
      session[:permit_no] = params[:project][:permit_no]
      session[:permit_holder] = params[:project][:permit_holder]
      session[:contact_address] = params[:project][:contact_address]
      session[:participant] = params[:project][:participant]
      session[:srid] = params[:project][:srid]
    end

    valid
  end

  def validate_project_update
    # check if project is valid

    valid = true

    # check if ui schema is valid
    if !session[:ui_schema]
      if !params[:project][:ui_schema].blank?
        error = Project.validate_ui_schema(params[:project][:ui_schema])
        if error
          @project.errors.add(:ui_schema, error)
          valid = false
        else
          create_temp_file(@project.get_name(:ui_schema), params[:project][:ui_schema])
          session[:ui_schema] = true
        end
      end
    end

    # check if arch16n is valid
    if !session[:ui_logic]
      if !params[:project][:ui_logic].nil?
        create_temp_file(@project.get_name(:ui_logic), params[:project][:ui_logic])
        session[:ui_logic] = true
      end
    end

    # check if arch16n is valid
    if !session[:arch16n]
      error = Project.validate_arch16n(params[:project][:arch16n],params[:project][:name])
      if error
        @project.errors.add(:arch16n, error)
        valid = false
      else
        if !params[:project][:arch16n].nil?
          create_temp_file(@project.get_name(:properties), params[:project][:arch16n])
          session[:arch16n] = true
        end
      end
    end

    # check if validation schema is valid
    if !session[:validation_schema]
      error = Project.validate_validation_schema(params[:project][:validation_schema])
      if error
        @project.errors.add(:validation_schema, error)
        valid = false
      else
        if !params[:project][:validation_schema].nil?
          create_temp_file(@project.get_name(:validation_schema), params[:project][:validation_schema])
          session[:validation_schema] = true
        end
      end
    end

    if valid
      session[:season] = ''
      session[:description] = ''
      session[:permit_no] = ''
      session[:permit_holder] = ''
      session[:contact_address] = ''
      session[:participant] = ''
      session[:srid] = ''
    else
      session[:season] = params[:project][:season]
      session[:description] = params[:project][:description]
      session[:permit_no] = params[:project][:permit_no]
      session[:permit_holder] = params[:project][:permit_holder]
      session[:contact_address] = params[:project][:contact_address]
      session[:participant] = params[:project][:participant]
      session[:srid] = params[:project][:srid]
    end

    valid
  end

  def create_temp_file(filename, upload)
    tmpdir = session[:tmpdir]
    File.open(upload.tempfile, 'r') do |upload_file|
      File.open(tmpdir + '/' + filename, 'w') do |temp_file|
        temp_file.write(upload_file.read)
      end
    end
  end

end

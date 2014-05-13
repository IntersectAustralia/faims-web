require Rails.root.join('app/models/modules/database')

class ProjectModulesController < ApplicationController
  include ProjectModuleBreadCrumbs
  before_filter :crumbs
  before_filter :authenticate_user!
  load_and_authorize_resource

  class MemberException < Exception
  end

  def get_error_message(exception)
    if instance_of? MemberException
      'You are not a member of the module you are editing. Please ask a member to add you to the module before continuing.'
    else instance_of? TimeoutException
    'Could not process request as project is current locked.'
    end
  end

  def authenticate_project_module_user
    @project_module = ProjectModule.find(params[:id])
    redirect_to :project_modules unless @project_module

    user_emails = @project_module.db.get_list_of_users.map { |x| x.last }
    raise MemberException unless user_emails.include? current_user.email
  end

  def index
    page_crumbs :pages_home, :project_modules_index
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
        @project_module.update_settings(params)
        @project_module.create_project_module_from(@tmpdir, current_user)
        @project_module.created = true
        @project_module.save

        flash[:notice] = 'New module created.'
      rescue Exception => e
        # cleanup
        safe_delete_directory @project_module.get_path(:project_module_dir) if File.directory? @project_module.get_path(:project_module_dir)
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

  def edit_project_module_user
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_users

    @project_module = ProjectModule.find(params[:id])

    @users = @project_module.db.get_list_of_users
    user_transpose = @users.transpose
    @server_user = User.all.select { |x| user_transpose.empty? or !user_transpose.last.include? x.email }
  end

  def update_project_module_user
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_users

    @project_module = ProjectModule.find(params[:id])
    
    authenticate_project_module_user

    user = User.find(params[:user_id])
    @project_module.db_mgr.with_shared_lock do
      @project_module.db.update_list_of_users(user, @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Successfully updated user'

      redirect_to :edit_project_module_user
    end
  rescue MemberException, TimeoutException => e
    logger.warn e
    flash.now[:error] = get_error_message(e)

    @users = @project_module.db.get_list_of_users
    user_transpose = @users.transpose
    @server_user = User.all.select { |x| user_transpose.empty? or !user_transpose.last.include? x.email }
    render 'edit_project_module_user'
  end

  # Arch entity functionalities

  def list_arch_ent_records
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_list_arch_ent

    @project_module = ProjectModule.find(params[:id])
    @type = @project_module.db.get_arch_ent_types
    
    session.delete(:values)
    session.delete(:type)
    session.delete(:query)
    session.delete(:action)
    session.delete(:show)
    session.delete(:show_deleted)
    session.delete(:prev_id)
  end

  def list_typed_arch_ent_records
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_list_arch_ent, :project_modules_show_arch_ent

    @project_module = ProjectModule.find(params[:id])

    @limit = Database::LIMIT
    @offset = params[:offset] ? params[:offset] : '0'

    type = params[:type]
    show_deleted = !params[:show_deleted].blank?
    @uuid = @project_module.db.load_arch_entity(type, @limit, @offset, show_deleted)
    @total = @project_module.db.total_arch_entity(type, show_deleted)

    query_params = ''
    query_params << "?type=#{type}&" if type
    query_params << "show_deleted=#{show_deleted}" if show_deleted
    @base_url = list_typed_arch_ent_records_path(@project_module) + query_params

    @entity_dirty_map = {}
    @entity_forked_map = {}
    @uuid.each do |row|
      @entity_dirty_map[row[0]] = @project_module.db.is_arch_entity_dirty(row[0]) unless @entity_dirty_map[row[0]]
      @entity_forked_map[row[0]] = @project_module.db.is_arch_entity_forked(row[0]) unless @entity_forked_map[row[0]]
    end

    session[:type] = type
    session[:show_deleted] = show_deleted ? 'true' : nil
    session[:action] = 'list_typed_arch_ent_records'
  end

  def search_arch_ent_records
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_search_arch_ent

    @project_module = ProjectModule.find(params[:id])
    session.delete(:values)
    session.delete(:type)
    session.delete(:query)
    session.delete(:action)
    session.delete(:show)
    session.delete(:show_deleted)
    session.delete(:prev_id)
  end

  def show_arch_ent_records
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_search_arch_ent, :project_modules_show_arch_ent

    @project_module = ProjectModule.find(params[:id])

    @limit = Database::LIMIT
    @offset = params[:offset] ? params[:offset] : '0'

    query = params[:query]
    show_deleted = !params[:show_deleted].blank?
    @uuid = @project_module.db.search_arch_entity(@limit, @offset, query, show_deleted)
    @total = @project_module.db.total_search_arch_entity(query, show_deleted)

    query_params = ''
    query_params << "?query=#{query}&" if query
    query_params << "show_deleted=#{show_deleted}" if show_deleted
    @base_url = show_arch_ent_records_path(@project_module) + query_params

    @entity_dirty_map = {}
    @entity_forked_map = {}
    @uuid.each do |row|
      @entity_dirty_map[row[0]] = @project_module.db.is_arch_entity_dirty(row[0]) unless @entity_dirty_map[row[0]]
      @entity_forked_map[row[0]] = @project_module.db.is_arch_entity_forked(row[0]) unless @entity_forked_map[row[0]]
    end

    session[:query] = query
    session[:show_deleted] = show_deleted ? 'true' : nil
    session[:action] = 'show_arch_ent_records'
  end

  def edit_arch_ent_records
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_search_or_list_arch_ent, :project_modules_show_arch_ent, :project_modules_edit_arch_ent

    @project_module = ProjectModule.find(params[:id])
    uuid = params[:uuid]

    # TODO whats this for?
    session[:uuid] = uuid
    if !session[:show].nil? and session[:show][-1].eql?('show_rel_associations')
      session[:show].pop()
    end

    @attributes = @project_module.db.get_arch_entity_attributes(uuid)

    @vocab_name = {}
    for attribute in @attributes
      @vocab_name[attribute[1]] = @project_module.db.get_vocab(attribute[1])
    end

    if @project_module.db.is_arch_entity_forked(uuid)
      flash.now[:warning] = "This Archaeological Entity record contains conflicting data. Please click 'Show History' to resolve the conflicts."
    end

    @deleted = @project_module.db.get_arch_entity_deleted_status(uuid)
    @related_arch_ents = @project_module.db.get_related_arch_entities(uuid)

    # TODO what this for?
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
    @project_module = ProjectModule.find(params[:id])
    
    uuid = params[:uuid]
    vocab_id = !params[:attr][:vocab_id].blank? ? params[:attr][:vocab_id] : nil
    attribute_id = !params[:attr][:attribute_id].blank? ? params[:attr][:attribute_id] : nil
    measure = !params[:attr][:measure].blank? ? params[:attr][:measure] : nil
    freetext = !params[:attr][:freetext].blank? ? params[:attr][:freetext] : nil
    certainty = !params[:attr][:certainty].blank? ? params[:attr][:certainty] : nil
    ignore_errors = !params[:attr][:ignore_errors].blank? ? params[:attr][:ignore_errors] : nil

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.update_arch_entity_attribute(uuid, @project_module.db.get_project_module_user_id(current_user.email), vocab_id, attribute_id, measure, freetext, certainty, ignore_errors)

      # TODO add new query to return attributes dirty flag and reason
      @attributes = @project_module.db.get_arch_entity_attributes(uuid)
      errors = @attributes.select { |a| a[1] == attribute_id }.map { |a| a[11] }.first

      render json: { result: 'success', errors: errors }
    end
  rescue MemberException, TimeoutException => e
    logger.warn e

    render json: { result: 'failure', message: get_error_message(e) }
  end

  def delete_arch_ent_records
    @project_module = ProjectModule.find(params[:id])

    uuid = params[:uuid]
    
    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.delete_arch_entity(uuid, @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Deleted Archaeological Entity'

      show_deleted = session[:show_deleted].nil? ? '' : session[:show_deleted]
      if session[:type]
        redirect_to action: :list_typed_arch_ent_records, id: @project_module.id, type: session[:type], show_deleted: show_deleted
      else
        redirect_to action: :show_arch_ent_records, id: @project_module.id, query: session[:query], show_deleted: show_deleted
      end
    end
  rescue MemberException, TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)

    redirect_to action: :edit_arch_ent_records, id: @project_module.id, uuid: uuid
  end

  def restore_arch_ent_records
    @project_module = ProjectModule.find(params[:id])

    uuid = params[:uuid]
    
    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.restore_arch_entity(uuid, @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Restored Archaeological Entity'

      redirect_to action: :edit_arch_ent_records, id: @project_module.id, uuid: uuid
    end
  rescue MemberException, TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)

    redirect_to action: :edit_arch_ent_records, id: @project_module.id, uuid: uuid
  end

  def compare_arch_ents
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_search_or_list_arch_ent, :project_modules_show_arch_ent, :project_modules_compare_arch_ent

    @project_module = ProjectModule.find(params[:id])
    session[:values] = []
    session[:identifiers] = []
    session[:timestamps] = []
    ids = params[:ids]
    @identifiers = params[:identifiers]
    @timestamps = params[:timestamps]
    @first_uuid = ids[0]
    @second_uuid = ids[1]

    unless @project_module.db.is_arch_ent_same_type(@first_uuid, @second_uuid)
      flash[:error] = 'Cannot compare Archaeological Entities of different types'

      redirect_to @project_module
    end
  end

  def merge_arch_ents
    @project_module = ProjectModule.find(params[:id])

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.merge_arch_ents(params[:deleted_id], params[:uuid], params[:vocab_id], params[:attribute_id], params[:measure], params[:freetext], params[:certainty], @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Merged Archaeological Entities'

      show_deleted = session[:show_deleted].nil? ? '' : session[:show_deleted]
      if session[:type]
        url = list_typed_arch_ent_records_path(@project_module, {type: session[:type], show_deleted: show_deleted, flash: flash[:notice]})
      else
        url = show_arch_ent_records_path(@project_module, {query: session[:query], show_deleted: show_deleted, flash: flash[:notice]})
      end

      return render :json => { result: 'success', url: url }
    end
  rescue MemberException, TimeoutException => e
    logger.warn e

    return render :json => { result: 'failure', message: get_error_message(e) }
  end

  def show_arch_ent_history
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_search_or_list_arch_ent, :project_modules_show_arch_ent, :project_modules_edit_arch_ent, :project_modules_show_arch_ent_history

    @project_module = ProjectModule.find(params[:id])
    uuid = params[:uuid]
    @timestamps = @project_module.db.get_arch_ent_history(uuid)
  end

  def revert_arch_ent_to_timestamp
    @project_module = ProjectModule.find(params[:id])

    data = params[:data].map { |x, y| y }

    entity = data.select { |x| x[:attributeid] == nil }.first
    attributes = data.select { |x| x[:attributeid] != nil }

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.revert_arch_ent(entity[:uuid], entity[:timestamp], attributes, params[:resolve] == 'true', @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Reverted Archaeological Entity'
    end
  rescue MemberException, TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)

    redirect_to action: :show_arch_ent_history, id: @project_module.id, uuid: params[:uuid]
  end

  # Relationship functionalities

  def list_rel_records
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_list_rel

    @project_module = ProjectModule.find(params[:id])
    @type = @project_module.db.get_rel_types
    session.delete(:values)
    session.delete(:type)
    session.delete(:query)
    session.delete(:action)
    session.delete(:show)
    session.delete(:show_deleted)
  end

  def list_typed_rel_records
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_list_rel, :project_modules_show_rel

    @project_module = ProjectModule.find(params[:id])

    @limit = Database::LIMIT
    @offset = params[:offset] ? params[:offset] : '0'

    type = params[:type]
    show_deleted = params[:show_deleted].nil? || params[:show_deleted].empty? ? false : true
    @relationshipid = @project_module.db.load_rel(type, @limit, @offset, show_deleted)
    @total = @project_module.db.total_rel(type, show_deleted)

    query_params = ''
    query_params << "?type=#{type}&" if type
    query_params << "show_deleted=#{show_deleted}" if show_deleted
    @base_url = list_typed_rel_records_path(@project_module) + query_params

    @rel_dirty_map = {}
    @rel_forked_map = {}
    @relationshipid.each do |row|
      @rel_dirty_map[row[0]] = @project_module.db.is_relationship_dirty(row[0]) unless @rel_dirty_map[row[0]]
      @rel_forked_map[row[0]] = @project_module.db.is_relationship_forked(row[0]) unless @rel_forked_map[row[0]]
    end

    session[:type] = type
    session[:show_deleted] = show_deleted ? 'true' : nil
    session[:action] = 'list_typed_rel_records'
  end

  def search_rel_records
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_search_rel

    @project_module = ProjectModule.find(params[:id])
    session.delete(:values)
    session.delete(:type)
    session.delete(:query)
    session.delete(:action)
    session.delete(:show)
    session.delete(:show_deleted)
  end

  def show_rel_records
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_search_rel, :project_modules_show_rel

    @project_module = ProjectModule.find(params[:id])

    @limit = Database::LIMIT
    @offset = params[:offset] ? params[:offset] : '0'

    query = params[:query]
    show_deleted = params[:show_deleted].nil? || params[:show_deleted].empty? ? false : true
    @relationshipid = @project_module.db.search_rel(@limit, @offset, query, show_deleted)
    @total = @project_module.db.total_search_rel(query, show_deleted)

    query_params = ''
    query_params << "?query=#{query}&" if query
    query_params << "show_deleted=#{show_deleted}" if show_deleted
    @base_url = show_rel_records_path(@project_module) + query_params

    @rel_dirty_map = {}
    @rel_forked_map = {}
    @relationshipid.each do |row|
      @rel_dirty_map[row[0]] = @project_module.db.is_relationship_dirty(row[0]) unless @rel_dirty_map[row[0]]
      @rel_forked_map[row[0]] = @project_module.db.is_relationship_forked(row[0]) unless @rel_forked_map[row[0]]
    end

    session[:query] = query
    session[:show_deleted] = show_deleted ? 'true' : nil
    session[:action] = 'show_rel_records'
  end

  def edit_rel_records
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_search_or_list_rel, :project_modules_show_rel, :project_modules_edit_rel

    @project_module = ProjectModule.find(params[:id])
    relationshipid = params[:relationshipid]

    session[:relationshipid] = relationshipid

    #TODO whats this for?
    if !session[:show].nil? and session[:show][-1].eql?('show_rel_members')
      session[:show].pop()
      p session[:show]
    end

    @attributes = @project_module.db.get_rel_attributes(relationshipid)
    @vocab_name = {}
    for attribute in @attributes
      @vocab_name[attribute[2]] = @project_module.db.get_vocab(attribute[2])
    end

    if @project_module.db.is_relationship_forked(relationshipid)
      flash.now[:warning] = "This Relationship record contains conflicting data. Please click 'Show History' to resolve the conflicts."
    end

    @deleted = @project_module.db.get_rel_deleted_status(relationshipid)
  end

  def update_rel_records
    @project_module = ProjectModule.find(params[:id])

    relationshipid = params[:relationshipid]
    vocab_id = !params[:attr][:vocab_id].blank? ? params[:attr][:vocab_id] : nil
    attribute_id = !params[:attr][:attribute_id].blank? ? params[:attr][:attribute_id] : nil
    freetext = !params[:attr][:freetext].blank? ? params[:attr][:freetext] : nil
    certainty = !params[:attr][:certainty].blank? ? params[:attr][:certainty] : nil
    ignore_errors = !params[:attr][:ignore_errors].blank? ? params[:attr][:ignore_errors] : nil

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.update_rel_attribute(relationshipid, @project_module.db.get_project_module_user_id(current_user.email), vocab_id, attribute_id, freetext, certainty, ignore_errors)

      # TODO add new query to return attributes dirty flag and reason
      @attributes = @project_module.db.get_rel_attributes(relationshipid)
      errors = @attributes.select { |a| a[2] == attribute_id }.map { |a| a[11] }.first

      render json: { result: 'success', errors: errors }
    end
  rescue MemberException, TimeoutException => e
    logger.warn e

    render json: { result: 'failure', message: get_error_message(e) }
  end

  def show_rel_history
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_search_or_list_rel, :project_modules_show_rel, :project_modules_edit_rel, :project_modules_show_rel_history

    @project_module = ProjectModule.find(params[:id])
    relationshipid = params[:relationshipid]
    @timestamps = @project_module.db.get_rel_history(relationshipid)
  end

  def revert_rel_to_timestamp
    @project_module = ProjectModule.find(params[:id])

    data = params[:data].map { |x, y| y }

    rel = data.select { |x| x[:attributeid] == nil }.first
    attributes = data.select { |x| x[:attributeid] != nil }

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.revert_rel(rel[:relationshipid], rel[:timestamp], attributes, params[:resolve] == 'true', @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Reverted Relationship'
    end
  rescue MemberException, TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)

    redirect_to action: :show_rel_history, id: @project_module.id, relationshipid: params[:relationshipid]
  end

  def delete_rel_records
    @project_module = ProjectModule.find(params[:id])

    relationshipid = params[:relationshipid]

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.delete_relationship(relationshipid, @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Deleted Relationship'

      show_deleted = session[:show_deleted].nil? ? '' : session[:show_deleted]
      if session[:type]
        return redirect_to action: :list_typed_rel_records, id: @project_module.id, type: session[:type], show_deleted: show_deleted
      else
        return redirect_to action: :show_rel_records, id: @project_module.id, query: session[:query], show_deleted: show_deleted
      end
    end
  rescue MemberException, TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)

    redirect_to action: :edit_rel_records, id: @project_module.id, relationshipid: relationshipid
  end

  def restore_rel_records
    @project_module = ProjectModule.find(params[:id])

    relationshipid = params[:relationshipid]

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.restore_relationship(relationshipid, @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Restored Relationship'

      return redirect_to action: :edit_rel_records, id: @project_module.id, relationshipid: relationshipid
    end
  rescue MemberException, TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)

    redirect_to action: :edit_rel_records, id: @project_module.id, relationshipid: relationshipid
  end

  def show_rel_members
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_search_or_list_rel, :project_modules_show_rel, :project_modules_edit_rel, :project_modules_show_rel_associations

    @project_module = ProjectModule.find(params[:id])

    @limit = Database::LIMIT
    @offset = params[:offset] ? params[:offset] : '0'

    relationshipid = params[:relationshipid]
    relntypeid = params[:relntypeid]

    @uuid = @project_module.db.get_rel_arch_ent_members(relationshipid, @limit, @offset)
    @total = @project_module.db.total_rel_arch_ent_members(relationshipid)

    query_params = '?'
    query_params << "relationshipid=#{relationshipid}&" if relationshipid
    query_params << "relntypeid=#{relntypeid}&" if relntypeid
    @base_url = show_rel_members_path(@project_module) + query_params

    # TODO these need to be query params
    session[:relationshipid] = relationshipid
    session[:relntypeid] = relntypeid

    # TODO this seems unneccessary ...
    if session[:show].nil?
      session[:show] = []
      session[:show].push('show_rel_members')
    else
      if !session[:show][-1].eql?('show_rel_members')
        session[:show].push('show_rel_members')
      end
    end
  end

  def remove_arch_ent_member
    @project_module = ProjectModule.find(params[:id])

    relationshipid = params[:relationshipid]
    relntypeid = params[:relntypeid]
    uuid = params[:uuid]

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.delete_member(relationshipid, @project_module.db.get_project_module_user_id(current_user.email), uuid)

      flash[:notice] = 'Removed Archaeological Entity from Relationship'

      return redirect_to action: :show_rel_members, id: @project_module.id, relationshipid: relationshipid, relntypeid: relntypeid
    end
  rescue MemberException, TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)

    return redirect_to action: :show_rel_members, id: @project_module.id, relationshipid: relationshipid, relntypeid: relntypeid
  end

  def search_arch_ent_member
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_search_or_list_rel, :project_modules_show_rel, :project_modules_edit_rel, :project_modules_search_rel_associations

    @project_module = ProjectModule.find(params[:id])

    relationshipid = params[:relationshipid]
    relntypeid = params[:relntypeid]

    # TODO search_query should default to blank and not be in session
    if params[:search_query].nil?
      @uuid = nil
      @status = 'init'
      session.delete(:search_query)
    else
      @limit = Database::LIMIT
      @offset = params[:offset] ? params[:offset] : '0'

      session[:search_query] = params[:search_query]

      @uuid = @project_module.db.get_non_member_arch_ent(relationshipid, params[:search_query], @limit, @offset)
      @total = @project_module.db.total_non_member_arch_ent(relationshipid, params[:search_query])

      query_params = '?'
      query_params << "relationshipid=#{relationshipid}&" if relationshipid
      query_params << "relntypeid=#{relntypeid}&" if relntypeid
      query_params << "search_query=#{params[:search_query]}&" if params[:search_query]
      @base_url = search_arch_ent_member_path(@project_module) + query_params
    end
    @verb = @project_module.db.get_verbs_for_relation(relntypeid)

    # TODO these need to be query params
    session[:relationshipid] = relationshipid
    session[:relntypeid] = relntypeid
  end

  def add_arch_ent_member
    @project_module = ProjectModule.find(params[:id])

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.add_member(params[:relationshipid], @project_module.db.get_project_module_user_id(current_user.email), params[:uuid], params[:verb])

      flash[:notice] = 'Added Archaeological Entity as member of Relationship'

      return redirect_to action: :show_rel_members, id: @project_module.id, relationshipid: params[:relationshipid], relntypeid: params[:relntypeid]
    end
  rescue MemberException, TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)

    return redirect_to action: :show_rel_members, id: @project_module.id, relationshipid: params[:relationshipid], relntypeid: params[:relntypeid]
  end

  def show_rel_association
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_search_or_list_arch_ent, :project_modules_show_arch_ent, :project_modules_edit_arch_ent, :project_modules_show_arch_ent_associations

    @project_module = ProjectModule.find(params[:id])

    @limit = Database::LIMIT
    @offset = params[:offset] ? params[:offset] : '0'

    uuid = params[:uuid]

    @relationships = @project_module.db.get_arch_ent_rel_associations(uuid, @limit, @offset)

    @total = @project_module.db.total_arch_ent_rel_associations(uuid)

    query_params = ''
    query_params << "?uuid=#{uuid}" if uuid
    @base_url = show_rel_association_path(@project_module) + query_params

    # TODO these need to be query params
    session[:uuid] = params[:uuid]

    # TODO this seems unneccessary ...
    if session[:show].nil?
      session[:show] = []
      session[:show].push('show_rel_associations')
    else
      if !session[:show][-1].eql?('show_rel_associations')
        session[:show].push('show_rel_associations')
      end
    end
  end

  def remove_rel_association
    @project_module = ProjectModule.find(params[:id])

    relationshipid = params[:relationshipid]
    uuid = params[:uuid]

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.delete_member(relationshipid, @project_module.db.get_project_module_user_id(current_user.email), uuid)

      flash[:notice] = 'Removed Archaeological Entity from Relationship'

      redirect_to action: :show_rel_association, id: @project_module.id, uuid: uuid
    end
  rescue MemberException, TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)

    redirect_to action: :show_rel_association, id: @project_module.id, uuid: uuid
  end

  def search_rel_association
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_search_or_list_arch_ent, :project_modules_show_arch_ent, :project_modules_edit_arch_ent, :project_modules_show_arch_ent_associations,
      :project_modules_search_arch_ent_associations

    @project_module = ProjectModule.find(params[:id])

    uuid = params[:uuid]

    # TODO search_query should default to blank and not be in session
    if params[:search_query].nil?
      @uuid = nil
      @status = 'init'
      session.delete(:search_query)
    else
      @limit = Database::LIMIT
      @offset = params[:offset] ? params[:offset] : '0'

      session[:search_query] = params[:search_query]

      @relationships = @project_module.db.get_non_arch_ent_rel_associations(uuid, params[:search_query], @limit, @offset)

      @total = @project_module.db.total_non_arch_ent_rel_associations(uuid, params[:search_query])

      query_params = '?'
      query_params << "uuid=#{uuid}&" if uuid
      query_params << "search_query=#{params[:search_query]}&" if params[:search_query]
      @base_url = search_rel_association_path(@project_module) + query_params
    end

    # TODO these need to be query params
    session[:uuid] = params[:uuid]
  end

  # TODO change this so page load all vocabs instead of using ajax call
  def get_verbs_for_rel_association
    verbs = @project_module.db.get_verbs_for_relation(params[:relntypeid])
    respond_to do |format|
      format.json { render :json => verbs.to_json }
    end
  end

  def add_rel_association
    @project_module = ProjectModule.find(params[:id])

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.add_member(params[:relationshipid], @project_module.db.get_project_module_user_id(current_user.email), params[:uuid], params[:verb])

      flash[:notice] = 'Added Archaeological Entity as member of Relationship'

      redirect_to action: :show_rel_association, id: @project_module.id, uuid: params[:uuid]
    end
  rescue MemberException, TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)

    redirect_to action: :show_rel_association, id: @project_module.id, uuid: params[:uuid]
  end

  # TODO compare should use query params
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
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_search_or_list_rel, :project_modules_compare_rel

    @project_module = ProjectModule.find(params[:id])
    ids = params[:ids]
    session[:values] = []
    session[:identifiers] = []
    session[:timestamps] = []
    @identifiers = params[:identifiers]
    @timestamps = params[:timestamps]
    @first_rel_id = ids[0]
    @second_rel_id = ids[1]

    unless @project_module.db.is_rel_same_type(@first_rel_id, @second_rel_id)
      flash[:error] = 'Cannot compare Relationships of different types'
      redirect_to @project_module
    end
  end

  def merge_rel
    @project_module = ProjectModule.find(params[:id])

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.merge_rel(params[:deleted_id], params[:rel_id], params[:vocab_id], params[:attribute_id], params[:freetext], params[:certainty], @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Merged Relationships'

      show_deleted = session[:show_deleted].nil? ? '' : session[:show_deleted]
      if session[:type]
        url = list_typed_rel_records_path(@project_module, {type: session[:type], show_deleted: show_deleted, flash: flash[:notice]})
      else
        url = show_rel_records_path(@project_module, {query: session[:query], show_deleted: show_deleted, flash: flash[:notice]})
      end

      return render :json => { result: 'success', url: url }
    end
  rescue MemberException, TimeoutException => e
    logger.warn e

    render :json => { result: 'failure', message: get_error_message(e) }
  end

  def list_attributes_with_vocab
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_vocabulary

    @project_module = ProjectModule.find(params[:id])

    @attribute_id = params[:attribute_id]

    @attribute_vocabs = {}

    @attributes = @project_module.db.get_attributes_containing_vocab
    @attributes.each do |attribute|
      attribute_id = attribute.first

      vocabs = @project_module.db.get_vocabs_for_attribute(attribute_id)

      @attribute_vocabs[attribute_id] = vocabs.map { |v| {vocab_id:v[1], vocab_name:v[2], vocab_description:v[3].nil? ? '' : v[3], picture_url: v[4].nil? ? '' : v[4], parent_vocab_id: v[5], temp_id: '', temp_parent_id: ''} }
    end
  end

  def update_attributes_vocab
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_vocabulary

    @project_module = ProjectModule.find(params[:id])

    @attribute_id = params[:attribute_id]

    temp_id = params[:temp_id]
    temp_parent_id = params[:temp_parent_id]
    vocab_id = params[:vocab_id]
    parent_vocab_id = params[:parent_vocab_id]
    vocab_name = params[:vocab_name]
    vocab_description = params[:vocab_description]
    picture_url = params[:picture_url]

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      if vocab_name.select { |x| x.blank? }.size > 0
         flash[:error] = 'Please correct the errors in this form. Vocabulary name cannot be empty'
      else
        @project_module.db.update_attributes_vocab(@attribute_id, temp_id, temp_parent_id, vocab_id, parent_vocab_id, vocab_name, vocab_description, picture_url, @project_module.db.get_project_module_user_id(current_user.email))

        flash[:notice] = 'Successfully updated vocabulary'

        return redirect_to list_attributes_with_vocab_path(@project_module, {attribute_id:@attribute_id})
      end
    end
  rescue MemberException, TimeoutException => e
    logger.warn e

    flash.now[:error] = get_error_message(e)

    @attribute_vocabs = {}

    @attributes = @project_module.db.get_attributes_containing_vocab
    @attributes.each do |attribute|
      attribute_id = attribute.first

      if attribute_id.to_s == @attribute_id.to_s
        vocabs = (1..vocab_id.size).to_a.zip(vocab_id, vocab_name, vocab_description, picture_url, parent_vocab_id, temp_id, temp_parent_id)
      else
        vocabs = @project_module.db.get_vocabs_for_attribute(attribute_id)
      end

      @attribute_vocabs[attribute_id] = vocabs.map { |v| {vocab_id:v[1], vocab_name:v[2], vocab_description:v[3].nil? ? '' : v[3], picture_url: v[4].nil? ? '' : v[4], parent_vocab_id: v[5].blank? ? nil : v[5], temp_id: v[6].nil? ? '' : v[6], temp_parent_id: v[7].nil? ? '' : v[7]} }
    end

    render 'list_attributes_with_vocab'
  end

  def edit_project_module
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_edit

    @project_module = ProjectModule.find(params[:id])
    @spatial_list = Database.get_spatial_ref_list

    create_project_module_tmp_dir

    project_module_setting = JSON.parse(safe_file_read(@project_module.get_path(:settings)))
    @name = @project_module.name
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

    @project_module.settings_mgr.with_shared_lock do
      if update_project_module(@tmpdir)
        begin
          @project_module.save
          @project_module.update_settings(params)
          @project_module.update_project_module_from(@tmpdir)
          flash[:notice] = 'Updated module'
        rescue Exception => e
          flash[:error] = 'Failed to update module'
        ensure
          FileUtils.remove_entry_secure @tmpdir
        end

        return redirect_to :project_module
      else
        flash.now[:error] = 'Please correct the errors in this form.'
        return render 'edit_project_module'
      end
    end
  rescue MemberException, TimeoutException => e
    logger.warn e

    flash.now[:error] = 'Could not process request as project is current locked.'

    return render 'edit_project_module'
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

    job = Delayed::Job.find(params[:job])
    render json: { result: job.blank? ? 'success' : (job.last_error ? 'failure' : nil), url: download_project_module_path(@project_module) }
  end

  def download_project_module
    @project_module = ProjectModule.find(params[:id])

    @project_module.with_shared_lock do
      safe_send_file @project_module.get_path(:package_archive), :type => 'application/bzip2', :x_sendfile => true, :stream => false
    end
  rescue MemberException, TimeoutException => e
    logger.warn e

    flash.now[:error] = 'Could not process request as project is current locked.'

    redirect_to project_module_path(@project_module)
  end

  def upload_project_module
    page_crumbs :pages_home, :project_modules_index, :project_modules_upload

    @project_module = ProjectModule.new
  end

  def upload_new_project_module
    page_crumbs :pages_home, :project_modules_index, :project_modules_upload

    unless SpatialiteDB.library_exists?
      @project_module = ProjectModule.new
      flash.now[:error] = 'Cannot find library libspatialite. Please install library to upload module.'
      return render 'upload_project_module'
    end

    if params[:project_module]
      project_module_or_error = ProjectModule.upload_project_module(params)
      if project_module_or_error.class == String
        @project_module = ProjectModule.new
        flash.now[:error] = project_module_or_error
        render 'upload_project_module'
      else
        @project_module = project_module_or_error
        flash[:notice] = 'Module has been successfully uploaded'
        redirect_to :project_modules
      end
    else
      @project_module = ProjectModule.new
      flash.now[:error] = 'Please upload an archive of the module'
      render 'upload_project_module'
    end
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
  end

  def create_project_module(tmpdir)
    if params[:project_module]
      @project_module = ProjectModule.new(:name => params[:project_module][:name], :key => SecureRandom.uuid) if params[:project_module]
      @project_module.valid?
    end

    validate_project_module_files(tmpdir)
    
    @project_module.errors.empty?
  end

  def update_project_module(tmpdir)
    if params[:project_module]
      @project_module.assign_attributes(:name => params[:project_module][:name]) if params[:project_module]
      @project_module.valid?
    end

    validate_project_module_files(tmpdir)

    @project_module.errors.empty?
  end

  def validate_project_module_files(tmpdir)
    # check if data schema is valid
    if !session[:data_schema]
      @project_module.validate_data_schema(params[:project_module][:data_schema])
      if @project_module.errors[:data_schema].empty?
        create_temp_file(@project_module.get_name(:data_schema), params[:project_module][:data_schema], tmpdir)
        session[:data_schema] = true
      end
    end

    # check if ui schema is valid
    if !session[:ui_schema]
      @project_module.validate_ui_schema(params[:project_module][:ui_schema])
      if @project_module.errors[:ui_schema].empty?
        create_temp_file(@project_module.get_name(:ui_schema), params[:project_module][:ui_schema], tmpdir)
        session[:ui_schema] = true
      end
    end

    # check if ui logic is valid
    if !session[:ui_logic]
      @project_module.validate_ui_logic(params[:project_module][:ui_logic])
      if @project_module.errors[:ui_logic].empty?
        create_temp_file(@project_module.get_name(:ui_logic), params[:project_module][:ui_logic], tmpdir)
        session[:ui_logic] = true
      end
    end

    # check if arch16n is valid
    if !session[:arch16n]
      @project_module.validate_arch16n(params[:project_module][:arch16n])
      if @project_module.errors[:arch16n].empty?
        if !params[:project_module][:arch16n].nil?
          create_temp_file(@project_module.get_name(:properties), params[:project_module][:arch16n], tmpdir)
          session[:arch16n] = true
        end
      end
    end

    # check if validation schema is valid
    if !session[:validation_schema]
      @project_module.validate_validation_schema(params[:project_module][:validation_schema])
      if @project_module.errors[:validation_schema].empty?
        if !params[:project_module][:validation_schema].nil?
          create_temp_file(@project_module.get_name(:validation_schema), params[:project_module][:validation_schema], tmpdir)
          session[:validation_schema] = true
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

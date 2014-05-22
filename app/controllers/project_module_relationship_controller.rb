class ProjectModuleRelationshipController < ProjectModuleBaseController

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
  rescue MemberException, FileManager::TimeoutException => e
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

      flash[:notice] = 'Reverted Relationship.'
    end
  rescue MemberException, FileManager::TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)
  ensure
    redirect_to action: :show_rel_history, id: @project_module.id, relationshipid: params[:relationshipid]
  end

  def delete_rel_records
    @project_module = ProjectModule.find(params[:id])

    relationshipid = params[:relationshipid]

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.delete_relationship(relationshipid, @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Deleted Relationship.'

      show_deleted = session[:show_deleted].nil? ? '' : session[:show_deleted]
      if session[:type]
        return redirect_to action: :list_typed_rel_records, id: @project_module.id, type: session[:type], show_deleted: show_deleted
      else
        return redirect_to action: :show_rel_records, id: @project_module.id, query: session[:query], show_deleted: show_deleted
      end
    end
  rescue MemberException, FileManager::TimeoutException => e
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

      flash[:notice] = 'Restored Relationship.'

      return redirect_to action: :edit_rel_records, id: @project_module.id, relationshipid: relationshipid
    end
  rescue MemberException, FileManager::TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)

    redirect_to action: :edit_rel_records, id: @project_module.id, relationshipid: relationshipid
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
      flash[:error] = 'Cannot compare Relationships of different types.'
      redirect_to @project_module
    end
  end

  def merge_rel
    @project_module = ProjectModule.find(params[:id])

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.merge_rel(params[:deleted_id], params[:rel_id], params[:vocab_id], params[:attribute_id], params[:freetext], params[:certainty], @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Merged Relationships.'

      show_deleted = session[:show_deleted].nil? ? '' : session[:show_deleted]
      if session[:type]
        url = list_typed_rel_records_path(@project_module, {type: session[:type], show_deleted: show_deleted, flash: flash[:notice]})
      else
        url = show_rel_records_path(@project_module, {query: session[:query], show_deleted: show_deleted, flash: flash[:notice]})
      end

      return render :json => { result: 'success', url: url }
    end
  rescue MemberException, FileManager::TimeoutException => e
    logger.warn e

    render :json => { result: 'failure', message: get_error_message(e) }
  end


end
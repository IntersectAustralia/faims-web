class ProjectModuleAssociationController < ProjectModuleBaseController

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

      flash[:notice] = 'Removed Archaeological Entity from Relationship.'

      return redirect_to action: :show_rel_members, id: @project_module.id, relationshipid: relationshipid, relntypeid: relntypeid
    end
  rescue MemberException, FileManager::TimeoutException => e
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

      flash[:notice] = 'Added Archaeological Entity as member of Relationship.'

      return redirect_to action: :show_rel_members, id: @project_module.id, relationshipid: params[:relationshipid], relntypeid: params[:relntypeid]
    end
  rescue MemberException, FileManager::TimeoutException => e
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

      flash[:notice] = 'Removed Archaeological Entity from Relationship.'

      redirect_to action: :show_rel_association, id: @project_module.id, uuid: uuid
    end
  rescue MemberException, FileManager::TimeoutException => e
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

  def add_rel_association
    @project_module = ProjectModule.find(params[:id])

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.add_member(params[:relationshipid], @project_module.db.get_project_module_user_id(current_user.email), params[:uuid], params[:verb])

      flash[:notice] = 'Added Archaeological Entity as member of Relationship.'

      redirect_to action: :show_rel_association, id: @project_module.id, uuid: params[:uuid]
    end
  rescue MemberException, FileManager::TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)

    redirect_to action: :show_rel_association, id: @project_module.id, uuid: params[:uuid]
  end

  # TODO change this so page load all vocabs instead of using ajax call
  def get_verbs_for_rel_association
    @project_module = ProjectModule.find(params[:id])
    verbs = @project_module.db.get_verbs_for_relation(params[:relntypeid])
    respond_to do |format|
      format.json { render :json => verbs.to_json }
    end
  end

  # TODO compare should use query params
  def add_record_to_compare
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

  def remove_record_to_compare
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

end
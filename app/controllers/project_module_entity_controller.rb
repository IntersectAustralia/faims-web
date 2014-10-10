class ProjectModuleEntityController < ProjectModuleBaseController
  include ProjectModulesHelper

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

    @limit = params[:per_page].nil? ? 50 : params[:per_page]
    @offset = params[:offset] ? params[:offset] : '0'

    type = params[:type]
    show_deleted = params[:show_deleted].nil? || params[:show_deleted].empty? ? false : true
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

    @limit = params[:per_page].nil? ? 50 : params[:per_page]
    @offset = params[:offset] ? params[:offset] : '0'

    query = params[:query]
    show_deleted = params[:show_deleted].nil? || params[:show_deleted].empty? ? false : true
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
      flash.now[:warning] = "This Entity record contains conflicting data. Please click 'Show History' to resolve the conflicts."
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

  def get_arch_ent_record_data
    project_module = ProjectModule.find(params[:id])
    uuid = params[:uuid]

    attributes = project_module.db.get_arch_entity_attributes(uuid)

    data = []
    attributes.group_by{|a|a[3]}.each do |attribute, values|
      data << {"values" => values.map { |a| 
        {name: a[3],
         vocab: a[2].blank? ? nil : a[2].to_s,
         measure: a[5].blank? ? nil : a[5].to_s,
         freetext: a[6].blank? ? nil : a[6].to_s,
         certainty: a[7].blank? ? nil : a[7].to_s,
         errors: a[11].blank? ? nil : a[11].to_s }
       }}
    end

    render json: { result: data }
  rescue MemberException, FileManager::TimeoutException => e
    logger.warn e

    render json: { result: 'failure', message: get_error_message(e) }
  end

  def batch_update_arch_ent_records
    @project_module = ProjectModule.find(params[:id])

    uuid = params[:uuid]

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do

      @project_module.db.get_arch_entity_attributes(uuid).collect {|a| a[3]}.uniq.each do |att|
        attribute_id = !params[:attr][att][:attribute_id].blank? ? params[:attr][att][:attribute_id] : nil

        vocab_id = !params[:attr][att][:vocab_id].blank? ? params[:attr][att][:vocab_id] : nil
        measure = !params[:attr][att][:measure].blank? ? params[:attr][att][:measure] : nil
        freetext = !params[:attr][att][:freetext].blank? ? params[:attr][att][:freetext] : nil
        certainty = !params[:attr][att][:certainty].blank? ? params[:attr][att][:certainty] : nil
        ignore_errors = !params[:attr][att][:ignore_errors].blank? && params[:attr][att][:ignore_errors] == "1" ? params[:attr][att][:ignore_errors] : nil

        @project_module.db.update_arch_entity_attribute(uuid, @project_module.db.get_project_module_user_id(current_user.email), vocab_id, attribute_id, measure, freetext, certainty, ignore_errors)
      end

      data = []
      attributes = @project_module.db.get_arch_entity_attributes(uuid)
      attributes.group_by{|a|a[3]}.each do |attribute, values|
        data << {"values" => values.map { |a| 
          {name: a[3],
           vocab: a[2].blank? ? nil : a[2].to_s,
           measure: a[5].blank? ? nil : a[5].to_s,
           freetext: a[6].blank? ? nil : a[6].to_s,
           certainty: a[7].blank? ? nil : a[7].to_s,
           errors: a[11].blank? ? nil : a[11].to_s }
         }}
      end

      render json: { result: data }
    end
  rescue MemberException, FileManager::TimeoutException => e
    logger.warn e

    render json: { result: 'failure', message: get_error_message(e) }
  end

  def upload_arch_ent_attribute_file
    @project_module = ProjectModule.find(params[:id])

    uuid = params[:uuid]
    attribute_id = params[:attr_file][:attribute_id]

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      uploaded_files = []
      params[:attr_file][:attribute_file].each do |file|
        filename = process_filename(file.original_filename, @project_module.db.attribute_has_thumbnail(attribute_id))
        if @project_module.db.attribute_is_sync(attribute_id)
          @project_module.add_app_file(filename, file)
          uploaded_files << File.join(@project_module.get_path(:app_files_dir), filename).to_s.gsub(@project_module.get_path(:project_module_dir), '')
        else
          @project_module.add_server_file(filename, file)
          uploaded_files << File.join(@project_module.get_path(:server_files_dir), filename).to_s.gsub(@project_module.get_path(:project_module_dir), '')
        end
      end
      render json: { result: "success", uploaded_files: uploaded_files }
    end
  rescue MemberException, FileManager::TimeoutException, ProjectModule::ProjectModuleException => e
    logger.warn e

    render json: { result: 'failure', message: get_error_message(e) }
  end

  def delete_arch_ent_records
    @project_module = ProjectModule.find(params[:id])

    uuid = params[:uuid]

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.delete_arch_entity(uuid, @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Deleted Entity.'

      show_deleted = session[:show_deleted].nil? ? '' : session[:show_deleted]
      if session[:type]
        redirect_to action: :list_typed_arch_ent_records, id: @project_module.id, type: session[:type], show_deleted: show_deleted
      else
        redirect_to action: :show_arch_ent_records, id: @project_module.id, query: session[:query], show_deleted: show_deleted
      end
    end
  rescue MemberException, FileManager::TimeoutException => e
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

      flash[:notice] = 'Restored Entity.'

      redirect_to action: :edit_arch_ent_records, id: @project_module.id, uuid: uuid
    end
  rescue MemberException, FileManager::TimeoutException => e
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
      flash[:error] = 'Cannot compare Entities of different types.'

      redirect_to @project_module
    end
  end

  def batch_delete_arch_ents
    @project_module = ProjectModule.find(params[:id])

    uuids = params[:selected].split(",")

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.batch_delete_arch_entities(uuids, @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Deleted Entities.'

      session[:values] = []
      session[:identifiers] = []
      session[:timestamps] = []

      show_deleted = session[:show_deleted].nil? ? '' : session[:show_deleted]
      if session[:type]
        redirect_to action: :list_typed_arch_ent_records, id: @project_module.id, type: session[:type], show_deleted: show_deleted
      else
        redirect_to action: :show_arch_ent_records, id: @project_module.id, query: session[:query], show_deleted: show_deleted
      end
    end
  rescue MemberException, FileManager::TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)

    show_deleted = session[:show_deleted].nil? ? '' : session[:show_deleted]
    if session[:type]
      redirect_to action: :list_typed_arch_ent_records, id: @project_module.id, type: session[:type], show_deleted: show_deleted
    else
      redirect_to action: :show_arch_ent_records, id: @project_module.id, query: session[:query], show_deleted: show_deleted
    end
  end

  def batch_restore_arch_ents
    @project_module = ProjectModule.find(params[:id])

    uuids = params[:selected].split(",")

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.batch_restore_arch_entities(uuids, @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Restored Entities.'

      session[:values] = []
      session[:identifiers] = []
      session[:timestamps] = []

      show_deleted = session[:show_deleted].nil? ? '' : session[:show_deleted]
      if session[:type]
        redirect_to action: :list_typed_arch_ent_records, id: @project_module.id, type: session[:type], show_deleted: show_deleted
      else
        redirect_to action: :show_arch_ent_records, id: @project_module.id, query: session[:query], show_deleted: show_deleted
      end
    end
  rescue MemberException, FileManager::TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)

    show_deleted = session[:show_deleted].nil? ? '' : session[:show_deleted]
    if session[:type]
      redirect_to action: :list_typed_arch_ent_records, id: @project_module.id, type: session[:type], show_deleted: show_deleted
    else
      redirect_to action: :show_arch_ent_records, id: @project_module.id, query: session[:query], show_deleted: show_deleted
    end
  end

  def merge_arch_ents
    @project_module = ProjectModule.find(params[:id])

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.merge_arch_ents(params[:deleted_id], params[:uuid], params[:vocab_id], params[:attribute_id], params[:measure], params[:freetext], params[:certainty], @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Merged Entities.'

      show_deleted = session[:show_deleted].nil? ? '' : session[:show_deleted]
      if session[:type]
        url = list_typed_arch_ent_records_path(@project_module, {type: session[:type], show_deleted: show_deleted, flash: flash[:notice]})
      else
        url = show_arch_ent_records_path(@project_module, {query: session[:query], show_deleted: show_deleted, flash: flash[:notice]})
      end

      return render :json => { result: 'success', url: url }
    end
  rescue MemberException, FileManager::TimeoutException => e
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

      flash[:notice] = 'Reverted Entity.'
    end
  rescue MemberException, FileManager::TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)
  ensure
    redirect_to action: :show_arch_ent_history, id: @project_module.id, uuid: params[:uuid]
  end

  def thumbnail
    safe_send_file(params[:url])
  end

end
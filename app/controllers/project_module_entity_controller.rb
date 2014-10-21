class ProjectModuleEntityController < ProjectModuleBaseController
  include ProjectModulesHelper

  def search_arch_ent_records
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_search_arch_ent

    @project_module = ProjectModule.find(params[:id])

    @limit = params[:per_page].blank? ? 50 : params[:per_page]
    @offset = params[:offset].blank? ? 0 : params[:offset]

    type = params[:type]
    user = params[:user]
    query = params[:query]
    show_deleted = params[:show_deleted].blank? ? false : true
    if type and user and query
      @uuid = @project_module.db.search_arch_entity(@limit, @offset, type, user, query, show_deleted)
      @total = @project_module.db.total_search_arch_entity(type, user, query, show_deleted)

      @entity_dirty_map = {}
      @entity_forked_map = {}
      @uuid.each do |row|
        @entity_dirty_map[row[0]] = @project_module.db.is_arch_entity_dirty(row[0]) unless @entity_dirty_map[row[0]]
        @entity_forked_map[row[0]] = @project_module.db.is_arch_entity_forked(row[0]) unless @entity_forked_map[row[0]]
      end
    end

    @types = @project_module.db.get_arch_ent_types
    @users = @project_module.db.get_list_of_users_with_deleted
    @base_url = search_arch_ent_records_path(@project_module, search_params)
  end

  def edit_arch_ent_records
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_search_arch_ent, :project_modules_edit_arch_ent

    @project_module = ProjectModule.find(params[:id])

    uuid = params[:uuid]
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
  rescue Exception => e
    logger.warn e

    render json: { result: 'failure', message: get_error_message(e) }
  end

  def batch_update_arch_ent_records
    @project_module = ProjectModule.find(params[:id])

    uuid = params[:uuid]

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do

      @project_module.db.with_transaction do |db|
        @project_module.db.get_arch_entity_attributes(uuid).collect {|a| a[3]}.uniq.each do |att|
          attribute_id = !params[:attr][att][:attribute_id].blank? ? params[:attr][att][:attribute_id] : nil

          vocab_id = !params[:attr][att][:vocab_id].blank? ? params[:attr][att][:vocab_id] : nil
          measure = !params[:attr][att][:measure].blank? ? params[:attr][att][:measure] : nil
          freetext = !params[:attr][att][:freetext].blank? ? params[:attr][att][:freetext] : nil
          certainty = !params[:attr][att][:certainty].blank? ? params[:attr][att][:certainty] : nil
          ignore_errors = !params[:attr][att][:ignore_errors].blank? && params[:attr][att][:ignore_errors] == "1" ? params[:attr][att][:ignore_errors] : nil

          @project_module.db.update_arch_entity_attribute(db, uuid, @project_module.db.get_project_module_user_id(current_user.email), vocab_id, attribute_id, measure, freetext, certainty, ignore_errors)
        end
      end

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
  rescue Exception => e
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
  rescue Exception => e
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

      redirect_to search_arch_ent_records_path(@project_module, search_params)
    end
  rescue MemberException, FileManager::TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)

    redirect_to edit_arch_ent_records_path(@project_module, uuid, search_params)
  end

  def restore_arch_ent_records
    @project_module = ProjectModule.find(params[:id])

    uuid = params[:uuid]

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.restore_arch_entity(uuid, @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Restored Entity.'

      redirect_to edit_arch_ent_records_path(@project_module, uuid, search_params)
    end
  rescue MemberException, FileManager::TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)

    redirect_to edit_arch_ent_records_path(@project_module, uuid, search_params)
  end

  def compare_arch_ents
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_search_arch_ent, :project_modules_compare_arch_ent

    @project_module = ProjectModule.find(params[:id])

    ids = params[:ids]
    @first_uuid = ids[0]
    @second_uuid = ids[1]

    unless @project_module.db.is_arch_ent_same_type(@first_uuid, @second_uuid)
      flash[:error] = 'Cannot compare Entities of different types.'

      redirect_to search_arch_ent_records_path(@project_module, search_params)
    end
  end

  def merge_arch_ents
    @project_module = ProjectModule.find(params[:id])

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.merge_arch_ents(params[:deleted_id], params[:uuid], params[:vocab_id], params[:attribute_id], params[:measure], params[:freetext], params[:certainty], @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Merged Entities.'

      return render :json => { result: 'success', url: search_arch_ent_records_path(@project_module, search_params.merge(flash: flash[:notice])) }
    end
  rescue Exception => e
    logger.warn e

    return render :json => { result: 'failure', message: get_error_message(e) }
  end

  def batch_delete_arch_ents
    @project_module = ProjectModule.find(params[:id])

    uuids = params[:selected].split(",")

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.batch_delete_arch_entities(uuids, @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Deleted Entities.'

      redirect_to search_arch_ent_records_path(@project_module, search_params)
    end
  rescue MemberException, FileManager::TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)

    redirect_to search_arch_ent_records_path(@project_module, search_params)
  end

  def batch_restore_arch_ents
    @project_module = ProjectModule.find(params[:id])

    uuids = params[:selected].split(",")

    authenticate_project_module_user

    @project_module.db_mgr.with_shared_lock do
      @project_module.db.batch_restore_arch_entities(uuids, @project_module.db.get_project_module_user_id(current_user.email))

      flash[:notice] = 'Restored Entities.'

      redirect_to search_arch_ent_records_path(@project_module, search_params)
    end
  rescue MemberException, FileManager::TimeoutException => e
    logger.warn e

    flash[:error] = get_error_message(e)

    redirect_to search_arch_ent_records_path(@project_module, search_params)
  end

  def show_arch_ent_history
    page_crumbs :pages_home, :project_modules_index, :project_modules_show, :project_modules_search_arch_ent, :project_modules_edit_arch_ent, :project_modules_show_arch_ent_history

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
    redirect_to show_arch_ent_history_path(@project_module, params[:uuid])
  end

  def thumbnail
    safe_send_file(params[:url])
  end

end
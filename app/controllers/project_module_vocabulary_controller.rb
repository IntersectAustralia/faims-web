class ProjectModuleVocabularyController < ProjectModuleBaseController

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
        flash.now[:error] = 'Please correct the errors in this form. Vocabulary name cannot be empty.'
      else
        @project_module.db.update_attributes_vocab(@attribute_id, temp_id, temp_parent_id, vocab_id, parent_vocab_id, vocab_name, vocab_description, picture_url, @project_module.db.get_project_module_user_id(current_user.email))
        flash.now[:notice] = 'Successfully updated vocabulary.'
      end
    end
  rescue MemberException, FileManager::TimeoutException => e
    logger.warn e

    flash.now[:error] = get_error_message(e)
  ensure
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

end
module ProjectModuleBreadCrumbs

  def crumbs
    project_module = ProjectModule.find(params[:id]) if params[:id]
    uuid = params[:uuid]
    relationshipid = params[:relationshipid]

    #TODO fix paths to use url params instead of session params
    type = session[:type]
    query = session[:query]

    list_arch_ent = session[:action].eql?('list_typed_arch_ent_records')
    list_rel = session[:action].eql?('list_typed_rel_records')

    query_params = '?'
    query_params << "type=#{type}&" if type
    query_params << "query=#{query}&" if query

    @crumbs =
        {
            :pages_home => {title: 'Home', url: pages_home_path},
            :project_modules_index => {title: 'Modules', url: project_modules_path},
            :project_modules_create => {title: 'Create', url: new_project_module_path},
            :project_modules_upload => {title: 'Upload', url: upload_project_module_path},
            :project_modules_show => {title: project_module ? project_module.name : nil, url: project_module ? project_module_path(project_module) : nil},
            :project_modules_edit => {title: 'Edit', url: project_module ? edit_project_module_path(project_module) : nil},
            :project_modules_vocabulary => {title: 'Vocabulary', url: project_module ? list_attributes_with_vocab_path(project_module) : nil},
            :project_modules_users => {title: 'Users', url: project_module ? edit_project_module_user_path(project_module) : nil},
            :project_modules_files => {title: 'Files', url: project_module ? project_module_file_list_path(project_module) : nil},
            :project_modules_deleted => {title: 'Deleted', url: nil},
            :project_modules_export => {title: 'Export', url: project_module ? export_project_module_path(project_module) : nil},
            :project_modules_export_results => {title: 'Results', url: nil},

            :project_modules_search_or_list_arch_ent => !list_arch_ent ? {title: 'Search Entity', url: project_module ? search_arch_ent_records_path(project_module) : nil} : {title: 'List Entity', url: project_module ? list_arch_ent_records_path(project_module) : nil},
            :project_modules_search_arch_ent => {title: 'Search Entity', url: project_module ? search_arch_ent_records_path(project_module) : nil},
            :project_modules_list_arch_ent => {title: 'List Entity', url: project_module ? list_arch_ent_records_path(project_module) : nil},
            :project_modules_show_arch_ent => {title: 'Entities', url: project_module ? (query ? show_arch_ent_records_path(project_module) : list_typed_arch_ent_records_path(project_module)) + query_params : nil},
            :project_modules_compare_arch_ent => {title: 'Compare', url: project_module ? compare_arch_ents_path(project_module) : nil},
            :project_modules_edit_arch_ent => {title: project_module ? project_module.db.get_entity_identifier(uuid) : 'Edit', url: (project_module and uuid) ? edit_arch_ent_records_path(project_module, uuid) : nil},
            :project_modules_show_arch_ent_history => {title: 'History', url: (project_module and uuid) ? show_arch_ent_history_path(project_module, uuid) : nil},
            # :project_modules_show_arch_ent_associations => {title: 'Associations', url: (project_module and uuid) ? show_rel_association_path(project_module, uuid) : nil},
            # :project_modules_search_arch_ent_associations => {title: 'Search Association', url: (project_module and uuid) ? search_rel_association_path(project_module, uuid) : nil},

            # :project_modules_search_or_list_rel => !list_rel ? {title: 'Search Relationship', url: project_module ? search_rel_records_path(project_module) : nil} : {title: 'List Relationship', url: project_module ? list_rel_records_path(project_module) : nil},
            # :project_modules_search_rel => {title: 'Search Relationship', url: project_module ? search_rel_records_path(project_module) : nil},
            # :project_modules_list_rel => {title: 'List Relationship', url: project_module ? list_rel_records_path(project_module) : nil},
            # :project_modules_show_rel => {title: 'Relationships', url: project_module ? (query ? show_rel_records_path(project_module) : list_typed_rel_records_path(project_module)) + query_params : nil},
            # :project_modules_compare_rel => {title: 'Compare', url: project_module ? compare_rel_path(project_module) : nil},
            # :project_modules_edit_rel => {title: project_module ? project_module.db.get_rel_identifier(relationshipid) : 'Edit', url: (project_module and relationshipid) ? edit_rel_records_path(project_module, relationshipid) : nil},
            # :project_modules_show_rel_history => {title: 'History', url: (project_module and relationshipid) ? show_rel_history_path(project_module, relationshipid) : nil},
            # :project_modules_show_rel_associations => {title: 'Associations', url: (project_module and relationshipid) ? show_rel_association_path(project_module, relationshipid) : nil},
            # :project_modules_search_rel_associations => {title: 'Search Association', url: (project_module and relationshipid) ? search_arch_ent_member_path(project_module, relationshipid) : nil},

        }
  end

  def page_crumbs(*value)
    @page_crumbs = value
  end

end
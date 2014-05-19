FaimsWeb::Application.routes.draw do
  devise_for :users, controllers: {passwords: 'user_passwords'}
  devise_scope :user do
    get '/users/profile', :to => 'user_registers#profile'
    get '/users/edit', :to => 'user_registers#edit'
    put '/users/update', :to => 'user_registers#update'
    get '/users/edit_password', :to => 'user_registers#edit_password' #allow users to edit their own password
    put '/users/update_password', :to => 'user_registers#update_password' #allow users to edit their own password

    get '/users/password/forgot', :to => 'user_passwords#forgot_password', :as => 'forgot_user_password'
  end

  resources :users, :only => [:show, :new, :create, :destroy] do

    collection do
      get :index
    end

    member do
      get :edit_role
      put :update_role
      get :edit_details
      put :update_details
      get :change_password
      put :save_password
    end
  end

  devise_scope :project_module do
    get 'project_modules/upload_project_module', :to => 'project_modules#upload_project_module', :as => 'upload_project_module'
    post 'project_modules/upload_new_project_module', :to => 'project_modules#upload_new_project_module', :as => 'upload_new_project_module'
  end

  resources :project_modules

  get 'users/password/forgot', :to => 'user_passwords#forgot_password', :as => 'forgot_user_password'

  get 'project_modules/:id/file_list', :to => 'file_manager#file_list', :as => 'project_module_file_list'
  get 'project_modules/:id/download_file', :to => 'file_manager#download_file', :as => 'download_project_module_file'
  post 'project_modules/:id/upload_file', :to => 'file_manager#upload_file', :as => 'upload_project_module_file'
  post 'project_modules/:id/create_dir', :to => 'file_manager#create_dir', :as => 'project_module_create_dir'
  match 'project_modules/:id/delete_file', :to => 'file_manager#delete_file', :as => 'delete_project_module_file'
  post 'project_modules/:id/batch_upload_file', :to => 'file_manager#batch_upload_file', :as => 'batch_upload_file'

  get 'project_modules/:id/edit_project_module', :to => 'project_modules#edit_project_module', :as => 'edit_project_module'
  post 'project_modules/:id/update_project_module', :to => 'project_modules#update_project_module', :as => 'update_project_module'

  get 'project_modules/:id/archive_project_module', :to => 'project_modules#archive_project_module', :as => 'archive_project_module'
  get 'project_modules/:id/download_project_module', :to => 'project_modules#download_project_module', :as => 'download_project_module'
  get 'project_modules/:id/check_archive_status', :to => 'project_modules#check_archive_status', :as => 'check_archive_status'

  get 'project_modules/:id/download_attached_file', :to => 'project_modules#download_attached_file', :as => 'download_attached_file'

  get 'project_modules/:id/search_arch_ent_records/', :to => 'project_modules#search_arch_ent_records', :as => 'search_arch_ent_records'
  get 'project_modules/:id/show_arch_ent_records/', :to => 'project_modules#show_arch_ent_records', :as => 'show_arch_ent_records'
  get 'project_modules/:id/list_arch_ent_records/', :to => 'project_modules#list_arch_ent_records', :as => 'list_arch_ent_records'
  get 'project_modules/:id/list_typed_arch_ent_records/', :to => 'project_modules#list_typed_arch_ent_records', :as => 'list_typed_arch_ent_records'
  get 'project_modules/:id/delete_arch_ent_records/:uuid', :to => 'project_modules#delete_arch_ent_records', :as => 'delete_arch_ent_records'
  get 'project_modules/:id/restore_arch_ent_records/:uuid', :to => 'project_modules#restore_arch_ent_records', :as => 'restore_arch_ent_records'
  get 'project_modules/:id/edit_arch_ent_records/:uuid', :to => 'project_modules#edit_arch_ent_records', :as => 'edit_arch_ent_records'
  post 'project_modules/:id/edit_arch_ent_records/:uuid', :to => 'project_modules#update_arch_ent_records', :as => 'update_arch_ent_records'
  get 'project_modules/:id/show_arch_ent_history/:uuid', :to => 'project_modules#show_arch_ent_history', :as => 'show_arch_ent_history'
  post 'project_modules/:id/revert_arch_ent_to_timestamp/:uuid', :to => 'project_modules#revert_arch_ent_to_timestamp', :as => 'revert_arch_ent_to_timestamp'

  get 'project_modules/:id/search_rel_records/', :to => 'project_modules#search_rel_records', :as => 'search_rel_records'
  get 'project_modules/:id/show_rel_records/', :to => 'project_modules#show_rel_records', :as => 'show_rel_records'
  get 'project_modules/:id/list_rel_records/', :to => 'project_modules#list_rel_records', :as => 'list_rel_records'
  get 'project_modules/:id/list_typed_rel_records/', :to => 'project_modules#list_typed_rel_records', :as => 'list_typed_rel_records'
  get 'project_modules/:id/delete_rel_records/:relationshipid', :to => 'project_modules#delete_rel_records', :as => 'delete_rel_records'
  get 'project_modules/:id/restore_rel_records/:relationshipid', :to => 'project_modules#restore_rel_records', :as => 'restore_rel_records'
  get 'project_modules/:id/edit_rel_records/:relationshipid', :to => 'project_modules#edit_rel_records', :as => 'edit_rel_records'
  post 'project_modules/:id/edit_rel_records/:relationshipid', :to => 'project_modules#update_rel_records', :as => 'update_rel_records'
  get 'project_modules/:id/show_rel_history/:relationshipid', :to => 'project_modules#show_rel_history', :as => 'show_rel_history'
  post 'project_modules/:id/revert_rel_to_timestamp/:relationshipid', :to => 'project_modules#revert_rel_to_timestamp', :as => 'revert_rel_to_timestamp'

  get 'project_modules/:id/show_rel_members/:relationshipid', :to => 'project_modules#show_rel_members', :as => 'show_rel_members'
  post 'project_modules/:id/remove_arch_ent_member/', :to => 'project_modules#remove_arch_ent_member', :as => 'remove_arch_ent_member'
  get 'project_modules/:id/search_arch_ent_member/:relationshipid', :to => 'project_modules#search_arch_ent_member', :as => 'search_arch_ent_member'
  post 'project_modules/:id/add_arch_ent_member/', :to => 'project_modules#add_arch_ent_member', :as => 'add_arch_ent_member'

  get 'project_modules/:id/show_rel_association/:uuid', :to => 'project_modules#show_rel_association', :as => 'show_rel_association'
  post 'project_modules/:id/remove_rel_association/', :to => 'project_modules#remove_rel_association', :as => 'remove_rel_association'
  get 'project_modules/:id/search_rel_association/:uuid', :to => 'project_modules#search_rel_association', :as => 'search_rel_association'
  post 'project_modules/:id/add_rel_association/', :to => 'project_modules#add_rel_association', :as => 'add_rel_association'

  get 'project_modules/:id/get_verbs_for_rel_association', :to => 'project_modules#get_verbs_for_rel_association', :as => 'get_verbs_for_rel_association'

  post 'project_modules/:id/add_entity_to_compare/', :to => 'project_modules#add_entity_to_compare', :as => 'add_entity_to_compare'
  post 'project_modules/:id/remove_entity_to_compare/', :to => 'project_modules#remove_entity_to_compare', :as => 'remove_entity_to_compare'

  post 'project_modules/:id/compare_arch_ents', :to => 'project_modules#compare_arch_ents', :as => 'compare_arch_ents'
  post 'project_modules/:id/merge_arch_ents', :to => 'project_modules#merge_arch_ents', :as => 'merge_arch_ents'

  post 'project_modules/:id/compare_rel', :to => 'project_modules#compare_rel', :as => 'compare_rel'
  post 'project_modules/:id/merge_rel', :to => 'project_modules#merge_rel', :as => 'merge_rel'

  get 'project_modules/:id/list_attributes_with_vocab', :to => 'project_modules#list_attributes_with_vocab', :as => 'list_attributes_with_vocab'
  get 'project_modules/:id/list_vocab_for_attribute/:attribute_id', :to => 'project_modules#list_vocab_for_attribute', :as => 'list_vocab_for_attribute'
  post 'project_modules/:id/update_attributes_vocab', :to => 'project_modules#update_attributes_vocab', :as => 'update_attributes_vocab'

  get 'project_module/:id/edit_project_module_user' , :to => 'project_modules#edit_project_module_user', :as => 'edit_project_module_user'
  post 'project_module/:id/update_project_module_user' , :to => 'project_modules#update_project_module_user', :as => 'update_project_module_user'

  get 'android/modules', :to => 'android#project_modules', :as => 'android_project_modules'

  get 'android/module/:key/settings_info', :to => 'android#settings_info', :as => 'android_settings_info'
  get 'android/module/:key/settings_download', :to => 'android#settings_download', :as => 'android_settings_download'

  get 'android/module/:key/db_info', :to => 'android#db_info', :as => 'android_project_module_db_info'
  get 'android/module/:key/db_download', :to => 'android#db_download', :as => 'android_project_module_db_download'
  post 'android/module/:key/db_upload', :to => 'android#db_upload', :as => 'android_project_module_db_upload'

  get 'android/module/:key/data_files_info', :to => 'android#data_files_info', :as => 'android_data_files_info'
  get 'android/module/:key/data_file_download', :to => 'android#data_file_download', :as => 'android_data_file_download'
  post 'android/module/:key/data_file_upload', :to => 'android#data_file_upload', :as => 'android_data_file_upload'

  get 'android/module/:key/server_files_info', :to => 'android#server_files_info', :as => 'android_server_files_info'
  post 'android/module/:key/server_file_upload', :to => 'android#server_file_upload', :as => 'android_server_file_upload'

  get 'android/module/:key/app_files_info', :to => 'android#app_files_info', :as => 'android_app_files_info'
  get 'android/module/:key/app_file_download', :to => 'android#app_file_download', :as => 'android_app_file_download'
  post 'android/module/:key/app_file_upload', :to => 'android#app_file_upload', :as => 'android_app_file_upload'

  root :to => 'pages#home'

  get 'pages/home'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with 'root'
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with 'rake routes'

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

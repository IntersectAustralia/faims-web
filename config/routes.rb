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
    end
  end

  devise_scope :project do
    get 'projects/upload_project', :to => 'projects#upload_project', :as => 'upload_project'
    post 'projects/upload_new_project', :to => 'projects#upload_new_project', :as => 'upload_new_project'
  end

  resources :projects

  get 'users/password/forgot', :to => 'user_passwords#forgot_password', :as => 'forgot_user_password'

  get 'projects/:id/file_list', :to => 'file_manager#file_list', :as => 'project_file_list'
  get 'projects/:id/download_file', :to => 'file_manager#download_file', :as => 'download_project_file'
  post 'projects/:id/upload_file', :to => 'file_manager#upload_file', :as => 'upload_project_file'
  post 'projects/:id/create_dir', :to => 'file_manager#create_dir', :as => 'project_create_dir'
  match 'projects/:id/delete_file', :to => 'file_manager#delete_file', :as => 'delete_project_file'

  get 'projects/:id/edit_project', :to => 'projects#edit_project', :as => 'edit_project'
  post 'projects/:id/update_project', :to => 'projects#update_project', :as => 'update_project'

  get 'projects/:id/archive_project', :to => 'projects#archive_project', :as => 'archive_project'
  get 'projects/:id/download_project', :to => 'projects#download_project', :as => 'download_project'
  get 'projects/:id/check_archive_status', :to => 'projects#check_archive_status', :as => 'check_archive_status'

  get 'projects/:id/download_attached_file', :to => 'projects#download_attached_file', :as => 'download_attached_file'

  get 'projects/:id/search_arch_ent_records/', :to => 'projects#search_arch_ent_records', :as => 'search_arch_ent_records'
  get 'projects/:id/show_arch_ent_records/', :to => 'projects#show_arch_ent_records', :as => 'show_arch_ent_records'
  get 'projects/:id/list_arch_ent_records/', :to => 'projects#list_arch_ent_records', :as => 'list_arch_ent_records'
  get 'projects/:id/list_typed_arch_ent_records/', :to => 'projects#list_typed_arch_ent_records', :as => 'list_typed_arch_ent_records'
  get 'projects/:id/delete_arch_ent_records/:uuid', :to => 'projects#delete_arch_ent_records', :as => 'delete_arch_ent_records'
  get 'projects/:id/edit_arch_ent_records/:uuid', :to => 'projects#edit_arch_ent_records', :as => 'edit_arch_ent_records'
  post 'projects/:id/edit_arch_ent_records/:uuid', :to => 'projects#update_arch_ent_records', :as => 'update_arch_ent_records'
  get 'projects/:id/show_arch_ent_history/:uuid', :to => 'projects#show_arch_ent_history', :as => 'show_arch_ent_history'
  post 'projects/:id/revert_arch_ent_to_timestamp/:uuid', :to => 'projects#revert_arch_ent_to_timestamp', :as => 'revert_arch_ent_to_timestamp'

  get 'projects/:id/search_rel_records/', :to => 'projects#search_rel_records', :as => 'search_rel_records'
  get 'projects/:id/show_rel_records/', :to => 'projects#show_rel_records', :as => 'show_rel_records'
  get 'projects/:id/list_rel_records/', :to => 'projects#list_rel_records', :as => 'list_rel_records'
  get 'projects/:id/list_typed_rel_records/', :to => 'projects#list_typed_rel_records', :as => 'list_typed_rel_records'
  get 'projects/:id/delete_rel_records/:relationshipid', :to => 'projects#delete_rel_records', :as => 'delete_rel_records'
  get 'projects/:id/edit_rel_records/:relationshipid', :to => 'projects#edit_rel_records', :as => 'edit_rel_records'
  post 'projects/:id/edit_rel_records/:relationshipid', :to => 'projects#update_rel_records', :as => 'update_rel_records'
  get 'projects/:id/show_rel_history/:relid', :to => 'projects#show_rel_history', :as => 'show_rel_history'
  post 'projects/:id/revert_rel_to_timestamp/:relid', :to => 'projects#revert_rel_to_timestamp', :as => 'revert_rel_to_timestamp'

  get 'projects/:id/show_rel_members/:relationshipid', :to => 'projects#show_rel_members', :as => 'show_rel_members'
  post 'projects/:id/remove_arch_ent_member/', :to => 'projects#remove_arch_ent_member', :as => 'remove_arch_ent_member'
  get 'projects/:id/search_arch_ent_member/:relationshipid', :to => 'projects#search_arch_ent_member', :as => 'search_arch_ent_member'
  post 'projects/:id/add_arch_ent_member/', :to => 'projects#add_arch_ent_member', :as => 'add_arch_ent_member'

  get 'projects/:id/show_rel_association/:uuid', :to => 'projects#show_rel_association', :as => 'show_rel_association'
  get 'projects/:id/search_rel_association/:uuid', :to => 'projects#search_rel_association', :as => 'search_rel_association'
  get 'projects/:id/get_verbs_for_rel_association', :to => 'projects#get_verbs_for_rel_association', :as => 'get_verbs_for_rel_association'
  post 'projects/:id/add_rel_association/', :to => 'projects#add_rel_association', :as => 'add_rel_association'


  post 'projects/:id/add_entity_to_compare/', :to => 'projects#add_entity_to_compare', :as => 'add_entity_to_compare'
  post 'projects/:id/remove_entity_to_compare/', :to => 'projects#remove_entity_to_compare', :as => 'remove_entity_to_compare'

  post 'projects/:id/compare_arch_ents', :to => 'projects#compare_arch_ents', :as => 'compare_arch_ents'
  post 'projects/:id/merge_arch_ents', :to => 'projects#merge_arch_ents', :as => 'merge_arch_ents'

  post 'projects/:id/compare_rel', :to => 'projects#compare_rel', :as => 'compare_rel'
  post 'projects/:id/merge_rel', :to => 'projects#merge_rel', :as => 'merge_rel'

  get 'projects/:id/list_attributes_with_vocab', :to => 'projects#list_attributes_with_vocab', :as => 'list_attributes_with_vocab'
  get 'projects/:id/list_vocab_for_attribute/:attribute_id', :to => 'projects#list_vocab_for_attribute', :as => 'list_vocab_for_attribute'
  post 'projects/:id/update_attributes_vocab', :to => 'projects#update_attributes_vocab', :as => 'update_attributes_vocab'

  get 'project/:id/edit_project_user' , :to => 'projects#edit_project_user', :as => 'edit_project_user'
  post 'project/:id/update_project_user' , :to => 'projects#update_project_user', :as => 'update_project_user'

  get 'android/projects', :to => 'android#projects', :as => 'android_projects'

  get 'android/project/:key/settings_archive', :to => 'android#settings_archive', :as => 'android_settings_archive'
  get 'android/project/:key/settings_download', :to => 'android#settings_download', :as => 'android_settings_download'

  get 'android/project/:key/db_archive', :to => 'android#db_archive', :as => 'android_project_db_archive'
  get 'android/project/:key/db_download', :to => 'android#db_download', :as => 'android_project_db_download'
  post 'android/project/:key/db_upload', :to => 'android#db_upload', :as => 'android_project_db_upload'

  get 'android/project/:key/data_file_list', :to => 'android#data_file_list', :as => 'android_data_file_list'
  get 'android/project/:key/data_file_archive', :to => 'android#data_file_archive', :as => 'android_data_file_archive'
  get 'android/project/:key/data_file_download', :to => 'android#data_file_download', :as => 'android_data_file_download'
  post 'android/project/:key/data_file_upload', :to => 'android#data_file_upload', :as => 'android_data_file_upload'

  get 'android/project/:key/server_file_list', :to => 'android#server_file_list', :as => 'android_server_file_list'
  get 'android/project/:key/server_file_archive', :to => 'android#server_file_archive', :as => 'android_server_file_archive'
  get 'android/project/:key/server_file_download', :to => 'android#server_file_download', :as => 'android_server_file_download'
  post 'android/project/:key/server_file_upload', :to => 'android#server_file_upload', :as => 'android_server_file_upload'

  get 'android/project/:key/app_file_list', :to => 'android#app_file_list', :as => 'android_app_file_list'
  get 'android/project/:key/app_file_archive', :to => 'android#app_file_archive', :as => 'android_app_file_archive'
  get 'android/project/:key/app_file_download', :to => 'android#app_file_download', :as => 'android_app_file_download'
  post 'android/project/:key/app_file_upload', :to => 'android#app_file_upload', :as => 'android_app_file_upload'

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

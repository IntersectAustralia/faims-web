FaimsWeb::Application.routes.draw do
  devise_for :users, controllers: {passwords: "user_passwords"}
  devise_scope :user do
    get "/users/profile", :to => "user_registers#profile"
    get "/users/edit", :to => "user_registers#edit"
    put "/users/update", :to => "user_registers#update"
    get "/users/edit_password", :to => "user_registers#edit_password" #allow users to edit their own password
    put "/users/update_password", :to => "user_registers#update_password" #allow users to edit their own password
  end

  resources :users, :only => [:show] do

    collection do
      get :index
    end

    member do
      get :edit_role
      put :update_role
    end
  end

  resources :projects

  get "projects/:id/edit_project_setting", :to => "projects#edit_project_setting", :as => "edit_project_setting"
  post "projects/:id/edit_project_setting", :to => "projects#update_project_setting", :as => "update_project_setting"

  get "projects/:id/list_arch_ent_records/", :to => "projects#list_arch_ent_records", :as => "list_arch_ent_records"
  get "projects/:id/list_typed_arch_ent_records/", :to => "projects#list_typed_arch_ent_records", :as => "list_typed_arch_ent_records"
  get "projects/:id/delete_arch_ent_records/:uuid", :to => "projects#delete_arch_ent_records", :as => "delete_arch_ent_records"
  get "projects/:id/edit_arch_ent_records/:uuid", :to => "projects#edit_arch_ent_records", :as => "edit_arch_ent_records"
  post "projects/:id/edit_arch_ent_records/:uuid", :to => "projects#update_arch_ent_records", :as => "update_arch_ent_records"

  get "projects/:id/list_rel_records/", :to => "projects#list_rel_records", :as => "list_rel_records"
  get "projects/:id/list_typed_rel_records/", :to => "projects#list_typed_rel_records", :as => "list_typed_rel_records"
  get "projects/:id/delete_rel_records/:relationshipid", :to => "projects#delete_rel_records", :as => "delete_rel_records"
  get "projects/:id/edit_rel_records/:relationshipid", :to => "projects#edit_rel_records", :as => "edit_rel_records"
  post "projects/:id/edit_rel_records/:relationshipid", :to => "projects#update_rel_records", :as => "update_rel_records"

  post "projects/:id/compare_arch_ents", :to => "projects#compare_arch_ents", :as => "compare_arch_ents"
  post "projects/:id/select_arch_ents", :to => "projects#select_arch_ents", :as => "select_arch_ents"

  get "android/projects", :to => "android#projects", :as => "android_projects"
  
  get "android/project/:key/archive", :to => "android#archive", :as => "android_project_archive"
  get "android/project/:key/download", :to => "android#download", :as => "android_project_download"
  
  get "android/project/:key/archive_db", :to => "android#archive_db", :as => "android_project_archive_db"
  get "android/project/:key/download_db", :to => "android#download_db", :as => "android_project_download_db"

  post "android/project/:key/upload_db", :to => "android#upload_db", :as => "android_project_upload_db"

  get "android/project/:key/server_file_list", :to => "android#server_file_list", :as => "server_file_list"
  get "android/project/:key/app_file_list", :to => "android#app_file_list", :as => "app_file_list"

  get "android/project/:key/server_file_archive", :to => "android#server_file_archive", :as => "server_file_archive"
  get "android/project/:key/app_file_archive", :to => "android#app_file_archive", :as => "app_file_archive"

  get "android/project/:key/server_file_download", :to => "android#server_file_download", :as => "server_file_download"
  get "android/project/:key/app_file_download", :to => "android#app_file_download", :as => "app_file_download"

  root :to => "pages#home"

  get "pages/home"

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

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

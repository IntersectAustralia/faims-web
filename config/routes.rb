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

  get "android/projects", :to => "android#projects", :as => "android_projects"
  get "android/project/:id/archive", :to => "android#archive", :as => "android_project_archive"
  get "android/project/:id/download", :to => "android#download", :as => "android_project_download"

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

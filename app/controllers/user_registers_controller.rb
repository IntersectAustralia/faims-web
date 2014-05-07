class UserRegistersController < Devise::RegistrationsController
  # based on https://github.com/plataformatec/devise/blob/v2.0.4/app/controllers/devise/registrations_controller.rb
  include UserBreadCrumbs
  before_filter :crumbs
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy, :edit_password, :update_password, :profile]

  def profile

  end

  def edit
    page_crumbs :pages_home, :users_index, :users_current_show, :users_edit_details
    super
  end

  # Override the create method in the RegistrationsController to add the notification hook
  def create
    build_resource

    if resource.save
      Notifier.notify_superusers_of_access_request(resource).deliver
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  # Override the update method in the RegistrationsController so that we don't require password on update
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    if resource.update_attributes(params[resource_name])
      if is_navigational_format?
        if resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation?
          flash_key = :update_needs_confirmation
        end
        set_flash_message :notice, flash_key || :updated
      end
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def edit_password
    page_crumbs :pages_home, :users_index, :users_current_show, :users_edit_password

    respond_with resource
  end

  # Mostly the same as the devise 'update' method, just call a different method on the model
  def update_password
    page_crumbs :pages_home, :users_index, :users_current_show, :users_edit_password

    if resource.update_password(params[resource_name])
      set_flash_message :notice, :password_updated if is_navigational_format?
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords(resource)
      render :edit_password
    end
  end

end

def create_roles_and_permissions
  Permission.delete_all
  Role.delete_all

  #TODO: create your roles here
  superuser = "superuser"
  Role.create!(:name => superuser)

  #TODO: set your own permissions here
  create_permission("User", "read", [superuser])
  create_permission("User", "update_role", [superuser])
  create_permission("User", "activate_deactivate", [superuser])
  create_permission("User", "admin", [superuser])
  create_permission("User", "reject", [superuser])
  create_permission("User", "approve", [superuser])

  #TODO: create more permissions here
end

def create_permission(entity, action, roles)
  permission = Permission.new(:entity => entity, :action => action)
  permission.save!
  roles.each do |role_name|
    role = Role.where(:name => role_name).first
    role.permissions << permission
    role.save!
  end
end


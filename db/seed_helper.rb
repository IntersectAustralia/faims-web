def create_roles_and_permissions
  Role.delete_all
  User.delete_all

  superuser = "superuser"
  Role.create!(:name => superuser)

  create_user(first_name: "Faims",
              last_name: "Admin",
              email: "faimsadmin@intersect.org.au",
              password: "Pass.123",
              password: "Pass.123")
  set_role("faimsadmin@intersect.org.au", "superuser")

end

def set_role(email, role)
  user = User.where(:email => email).first
  role = Role.where(:name => role).first
  user.role = role
  user.save!
end

def create_user(attrs)
  u = User.new(attrs)
  u.activate
  u.save!
end
def make_user(firstname, lastname, email, password)
  user = User.new(:first_name => firstname, :last_name => lastname, :email => email, :password => password)

  if user.valid?
    user.activate
    user.role = Role.find_by_name('user')
    user.save
    user
  else
    return nil
  end
end
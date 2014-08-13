require 'highline/import'

begin
  namespace :users do

    desc 'Create user'
    task :create => :environment do
      create_user
    end

    desc 'Delete user'
    task :delete => :environment do
      delete_user
    end

  end
rescue LoadError
  puts 'It looks like some Gems are missing: please run bundle install'
end

def create_user
  firstname = ask("First name of user: ")
  lastname = ask("Last name of user: ")
  email = ask("Email of user: ")
  password = ask("Password: ") { |q| q.echo = false }
  password2 = ask("Confirm Password: ") { |q| q.echo = false }

  if password != password2
    raise Exception, "Passwords don't match"
    return
  end

  user = User.new(:first_name => firstname, :last_name => lastname, :email => email, :password => password)

  if user.valid?
    user.activate
    user.role = Role.find_by_name('user')
    user.save
  else
    raise Exception, "Error creating user. Check the entered email is valid and that the password is between 6-20 characters " +
    "and contains at least one uppercase letter, one lowercase letter, one digit and one symbol"
  end
end

def delete_user
  user_email = ENV['email'] unless ENV['email'].nil?
  if user_email.nil? || user_email.blank?
    raise Exception, "Usage: rake users:delete email=<user email>"
    return
  end

  user = User.find_by_email(user_email)

  if user
    user.destroy
  else
    raise Exception, "User does not exist"
  end
end
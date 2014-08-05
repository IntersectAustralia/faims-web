begin
  namespace :users do

    desc 'Create user'
    task :create => :environment do
      puts "First name of user:"
      firstname = $stdin.gets.chomp
      puts "Last name of user:"
      lastname = $stdin.gets.chomp
      puts "Email of user:"
      email = $stdin.gets.chomp
      puts "Password:"
      password = $stdin.noecho(&:gets).chomp
      puts "Confirm password:"
      password2 = $stdin.noecho(&:gets).chomp

      if password != password2
        puts "Passwords don't match"
        next
      end

      user = User.new(:first_name => firstname, :last_name => lastname, :email => email, :password => password)

      if user.valid?
        user.activate
        user.role = Role.find_by_name('user')
        user.save
      else
        puts "Error creating user. Check the entered email is valid and that the password is between 6-20 characters " + 
        "and contains at least one uppercase letter, one lowercase letter, one digit and one symbol"
      end

    end

    desc 'Delete user'
    task :delete => :environment do
      user_email = ENV['email'] unless ENV['email'].nil?

      if user_email.nil? || user_email.blank?
        puts "Usage: rake users:delete email=<user email>"
        next
      end

      user = User.find_by_email(user_email)

      if user
        user.destroy
      else
        puts "User does not exist"
      end
    end

  end
rescue LoadError
  puts 'It looks like some Gems are missing: please run bundle install'
end
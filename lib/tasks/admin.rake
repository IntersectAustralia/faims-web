require File.dirname(__FILE__) + '/admin.rb'
begin
  namespace :admin do
    desc "Enter new admin password"
    task :password => :environment do
      set_admin_password
    end
  end
rescue LoadError
  puts "It looks like some Gems are missing: please run bundle install"
end
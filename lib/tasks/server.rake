require File.dirname(__FILE__) + '/server.rb'
begin
  namespace :server do

    desc 'Initialise server with a uuid'
    task :setup do
      setup_server
    end

    desc 'Check for server updates'
    task :check_for_updates do
      check_for_server_updates
    end

    desc 'Update server'
    task :update do
      update_server
    end

  end
rescue LoadError
  puts 'It looks like some Gems are missing: please run bundle install'
end
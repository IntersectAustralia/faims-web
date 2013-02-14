require File.dirname(__FILE__) + '/setup_server.rb'
begin
  namespace :server do
    desc "Initialise server with a uuid"
    task :setup do
      if File.exists? Rails.application.config.server_properties_file
        puts "Properties file already exists. Do you want to create a new one?"
        input = STDIN.gets.chomp
        if input.downcase != "yes" && input.downcase != "y"
          puts "Cancelled server setup"
          exit(0)
        end
      end
      create_server_properties(Rails.application.config.server_properties_file)
      puts "Created #{Rails.root}/projects/server.properties"
    end
  end
rescue LoadError
  puts "It looks like some Gems are missing: please run bundle install"
end
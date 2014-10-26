require Rails.root.join('lib/server_updater')

def setup_server
  if File.exists? Rails.application.config.server_properties_file
    puts 'Properties file already exists. Do you want to create a new one?'
    input = STDIN.gets.chomp
    if input.downcase != 'yes' && input.downcase != 'y'
      puts 'Cancelled server setup'
      exit(0)
    end
  end
  create_server_properties(Rails.application.config.server_properties_file)
  puts "Created #{Rails.root}/modules/server.properties"
end

def check_for_server_updates
  ServerUpdater.check_server_updates
end

def update_server
  ServerUpdater.update_server
  ServerUpdater.restart_server
end

def create_server_properties(filename)
  File.open(filename, 'w') do |file|
    file.write("server_key=#{SecureRandom.uuid}")
  end
end
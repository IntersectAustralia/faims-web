def create_server_properties(filename)
  File.open(filename, 'w') do |file|
    file.write("server_key=#{SecureRandom.uuid}")
  end
end
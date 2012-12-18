def local_ip
  orig, Socket.do_not_reverse_lookup = 
    Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily
  UDPSocket.open do |s|
    s.connect '64.233.187.99', 1
    s.addr.last
  end
ensure
    Socket.do_not_reverse_lookup = orig
end


SERVER_PORT = Rails.application.config.server_port
DISCOVERY_PORT = Rails.application.config.discovery_server_port

puts "Server Started on port #{DISCOVERY_PORT}"
socket = UDPSocket.new
socket.bind('0.0.0.0', DISCOVERY_PORT)
loop do

  begin
    data, addr = socket.recvfrom(1024) # max 1 kb

    object = JSON.parse(data)
    ip = object['android_ip']
    port = object['android_port']
    puts "Received broadcast from #{ip}:#{port}"

    s = UDPSocket.new
    s.send({server_ip:local_ip, server_port:SERVER_PORT}.to_json, 0, ip, port)
    s.close
    puts "Sent Server@#{local_ip}:#{SERVER_PORT} to #{ip}:#{port}"
  rescue Execption => e
    puts e
  end
end

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

puts "Server Started on port #{SERVER_PORT}"
socket = UDPSocket.new
socket.bind('0.0.0.0', DISCOVERY_PORT)
loop do

  data, addr = socket.recvfrom(1024) # max 1 kb

  object = JSON.parse(data)
  ip = object['ip']
  port = object['port']
  puts "Received broadcast from #{ip}:#{port}"

  s = UDPSocket.new
  s.send({ip:local_ip, port:SERVER_PORT}.to_json, 0, ip, port)
  s.close
  puts "Sent message to #{ip}:#{port}"

end

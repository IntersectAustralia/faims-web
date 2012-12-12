SERVER_IP = IPSocket.getaddress(Socket.gethostname)
SERVER_PORT = Rails.application.config.server_port
DISCOVERY_PORT = Rails.application.config.discovery_server_port

puts "Server Started on #{SERVER_IP}:#{SERVER_PORT}"
socket = UDPSocket.new
socket.bind('0.0.0.0', DISCOVERY_PORT)
loop do

  data, addr = socket.recvfrom(1024) # max 1 kb

  object = JSON.parse(data)
  ip = object['ip']
  port = object['port']
  puts "Received broadcast from #{ip}:#{port}"

  s = UDPSocket.new
  s.send({ip:SERVER_IP, port:SERVER_PORT}.to_json, 0, ip, port)
  s.close
  puts "Sent message to #{ip}:#{port}"

end

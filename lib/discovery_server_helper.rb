SERVER_PORT = Rails.application.config.server_port
DISCOVERY_PORT = Rails.application.config.discovery_server_port

class DiscoveryServer

  def self.reverse_lookup
    begin
      orig, Socket.do_not_reverse_lookup =
          Socket.do_not_reverse_lookup, true # turn off reverse DNS resolution temporarily
      UDPSocket.open do |s|
        s.connect '64.233.187.99', 1
        s.addr.last
      end
    ensure
      Socket.do_not_reverse_lookup = orig
    end
  end

  def self.line_splitter
    return /\n\t/ if (/darwin/ =~ RUBY_PLATFORM) != nil
    return /\n/
  end

  def self.get_subnet(ip)
    /^(?<subnet>\d{1,3}.\d{1,3}.\d{1,3})/.match(ip)[:subnet]
  end

  def self.find_matching_local_ip(ip)
    begin
      # read each line of config and return ip address by looking for inet
      ips = `/sbin/ifconfig`.split(line_splitter).select { |l| l if l =~ /inet\s/ }.map { |l| /(?<ip>\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3})/.match(l)[:ip] }

      # return ip which matches in same subnet
      found_ip = ips.select { |local_ip| local_ip if get_subnet(local_ip) == get_subnet(ip) }
      return found_ip.first if found_ip.length > 0
    rescue Exception => e
      puts e
    end
    # fallback using reverse lookup
    reverse_lookup
  end

  def self.init
    puts "Server Started on port #{DISCOVERY_PORT}"
    @socket = UDPSocket.new
    @socket.bind('0.0.0.0', DISCOVERY_PORT)
  end

  def self.do_discovery
    data, addr = @socket.recvfrom(1024) # max 1 kb

    object = JSON.parse(data)
    ip = object['android_ip']
    port = object['android_port']
    puts "Received broadcast from #{ip}:#{port}"

    server_ip = DiscoveryServer.find_matching_local_ip(ip)

    s = UDPSocket.new
    s.send({server_ip: server_ip, server_port: SERVER_PORT}.to_json, 0, ip, port)
    s.close
    puts "Sent Server@#{server_ip}:#{SERVER_PORT} to #{ip}:#{port}"
  end
end

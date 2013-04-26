require 'discovery_server_helper'

DiscoveryServer.init

loop do

  begin

    DiscoveryServer.do_discovery

  rescue SystemExit, Interrupt
    puts 'Discovery server killed'
    exit(0)
  rescue Exception => e
    puts 'Error sending discovery packet'
    puts e
  end

end

begin
  namespace :discover do
    desc "Start discovery server"
    task :start => :environment do
      discover_server "start", "-f"
    end

    desc "Get status of discovery server"
    task :status => :environment do
      discover_server "status"
    end

    desc "Stop discover server"
    task :stop => :environment do
      discover_server "stop"
    end
  end
rescue LoadError
  puts "It looks like some Gems are missing: please run bundle install"
end

def discover_server(*args)

  options = {
      :app_name   => "discovery_server",
      :dir_mode   => :normal,
      :dir        => Rails.root.join('tmp').to_s,
      :multiple   => false,
      :ontop      => false,
      :mode       => :load,
      :backtrace  => true,
      :monitor    => true
  }

  options[:ARGV] = args

  Daemons.run(Rails.root.join('lib', 'discovery_server.rb'), options)
end


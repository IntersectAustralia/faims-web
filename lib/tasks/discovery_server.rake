begin
  namespace :discovery do
    desc "Start discovery server"
    task :start, [:background] => :environment do |t, args|
      discover_server options(:ontop => args[:background].nil?, :ARGV => ["start", "-f"])
    end

    desc "Get status of discovery server"
    task :status => :environment do
      discover_server options(:ARGV => ["status"])
    end

    desc "Stop discover server"
    task :stop => :environment do
      discover_server options(:ARGV => ["stop"])
    end
  end
rescue LoadError
  puts "It looks like some Gems are missing: please run bundle install"
end

def discover_server(opts)
  Daemons.run(Rails.root.join('lib', 'discovery_server.rb'), opts)
end

def options(extra)
  {
      :app_name => "discovery_server",
      :dir_mode => :normal,
      :dir => Rails.root.join('tmp').to_s,
      :multiple => false,
      :ontop => true,
      :mode => :load,
      :backtrace => true,
      :monitor => true
  }.merge(extra)
end

begin
  namespace :discovery do
    desc 'Start discovery server'
    task :start, [:background] do |t, args|
      discover_server discover_options(:ontop => args[:background].nil?, :ARGV => ['start', '-f'])
    end

    desc 'Get status of discovery server'
    task :status do
      discover_server discover_options(:ARGV => ['status'])
    end

    desc 'Stop discover server'
    task :stop do
      discover_server discover_options(:ARGV => ['stop'])
    end
  end
rescue LoadError
  puts 'It looks like some Gems are missing: please run bundle install'
end

def discover_server(opts)
  # make sure pids dir exists
  FileUtils.mkdir_p (Rails.root.join('tmp/pids').to_s) unless File.directory? Rails.root.join('tmp/pids').to_s

  Daemons.run(Rails.root.join('lib', 'discovery_server.rb'), opts)
end

def discover_options(extra)
  {
      :app_name => 'discovery_server',
      :dir_mode => :normal,
      :dir => Rails.root.join('tmp/pids').to_s,
      :multiple => false,
      :ontop => true,
      :mode => :load,
      :backtrace => true,
      :monitor => true
  }.merge(extra)
end

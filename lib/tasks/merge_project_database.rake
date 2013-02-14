begin
  namespace :merge_daemon do
    desc "Start daemon to merge project databases"
    task :start, [:background] => :environment do |t, args|
      merge_daemon merge_options(:ontop => args[:background].nil?, :ARGV => ["start", "-f"])
    end

    desc "Get status of daemon"
    task :status do
      merge_daemon merge_options(:ARGV => ["status"])
    end

    desc "Stop daemon"
    task :stop do
      merge_daemon merge_options(:ARGV => ["stop"])
    end
  end
rescue LoadError
  puts "It looks like some Gems are missing: please run bundle install"
end

def merge_daemon(opts)
  Daemons.run(Rails.root.join('lib', 'merge_daemon.rb'), opts)
end

def merge_options(extra)
  {
      :app_name => "merge_daemon",
      :dir_mode => :normal,
      :dir => Rails.root.join('tmp/pids').to_s,
      :multiple => false,
      :ontop => true,
      :mode => :load,
      :backtrace => true,
      :monitor => true
  }.merge(extra)
end

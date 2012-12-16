require File.dirname(__FILE__) + '/test_project_creator.rb'

begin
  namespace :test_helper do
    desc "Test helper"
      task :create_projects, [:size] => :environment do |t, args|
        size = args[:size] || 50
        create_projects(size.to_i)
    end
  end
rescue LoadError
  puts "It looks like some Gems are missing: please run bundle install"
end

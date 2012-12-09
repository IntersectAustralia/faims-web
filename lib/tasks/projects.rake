require File.dirname(__FILE__) + '/sample_data_populator.rb'
begin
  namespace :projects do
    desc "Cleanup all projects"
    task :clean => :environment do
      clean_projects
    end
  end
rescue LoadError
  puts "It looks like some Gems are missing: please run bundle install"
end

def clean_projects
  Project.destroy_all
  FileUtils.rm_rf Rails.root.join(projects_dir) if File.directory? projects_dir
end

def projects_dir
  Rails.env == 'test' ? 'tmp/projects' : 'projects'
end
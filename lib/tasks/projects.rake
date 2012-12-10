require File.dirname(__FILE__) + '/sample_data_populator.rb'
begin
  namespace :projects do
    desc "Cleanup all projects"
    task :clean => :environment do
      clean_projects
    end

    desc "Create projects directory"
    task :create => :environment do
      Dir.mkdir(Rails.root.join(projects_dir)) unless File.directory? Rails.root.join(projects_dir)
    end

    namespace :test do
      desc "Prepare test projects directory"
      task :prepare => :environment do
        Dir.mkdir(Rails.root.join('tmp')) unless File.directory? Rails.root.join('tmp')
        Dir.mkdir(Rails.root.join(projects_dir)) unless File.directory? Rails.root.join(projects_dir)
      end
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
require Rails.root.join('lib/tasks/test_project_creator')
require Rails.root.join('app/models/projects/database')

begin
  namespace :projects do
    desc 'Cleanup all projects'
    task :clean => :environment do
      clean_projects
    end
    desc 'Archive all projects'
    task :archive, [:key] => :environment do |t, args|
      if args[:key]
        Project.find_by_key(args[:key]).generate_archives
      else
        Project.all.each { |p| p.generate_archives }
      end
    end
    desc 'Package all projects'
    task :package, [:key] => :environment do |t, args|
      if args[:key]
        Project.package_project(args[:key])
      else
        Project.all.each { |p| Project.package_project(p.key) }
      end
    end
    desc 'Clear locks from all projects'
    task :clear_lock => :environment do
      if ActiveRecord::Base.connection.table_exists? 'projects'
        Project.all.each do |p|
          p.db_mgr.clear_lock
          p.settings_mgr.clear_lock
          p.data_mgr.clear_lock
          p.app_mgr.clear_lock
          p.package_mgr.clear_lock
        end
      end
    end
    desc 'Setup project assets'
    task :setup => :environment do
      Database.generate_spatial_ref_list
      Database.generate_template_db
    end
    namespace :test do
      desc 'Generate test projects'
      task :create, [:size] => :environment do |t, args|
        size = args[:size] || 50
        create_projects(size.to_i)
      end
    end
  end
rescue LoadError
  puts 'It looks like some Gems are missing: please run bundle install'
end

def clean_projects
  Project.destroy_all

  projects_dir = Rails.application.config.server_projects_directory
  FileUtils.rm_rf Rails.root.join(projects_dir) if File.directory? projects_dir
  Dir.mkdir(Rails.root.join(projects_dir))

  uploads_dir = Rails.application.config.server_uploads_directory
  FileUtils.rm_rf Rails.root.join(uploads_dir) if File.directory? uploads_dir
  Dir.mkdir(Rails.root.join(uploads_dir))
end

require Rails.root.join('lib/tasks/test_project_creator')
require Rails.root.join('app/models/modules/database')

begin
  namespace :modules do
    desc 'Cleanup all project modules'
    task :clean => :environment do
      clean_project_modules
    end
    desc 'Archive all project modules'
    task :archive, [:key] => :environment do |t, args|
      if args[:key]
        ProjectModule.find_by_key(args[:key]).generate_archives
      else
        ProjectModule.all.each { |p| p.generate_archives }
      end
    end
    desc 'Package all project modules'
    task :package, [:key] => :environment do |t, args|
      if args[:key]
        ProjectModule.package_project_module(args[:key])
      else
        ProjectModule.all.each { |p| ProjectModule.package_project_module(p.key) }
      end
    end
    desc 'Clear locks from all project modules'
    task :clear_lock => :environment do
    	require 'find'
		  Find.find(Rails.root.join('modules').to_s) { |path| FileUtils.remove_entry_secure Rails.root.join(path) if path =~ /\.lock.*/ } if Dir.exists? Rails.root.join('modules')
	  end
    desc 'Setup project module assets'
    task :setup => :environment do
      Database.generate_spatial_ref_list
      Database.generate_template_db
    end
    namespace :test do
      desc 'Generate test project modules'
      task :create, [:size] => :environment do |t, args|
        size = args[:size] || 50
        create_project_modules(size.to_i)
      end
    end
  end
rescue LoadError
  puts 'It looks like some Gems are missing: please run bundle install'
end

def clean_project_modules
  ProjectModule.destroy_all

  project_modules_dir = Rails.application.config.server_project_modules_directory
  FileUtils.remove_entry_secure Rails.root.join(project_modules_dir) if File.directory? project_modules_dir
  Dir.mkdir(Rails.root.join(project_modules_dir))

  uploads_dir = Rails.application.config.server_uploads_directory
  FileUtils.remove_entry_secure Rails.root.join(uploads_dir) if File.directory? uploads_dir
  Dir.mkdir(Rails.root.join(uploads_dir))
end

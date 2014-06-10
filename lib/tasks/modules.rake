require Rails.root.join('lib/tasks/test_project_creator')
require Rails.root.join('app/models/modules/database')

begin
  namespace :modules do
    desc 'Clear all project modules'
    task :clear => :environment do
      clear_project_modules
    end
    desc 'Archive all project modules'
    task :archive, [:key] => :environment do |t, args|
      if args[:key]
        ProjectModule.find_by_key(args[:key]).archive_project_module
      else
        ProjectModule.all.each { |p| p.archive_project_module }
      end
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

def clear_project_modules
  ProjectModule.unscoped.destroy_all

  project_modules_dir = Rails.application.config.server_project_modules_directory
  FileUtils.remove_entry_secure Rails.root.join(project_modules_dir) if File.directory? project_modules_dir
  Dir.mkdir(Rails.root.join(project_modules_dir))

  uploads_dir = Rails.application.config.server_uploads_directory
  FileUtils.remove_entry_secure Rails.root.join(uploads_dir) if File.directory? uploads_dir
  Dir.mkdir(Rails.root.join(uploads_dir))
end

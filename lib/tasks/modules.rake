require Rails.root.join('lib/tasks/test_project_creator')
require Rails.root.join('app/models/modules/database')

begin
  namespace :modules do

    desc 'Clear all project modules'
    task :clear => :environment do
      clear_project_modules
    end

    desc 'Archive a specific or all project modules'
    task :archive => :environment do
      module_key = ENV['key'] unless ENV['key'].nil?
      begin
        if module_key
          project_module = ProjectModule.find_by_key(module_key)
          if project_module
            project_module.archive_project_module
          else
            puts "Module does not exist"
          end
        else
          ProjectModule.all.each { |p| p.archive_project_module }
        end
      rescue ProjectModule::ProjectModuleException => e
        puts e
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

    desc 'Create module from tarball'
    task :create => :environment do
      module_tarball = ENV['module'] unless ENV['module'].nil?

      if (module_tarball.nil?) || (!File.exists?(module_tarball))
        puts "Usage: rake modules:create module=<module tarball>"
        next
      end

      begin
        ProjectModule.upload_project_module(module_tarball)
      rescue ProjectModule::ProjectModuleException => e
        puts e
      end
    end

    desc 'Delete module'
    task :delete => :environment do
      module_key = ENV['key'] unless ENV['key'].nil?

      if (module_key.nil?) || (module_key.blank?)
        puts "Usage: rake modules:delete key=<module key>"
        next
      end

      project_module = ProjectModule.find_by_key(module_key)
      if project_module
        project_module.destroy
      else
        puts "Module does not exist"
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

require Rails.root.join('lib/tasks/test_project_creator')
require Rails.root.join('app/models/modules/database')
require Rails.root.join('lib/tasks/modules')

begin
  namespace :modules do

    desc 'Clear all project modules'
    task :clear => :environment do
      clear_project_modules
    end

    desc 'Archive a specific or all project modules'
    task :archive => :environment do
      archive
    end

    desc 'Setup project module assets'
    task :setup => :environment do
      Database.generate_spatial_ref_list
      Database.generate_template_db
    end

    desc 'Create module from tarball'
    task :create => :environment do
      create_module
    end

    desc 'Delete module'
    task :delete => :environment do
      delete_module
    end

    desc 'Restore module'
    task :restore => :environment do
      restore_module
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
require Rails.root.join('/lib/tasks/test_project_creator')

begin
  namespace :projects do
    desc "Cleanup all projects"
    task :clean => :environment do
      clean_projects
    end
    desc "Archive all projects"
    task :archive, [:key] => :environment do |t, args|
      if args[:key]
        Project.find_by_key(args[:key]).update_archives
      else
        Project.all.each { |p| p.update_archives }
      end
    end
    desc "Package all projects"
    task :package, [:key] => :environment do |t, args|
      if args[:key]
        Project.package_project_for(args[:key])
      else
        Project.all.each { |p| Project.package_project_for(p.key) }
      end
    end
    namespace :test do
      desc "Generate test projects"
      task :create, [:size] => :environment do |t, args|
        size = args[:size] || 50
        create_projects(size.to_i)
      end
    end
  end
rescue LoadError
  puts "It looks like some Gems are missing: please run bundle install"
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

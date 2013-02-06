begin
  namespace :projects do
    desc "Cleanup all projects"
    task :clean => :environment do
      clean_projects
    end
    desc "Archive all projects"
    task :archive => :environment do
      Project.all.each { |p| p.archive }
    end
  end
rescue LoadError
  puts "It looks like some Gems are missing: please run bundle install"
end

def clean_projects
  Project.destroy_all
  FileUtils.rm_rf Rails.root.join(projects_dir) if File.directory? projects_dir
  Dir.mkdir(Rails.root.join(projects_dir)) unless File.directory? Rails.root.join(projects_dir)
end

def projects_dir
  'projects'
end

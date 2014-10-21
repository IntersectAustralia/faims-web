def clear_project_modules
  ProjectModule.unscoped.destroy_all

  project_modules_dir = ProjectModule.project_modules_path
  FileUtils.remove_entry_secure Rails.root.join(project_modules_dir) if File.directory? project_modules_dir
  Dir.mkdir(Rails.root.join(project_modules_dir))

  uploads_dir = ProjectModule.uploads_path
  FileUtils.remove_entry_secure Rails.root.join(uploads_dir) if File.directory? uploads_dir
  Dir.mkdir(Rails.root.join(uploads_dir))

  upload_failures_dir = ProjectModule.upload_failures_path
  FileUtils.remove_entry_secure Rails.root.join(upload_failures_dir) if File.directory? upload_failures_dir
  Dir.mkdir(Rails.root.join(upload_failures_dir))
end

def create_module
  module_tarball = ENV['module'] unless ENV['module'].nil?
  if (module_tarball.nil?) || (!File.exists?(module_tarball))
    puts "Usage: rake modules:create module=<module tarball>"
    return
  end

  begin
    ProjectModule.upload_project_module(module_tarball)
  rescue ProjectModule::ProjectModuleException => e
    puts e
  end
end

def archive
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

def delete_module
  module_key = ENV['key'] unless ENV['key'].nil?
  if (module_key.nil?) || (module_key.blank?)
    puts "Usage: rake modules:delete key=<module key>"
    return
  end

  project_module = ProjectModule.find_by_key(module_key)
  if project_module
    project_module.with_exclusive_lock do
      project_module.deleted = true
      project_module.save
    end
  else
    puts "Module does not exist"
  end
end

def restore_module
  module_key = ENV['key'] unless ENV['key'].nil?
  if (module_key.nil?) || (module_key.blank?)
    puts "Usage: rake modules:restore key=<module key>"
    return
  end

  project_module = ProjectModule.unscoped.find_by_key(module_key)
  if project_module
    project_module.with_exclusive_lock do
      project_module.deleted = false
      project_module.save
    end
  else
    puts "Module does not exist"
  end
end
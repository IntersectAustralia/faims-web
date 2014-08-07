begin
  namespace :exporters do

    desc 'Clear all exporters'
    task :clear => :environment do
      clear_exporters
    end

    desc 'Install exporter'
    task :install => :environment do
      install_exporter
    end

    desc 'Uninstall exporter'
    task :uninstall => :environment do
      uninstall_exporter
    end

  end
rescue LoadError
  puts 'It looks like some Gems are missing: please run bundle install'
end

def clear_exporters
  exporters_dir = ProjectExporter.exporters_dir
  FileUtils.remove_entry_secure Rails.root.join(exporters_dir) if File.directory? exporters_dir
  Dir.mkdir(Rails.root.join(exporters_dir))
end

def install_exporter
  exporter_tarball = ENV['exporter'] unless ENV['exporter'].nil?
  if (exporter_tarball.nil?) || (!File.exists?(exporter_tarball))
    puts "Usage: rake exporters:install exporter=<exporter_tarball>"
    return
  end

  begin
    if !install_exporter_from_tarball(exporter_tarball)
      puts "Exporter failed to install. Please correct the errors in the install script."
    end
  rescue ProjectExporter::ProjectExporterException => e
    puts e
  end
end

def install_exporter_from_tarball(exporter_tarball)
  dir = ProjectExporter.extract_exporter(exporter_tarball)
  @project_exporter = ProjectExporter.new(dir)
  if @project_exporter.valid?
    @project_exporter.install
  end
end

def uninstall_exporter
  exporter_key = ENV['key'] unless ENV['key'].nil?
  if exporter_key.nil? || exporter_key.blank?
    puts "Usage: rake exporters:uninstall key=<exporter_key>"
    return
  end

  exporter = ProjectExporter.find_by_key(exporter_key)

  if exporter
    exporter.uninstall
  else
    puts "Exporter does not exist"
  end
end
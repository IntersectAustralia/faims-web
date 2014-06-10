def make_exporter_tarball(name, config = nil, options = nil)
  tmp_dir = Dir.mktmpdir

  config ||= {
      name: name,
      version: 0
  }

  unless options and options[:skip_config]
    File.open(File.join(tmp_dir, ProjectExporter::CONFIG_FILE), 'w+') do |file|
      file.write(config.to_json)
    end
  end

  install_script = (options and options[:install_script]) ? options[:install_script] : ProjectExporter::INSTALL_SCRIPT
  uninstall_script = (options and options[:uninstall_script]) ? options[:uninstall_script] : ProjectExporter::UNINSTALL_SCRIPT
  export_script = (options and options[:export_script]) ? options[:export_script] : ProjectExporter::EXPORT_SCRIPT

  FileUtils.cp Rails.root.join("features/assets/exporter_template/#{install_script}"),
               File.join(tmp_dir, ProjectExporter::INSTALL_SCRIPT) unless options and options[:skip_installer]
  FileUtils.cp Rails.root.join("features/assets/exporter_template/#{uninstall_script}"),
               File.join(tmp_dir, ProjectExporter::UNINSTALL_SCRIPT) unless options and options[:skip_uninstaller]
  FileUtils.cp Rails.root.join("features/assets/exporter_template/#{export_script}"),
               File.join(tmp_dir, ProjectExporter::EXPORT_SCRIPT) unless options and options[:skip_exporter]

  tarball = Tempfile.new(['exporter', '.tar.gz'])
  TarHelper.tar('zcf', tarball.path, File.basename(tmp_dir), File.dirname(tmp_dir))
  tarball.path
ensure
  FileUtils.rm_rf tmp_dir if Dir.exists? tmp_dir
end
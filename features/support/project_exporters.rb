def init_exporters
  exporters_dir = Rails.root.join('tmp/exporters')
  FileUtils.rm_rf exporters_dir if Dir.exists? exporters_dir
end

def make_exporter_tarball(name, config = nil, options = nil)
  exporters_dir = Rails.root.join('tmp/exporters')
  FileUtils.mkdir exporters_dir unless Dir.exists? exporters_dir

  tmp_dir = File.join(exporters_dir, SecureRandom.uuid)
  FileUtils.mkdir tmp_dir

  config ||= {
      name: name,
      version: 0,
      key: SecureRandom.uuid
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

  tarball = File.join(exporters_dir, SecureRandom.uuid)
  TarHelper.tar('zcf', tarball, File.basename(tmp_dir), File.dirname(tmp_dir))
  tarball
ensure
  FileUtils.rm_rf tmp_dir if Dir.exists? tmp_dir
end
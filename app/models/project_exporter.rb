class ProjectExporter
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  class ProjectExporterException < Exception
  end

  CONFIG_FILE = 'config.json'
  INSTALL_SCRIPT = 'install.sh'
  UNINSTALL_SCRIPT = 'uninstall.sh'
  EXPORT_SCRIPT = 'export.sh'

  # validations
  validates :dir, presence: true
  validate :validate_config
  validate :validate_install_script
  validate :validate_uninstall_script
  validate :validate_export_script

  def validate_config
    return errors.add(:config, 'Cannot find config') unless File.exists? get_path(:config)

    config_json = get_config_json

    errors.add(:config, 'Config is missing exporter key') if config_json['key'].blank?
    errors.add(:config, 'Config is missing exporter name') if config_json['name'].blank?
    errors.add(:config, 'Config is missing exporter version') if config_json['version'].blank?
  end

  def validate_install_script
    return errors.add(:install_script, 'Cannot find install script') unless File.exists? get_path(:install_script)
  end

  def validate_uninstall_script
    return errors.add(:uninstall_script, 'Cannot find uninstall script') unless File.exists? get_path(:uninstall_script)
  end

  def validate_export_script
    return errors.add(:export_script, 'Cannot find export script') unless File.exists? get_path(:export_script)
  end

  def initialize(dir = nil)
    @dir = dir
  end

  def dir
    @dir
  end

  def key
    config_json = get_config_json
    return config_json['key'] if config_json
  end

  def name
    config_json = get_config_json
    return config_json['name'] if config_json
  end

  def version
    config_json = get_config_json
    return config_json['version'] if config_json
  end

  def get_config_json
    JSON.parse(get_raw_config)
  rescue JSON::ParserError
    raise ProjectExporterException, 'Cannot parse config as json'
  end

  def get_raw_config
    File.open(get_path(:config), 'r').read
  end

  def get_path(type)
    return File.join(@dir, CONFIG_FILE) if type == :config
    return File.join(@dir, INSTALL_SCRIPT) if type == :install_script
    return File.join(@dir, UNINSTALL_SCRIPT) if type == :uninstall_script
    return File.join(@dir, EXPORT_SCRIPT) if type == :export_script
  end

  def install
    # check if install script exists
    raise ProjectExporterException, "Exporter doesn't contain install.sh script" unless File.exists? get_path(:install_script)

    # check if exporter already exists then version is greater
    exporter = ProjectExporter.find_by_key(key)
    raise ProjectExporterException, "Exporter '#{exporter.name}' already exists with version '#{exporter.version}'" if exporter and version <= exporter.version

    # delete old exporter
    exporter.uninstall if exporter

    # move the exporter into the exporters_dir
    Dir.mkdir ProjectExporter.exporters_dir unless Dir.exists? ProjectExporter.exporters_dir
    FileUtils.mv dir, ProjectExporter.exporters_dir
    @dir = File.join(ProjectExporter.exporters_dir, File.basename(dir))

    # run the install script
    result = execute_script(File.basename(get_path(:install_script)))
    FileUtils.rm_rf @dir unless result

    result
  end

  def uninstall
    # check if uninstall script exists
    raise ProjectExporterException, "Exporter doesn't contain uninstall.sh script" unless File.exists? get_path(:uninstall_script)

    # run the uninstall script
    result = execute_script(File.basename(get_path(:uninstall_script)))

    # delete the exporter from the exporters_dir
    FileUtils.rm_rf dir if result and Dir.exists? dir

    result
  end

  def export(module_tarball, input_json, download_dir, markup_file)
    # check if export script exists
    raise ProjectExporterException, "Exporter doesn't contain export.sh script" unless File.exists? get_path(:export_script)

    params = [module_tarball, input_json, download_dir, markup_file].join(" ")

    # run the export script
    execute_script(File.basename(get_path(:export_script)), params)
  end

  def parse_interface_inputs(input)
    attributes = {}
    config = get_config_json
    if config and input
      if config['interface']
        config['interface'].each do |field|
          if field['type'] == 'checkbox'
            values = []
            if field['items']
              field['items'].each do |item|
                checked = input["#{field['label']}:#{item}"]
                values << item if checked
              end
            end
            attributes[field['label']] = values
          else
            attributes[field['label']] = input[field['label']]
          end
        end
      end
    end
    attributes
  end

  class << self

    def all
      return [] unless exporters_dir and Dir.exists? exporters_dir

      dirs = Dir["#{exporters_dir}/*"]
      exporters = dirs.select do |dir|
        exporter = ProjectExporter.new(dir)
        exporter.valid?
      end.map { |dir| ProjectExporter.new(dir) }

      exporters
    end

    def find_by_name(name)
      all.select{ |exporter| exporter.name == name }.first
    end

    def find_by_key(key)
      all.select{ |exporter| exporter.key == key }.first
    end

    def extract_exporter(exporter_tarball)
      # extract tarball
      tmp_dir = Dir.mktmpdir
      export_dir = Dir.mktmpdir
      raise ProjectExporterException, 'Cannot extract archive' unless TarHelper.untar('xzf', exporter_tarball, tmp_dir)

      # validate tarball
      base_dir = Dir["#{tmp_dir}/*"].first
      raise ProjectExporterException, 'Cannot find directory in archive' unless base_dir and Dir.exists? base_dir

      # move contents to export directory
      FileUtils.cp_r Dir["#{base_dir}/*"], export_dir

      export_dir
    ensure
      FileUtils.rm_rf tmp_dir if tmp_dir and Dir.exists? tmp_dir
    end

    def exporters_dir
      Rails.env == 'test' ? Rails.root.join('tmp/exporters') : Rails.application.config.exporters_dir
    end

    def exporter_log
      Rails.root.join('log/exporters.log').to_s
    end

  end

  private

  def execute_script(script, params = nil)
    system("cd #{dir} && bash #{script} #{params.to_s} >> #{ProjectExporter.exporter_log} 2>&1")
  end

end
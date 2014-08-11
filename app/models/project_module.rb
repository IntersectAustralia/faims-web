require Rails.root.join('app/models/modules/database')

class ProjectModule < ActiveRecord::Base
  include XSDValidator
  include MD5Checksum
  include SecurityHelper

  class ProjectModuleException < Exception
  end

  DEFAULT_SRID = 4326

  # SCOPES

  default_scope order: 'name COLLATE NOCASE'
  default_scope where(deleted: false)

  scope :created, where(created: true, deleted: false)
  scope :deleted, where(deleted: true)

  attr_accessor :data_schema,
                :ui_schema,
                :ui_logic,
                :arch16n,
                :validation_schema,
                :css_style,
                :srid,
                :season,
                :description,
                :permit_no,
                :permit_holder,
                :permit_issued_by,
                :permit_type,
                :contact_address,
                :participant,
                :copyright_holder,
                :client_sponsor,
                :land_owner,
                :has_sensitive_data,
                :tmpdir

  attr_accessible :name,
                  :key,
                  :created,
                  :data_schema,
                  :ui_schema,
                  :ui_logic,
                  :arch16n,
                  :validation_schema,
                  :css_style,
                  :srid,
                  :season,
                  :description,
                  :permit_no,
                  :permit_holder,
                  :permit_issued_by,
                  :permit_type,
                  :contact_address,
                  :participant,
                  :copyright_holder,
                  :client_sponsor,
                  :land_owner,
                  :has_sensitive_data,
                  :tmpdir

  validates :name, :presence => true, :length => {:maximum => 255},
            :format => {:with => /\A(\s*[^\/\\\?\%\*\:\|\"\'\<\>\.]+\s*)*\z/i} # do not allow file name reserved characters

  validates :key, :presence => true, :uniqueness => true

  # Custom Validations

  def validate_validation_schema(schema)
    return if schema.blank?
    validate_schema('validation_schema', schema)

    begin
      DatabaseValidator.new(nil, schema.tempfile)
    rescue Exception => e
      logger.error e

      errors.add(:validation_schema, 'error initialising validation rules')
    end
  end

  def validate_data_schema(schema)
    return errors.add(:data_schema, "can't be blank") if schema.blank?
    validate_schema('data_schema', schema)
  end

  def validate_ui_schema(schema)
    return errors.add(:ui_schema, "can't be blank") if schema.blank?
    validate_schema('ui_schema', schema)
  end

  def validate_ui_logic(schema)
    return errors.add(:ui_logic, "can't be blank") if schema.blank?
  end

  def validate_css_style(schema)
    return if schema.blank?

    errors.add(:css_style, 'must be css file') unless schema.content_type =~ /css/
  end

  def validate_arch16n(arch16n)
    return if arch16n.blank?

    file = arch16n.tempfile
    begin
      line_num = 0
      File.open(file,'r').read.each_line do |line|
        line_num += 1
        next if line.blank?
        i = line.index('=')
        errors.add(:arch16n, "invalid properties file at line #{line_num}") if !i
        errors.add(:arch16n, "invalid properties file at line #{line_num}") if line[0..i] =~ /\s/
      end
    rescue Exception => e
      logger.error e

      errors.add(:arch16n, 'invalid properties file')
    end
  end

  # validation helper

  def validate_schema(attribute, schema)
    errors.add(attribute.to_sym, 'must be xml file') unless schema.content_type =~ /xml/

    begin
      xml_errors = XSDValidator.send("validate_#{attribute}", schema.tempfile.path)

      if xml_errors
        xml_errors.map do |x|
          errors.add(attribute.to_sym, "invalid xml at line #{x.line}")
        end
      end
    rescue => e
      errors.add(attribute.to_sym, e.message)
    end
  end

  after_initialize :init_file_map

  def init_file_map
    project_modules_dir = ProjectModule.project_modules_path
    uploads_dir = ProjectModule.uploads_path
    project_module_dir = project_modules_dir + "/#{key}/"
    n = name.gsub(/\s+/, '_') if name
    n ||= ''
    @file_map = {
        project_modules_dir: { name: 'project_modules', path: project_modules_dir },
        uploads_dir: { name: 'uploads', path: uploads_dir },
        project_module_dir: { name: key, path: project_module_dir },
        data_schema: { name: 'data_schema.xml', path: project_module_dir + 'data_schema.xml' },
        ui_schema: { name: 'ui_schema.xml', path: project_module_dir + 'ui_schema.xml' },
        ui_logic: { name: 'ui_logic.bsh', path: project_module_dir + 'ui_logic.bsh' },
        validation_schema: { name: 'validation_schema.xml', path: project_module_dir + 'validation_schema.xml' },
        css_style: { name: 'style.css', path: project_module_dir + 'style.css' },
        db: { name: 'db.sqlite3', path: project_module_dir + 'db.sqlite3' },
        settings: { name: 'module.settings', path: project_module_dir + 'module.settings' },
        properties: { name: 'faims.properties', path: project_module_dir + 'faims.properties' },
        files_dir: { name: 'files', path: project_module_dir + 'files/' },
        app_files_dir: { name: 'app', path: project_module_dir + 'files/app/' },
        server_files_dir: { name: 'server', path: project_module_dir + 'files/server/' },
        data_files_dir: { name: 'data', path: project_module_dir + 'files/data/' },
        tmp_dir: { name: 'tmp', path: project_module_dir + 'tmp/' },
        package_archive: { name: "#{n}.tar.bz2", path: project_module_dir + "tmp/#{n}.tar.bz2" },
    }
  end

  after_create :init_project_module

  def init_project_module
    FileUtils.mkdir_p @file_map[:project_modules_dir][:path] unless File.directory? @file_map[:project_modules_dir][:path]
    FileUtils.mkdir_p @file_map[:uploads_dir][:path] unless File.directory? @file_map[:uploads_dir][:path]
    FileUtils.mkdir_p @file_map[:project_module_dir][:path] unless File.directory? @file_map[:project_module_dir][:path]
    FileUtils.mkdir_p @file_map[:tmp_dir][:path] unless File.directory? @file_map[:tmp_dir][:path]
    FileUtils.mkdir_p @file_map[:server_files_dir][:path] unless File.directory? @file_map[:server_files_dir][:path]
    FileUtils.mkdir_p @file_map[:app_files_dir][:path] unless File.directory? @file_map[:app_files_dir][:path]
    FileUtils.mkdir_p @file_map[:data_files_dir][:path] unless File.directory? @file_map[:data_files_dir][:path]
  end

  before_destroy :cleanup_module

  def cleanup_module
    safe_delete_directory get_path(:project_module_dir)
  end
  
  # project module attributes
  
  def name
    read_attribute(:name)
  end

  def name=(value)
    write_attribute(:name, value.strip.squish) if value
  end

  # project_module database
  
  def db
    Database.new(self)
  end

  # project_module file name and path getters
  
  def get_name(symbol)
    @file_map[symbol][:name]
  end

  def get_path(symbol)
    @file_map[symbol][:path].to_s
  end

  # project_module file managers

  def settings_mgr
    return @settings_mgr if @settings_mgr
    @settings_mgr = FileManager.new('settings', get_path(:project_module_dir), get_path(:project_module_dir))
    @settings_mgr.add_file(get_path(:ui_schema))
    @settings_mgr.add_file(get_path(:ui_logic))
    @settings_mgr.add_file(get_path(:settings))
    @settings_mgr.add_file(get_path(:properties))
    @settings_mgr.add_file(get_path(:css_style)) if File.exists? get_path(:css_style)
    @settings_mgr
  end

  def db_mgr
    return @db_mgr if @db_mgr
    @db_mgr = FileManager.new('db', get_path(:project_module_dir), get_path(:project_module_dir))
    @db_mgr.add_file(get_path(:db))
    @db_mgr
  end

  def server_mgr
    return @server_mgr if @server_mgr
    @server_mgr = FileManager.new('server', get_path(:project_module_dir), get_path(:server_files_dir))
    @server_mgr.add_dir(get_path(:server_files_dir))
    @server_mgr
  end

  def app_mgr
    return @app_mgr if @app_mgr
    @app_mgr = FileManager.new('app', get_path(:project_module_dir), get_path(:app_files_dir))
    @app_mgr.add_dir(get_path(:app_files_dir))
    @app_mgr
  end

  def data_mgr
    return @data_mgr if @data_mgr
    @data_mgr = FileManager.new('data', get_path(:project_module_dir), get_path(:data_files_dir))
    @data_mgr.add_dir(get_path(:data_files_dir))
    @data_mgr
  end

  def package_mgr
    return @package_mgr if @package_mgr
    @package_mgr = ArchiveManager.new('module', get_path(:project_module_dir), get_path(:project_module_dir),
                             'jcf', get_path(:package_archive), name.gsub(/\s/, '_'))
    @package_mgr.add_dir(get_path(:project_module_dir))
    @package_mgr.ignore_dir(get_path(:tmp_dir))
    @package_mgr
  end

  # lock management

  def with_shared_lock
    settings_mgr.wait_for_lock(File::LOCK_SH)
    server_mgr.wait_for_lock(File::LOCK_SH)
    app_mgr.wait_for_lock(File::LOCK_SH)
    data_mgr.wait_for_lock(File::LOCK_SH)
    db_mgr.wait_for_lock(File::LOCK_SH)
    return yield
  ensure
    settings_mgr.clear_lock
    server_mgr.clear_lock
    app_mgr.clear_lock
    data_mgr.clear_lock
    db_mgr.clear_lock
  end

  def with_exclusive_lock
    settings_mgr.wait_for_lock(File::LOCK_EX)
    server_mgr.wait_for_lock(File::LOCK_EX)
    app_mgr.wait_for_lock(File::LOCK_EX)
    data_mgr.wait_for_lock(File::LOCK_EX)
    db_mgr.wait_for_lock(File::LOCK_EX)
    return yield
  ensure
    settings_mgr.clear_lock
    server_mgr.clear_lock
    app_mgr.clear_lock
    data_mgr.clear_lock
    db_mgr.clear_lock
  end
  
  # project module android info

  def settings_info
    {
        files: file_mgr_info(settings_mgr),
        version: db.current_version.to_s
    }
  end

  def settings_request_file(file)
    get_request_file(get_path(:project_module_dir), file)
  end

  def server_files_info
    {
        files: file_mgr_info(server_mgr)
    }
  end

  def app_files_info
    {
        files: file_mgr_info(app_mgr)
    }
  end

  def app_request_file(file)
    get_request_file(get_path(:app_files_dir), file)
  end

  def data_files_info
    {
        files: file_mgr_info(data_mgr)
    }
  end

  def data_request_file(file)
    get_request_file(get_path(:data_files_dir), file)
  end
  
  # database use versions when sending info
  def db_version_file_name(from_version, to_version)
    "db_v#{from_version}-#{to_version}.sqlite"
  end

  def db_version_file_path(version_num = 0)
    version_num ||= 0
    File.join(get_path(:tmp_dir), db_version_file_name(version_num, db.current_version))
  end

  def db_version_invalid?(version_num)
    version_num ||= 0
    version_num = version_num.to_i
    version_num < 0 or version_num > db.current_version.to_i
  end

  def db_version_info(version_num = 0)
    version_num ||= 0
    full_path = db_version_file_path(version_num)
    {
      files: [{
                file: 'db.sqlite',
                size: File.size(full_path),
                md5: MD5Checksum.compute_checksum(full_path)
              }],
      version: db.current_version.to_s 
    }
  end

  # file info helper function
  def file_mgr_info(file_mgr)
    files = []
    file_mgr.with_shared_lock do
      file_mgr.file_list.each do |f|
        full_path = File.join(file_mgr.base_dir, f)
        files.push(
            {
                file: f,
                size: File.size(full_path),
                md5: MD5Checksum.compute_checksum(full_path)
            }
        )
      end
    end
    files
  end

  def get_request_file(base_dir, file)
    request_file = File.join(base_dir, file)
    raise ProjectModuleException, 'file not found' unless File.exists? request_file
    request_file
  end
  
  def add_server_file(path, file)
    add_file(get_path(:server_files_dir), path, file)
  end
  
  def add_app_file(path, file)
    add_file(get_path(:app_files_dir), path, file)
  end

  def add_data_file(path, file)
    add_file(get_path(:data_files_dir), path, file)
  end

  def add_file(base_dir, path, file)
    raise ProjectModuleException, 'Filename is not valid.' unless is_valid_filename?(path)
    dest_path = File.join(base_dir, path)
    raise ProjectModuleException, 'File already exists.' if File.exists? dest_path
    FileUtils.mkdir_p File.dirname(dest_path) unless Dir.exists? File.dirname(dest_path)
    FileUtils.mv file.path, dest_path
  end

  def add_data_dir(dir)
    raise ProjectModuleException, 'Directory name is not valid.' unless is_valid_filename?(dir)
    dest_path = File.join(get_path(:data_files_dir), dir)
    raise ProjectModuleException, 'Directory already exists.' if File.exists? dest_path and dir != '.'
    FileUtils.mkdir_p dest_path
  end

  def add_data_batch_file(file)
    begin
      success = TarHelper.untar('zxf', file, get_path(:data_files_dir))
      raise ProjectModuleException, 'Could not upload file. Please ensure file is a valid archive.' unless success
    rescue
      raise ProjectModuleException, 'Could not upload file. Please ensure file is a valid archive.'
    end
  end

  def is_valid_filename?(file)
    return false if file.blank?
    # TODO add regex for filename
    true
  end

  # project module settings getter and setter
  
  def get_settings
    JSON.parse(File.read(get_path(:settings).as_json))
    end

  def set_settings(args)
    File.open(get_path(:settings), 'w') do |file|
      file.write({:name => args[:name],
                  :key => key,
                  :season => args[:season],
                  :description => args[:description],
                  :permit_no => args[:permit_no],
                  :permit_holder => args[:permit_holder],
                  :permit_issued_by => args[:permit_issued_by],
                  :permit_type => args[:permit_type],
                  :contact_address => args[:contact_address],
                  :participant => args[:participant],
                  :srid => args[:srid],
                  :copyright_holder => args[:copyright_holder],
                  :client_sponsor => args[:client_sponsor],
                  :land_owner => args[:land_owner],
                  :has_sensitive_data => args[:has_sensitive_data]}.to_json)
    end
  end

  # project module

  def create_project_module_from(tmp_dir, user = nil)
    begin
      # copy files from temp directory to project_modules directory
      FileHelper.copy_dir(tmp_dir, get_path(:project_module_dir))

      # generate database
      Database.generate_database(get_path(:db), get_path(:data_schema), user)

      # create default faims properties
      FileUtils.touch(get_path(:properties))

      generate_temp_files
    rescue Exception => e
      logger.error e

      FileUtils.remove_entry_secure get_path(:project_module_dir) if File.directory? get_path(:project_module_dir) # cleanup directory

      raise ProjectModuleException, 'Failed to create project module.'
    end
  end

  def create_project_module_from_archive_file(tmp_dir)
    begin
      # copy files from temp directory to project_modules directory
      FileHelper.copy_dir(tmp_dir, get_path(:project_module_dir), ['hash_sum'])

      generate_temp_files
    rescue Exception => e
      logger.error e

      FileUtils.remove_entry_secure get_path(:project_module_dir) if File.directory? get_path(:project_module_dir) # cleanup directory

      raise ProjectModuleException, 'Failed to create module from archive.'
    end
  end

  def update_project_module_from(tmp_dir)
    begin
      # copy files from temp directory to project_modules directory
      FileHelper.copy_dir(tmp_dir, get_path(:project_module_dir))

      generate_database_cache
    rescue Exception => e
      logger.error e

      FileUtils.remove_entry_secure get_path(:project_module_dir) if File.directory? get_path(:project_module_dir) # cleanup directory

      raise ProjectModuleException, 'Failed to update project module.'
    end
  end

  def store_database_from_android(file, user)
    begin
      # add new version
      version = db.add_version(user)

      # move file to upload directory
      stored_file = File.join(ProjectModule.uploads_path, "#{key}_v#{version}")

      FileUtils.mv(file.path, stored_file)
    rescue Exception => e
      logger.error e

      raise ProjectModuleException, 'Failed to store database from android.'
    ensure
      # TODO remove last db version?
    end
  end

  # Project archive helpers

  def generate_temp_files
    # initialise file managers
    settings_mgr.init
    db_mgr.init
    server_mgr.init
    app_mgr.init
    data_mgr.init
    package_mgr.init

    # cache current database
    generate_database_cache

    # cache current module
    archive_project_module
  end

  def generate_database_cache(version = 0)
    version ||= 0
    file = db_version_file_path(version)
    return if File.exists? file

    # need to use exclusive lock because database may be directly cloned
    db_mgr.with_exclusive_lock do
      db.create_app_database_from_version(file, version)
    end
  end

  def archive_project_module
    with_exclusive_lock do
      success = package_mgr.update_archive(true)
      raise ProjectModuleException, 'Failed to archive module.' unless success
    end
  end

  def destroy_project_module_archive
     safe_delete_file get_path(:package_archive)
  end

  def self.validate_checksum_for_project_archive(dir)
    hash_sum = JSON.parse(File.read(File.join(dir, "hash_sum")).as_json)

    result = FileHelper.get_file_list(dir).each do |file|
      next if file == 'hash_sum'
      return false unless hash_sum[file] == MD5Checksum.compute_checksum(File.join(dir, file))
    end
    result ||= true

    result
  end

  def self.upload_project_module(file)
    tmp_dir = Dir.mktmpdir + '/'

    logger.info "Untarring project module"
    success = TarHelper.untar('xjf', file, tmp_dir)
    raise ProjectModuleException, 'Failed to upload module.' unless success

    logger.info "Validating project module files and settings"
    module_dir = File.join(tmp_dir, Dir.entries(tmp_dir).select { |d| d != '.' and d != '..' }.first)
    settings = JSON.parse(File.read(File.join(module_dir, "module.settings")).as_json)

    if !validate_checksum_for_project_archive(module_dir)
      raise ProjectModuleException, 'Wrong hash sum for the module.'
    elsif !ProjectModule.find_by_key(settings['key']).blank?
      raise ProjectModuleException, 'This module already exists in the system.'
    elsif !ProjectModule.deleted.find_by_key(settings['key']).blank?
      raise ProjectModuleException, 'This module is deleted but already exists in the system.'
    else
      logger.info "Creating and saving project module"
      project_module = ProjectModule.new(name: settings['name'], key: settings['key'])

      begin
        project_module.save
        project_module.create_project_module_from_archive_file(module_dir)
        project_module.created = true
        project_module.save
      rescue Exception => e
        logger.error e

        File.rm_rf project_module.get_path(:project_module_dir) if File.directory? project_module.get_path(:project_module_dir)
        project_module.destroy

        raise ProjectModuleException, 'Failed to upload module.'
      end

      return project_module
    end
  ensure
    FileUtils.remove_entry_secure tmp_dir if tmp_dir
  end

  # Data archive helpers

  def create_data_archive(dir)
    tmp_dir = Dir.mktmpdir

    files = FileHelper.get_file_list(dir).each do |file|
      FileUtils.mkdir_p File.join(tmp_dir, File.dirname(file))
      FileUtils.cp File.join(dir, file), File.join(tmp_dir, file)
    end
    tmp_file = Tempfile.new(['data_', '.tar.gz'])

    success = TarHelper.tar('zcf', tmp_file.path, tmp_dir, *files)
    raise ProjectModuleException, 'Failed to archive data.' unless success

    tmp_file.path
  ensure
    FileUtils.remove_entry_secure tmp_dir if tmp_dir and File.directory? tmp_dir
  end

  # Export project module helpers

  def export_project_module(exporter, input, download_dir, markup_file)
    # Archive module first if required
    if self.package_mgr.has_changes?
      self.archive_project_module
    end

    archive = self.get_path(:package_archive)
    input_json = File.open(File.join("/tmp", "input_" + SecureRandom.uuid + ".json"), "w+")
    input_json.write(input.to_json)
    input_json.close

    success = exporter.export(archive, input_json.path, download_dir, markup_file)

    raise ProjectModuleException, 'Failed to export module.' unless success
  end

  # static

  def self.project_modules_path
    return Rails.root.to_s + '/tmp/modules' if Rails.env == 'test'
    Rails.application.config.server_project_modules_directory
  end

  def self.uploads_path
    return Rails.root.to_s + '/tmp/uploads' if Rails.env == 'test'
    Rails.application.config.server_uploads_directory
  end

end

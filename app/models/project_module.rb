require Rails.root.join('app/models/modules/database')

class ProjectModule < ActiveRecord::Base
  include XSDValidator
  include Archive::Tar
  include MD5Checksum

  SRID = 4326

  attr_accessor :data_schema, :ui_schema, :ui_logic, :arch16n, :season, :description, :permit_no, :permit_holder, :permit_issued_by,:permit_type, :contact_address,
                :participant, :validation_schema, :srid, :copyright_holder, :client_sponsor, :land_owner, :has_sensitive_data, :tmpdir

  attr_accessible :name, :key, :created, :data_schema, :ui_schema, :ui_logic, :arch16n, :season, :description, :permit_no, :permit_holder, :permit_issued_by,:permit_type, :contact_address, :participant, :vocab_id, :type,
    :validation_schema, :srid,:copyright_holder, :client_sponsor, :land_owner, :has_sensitive_data , :tmpdir

  validates :name, :presence => true, :length => {:maximum => 255},
            :format => {:with => /^(\s*[^\/\\\?\%\*\:\|\"\'\<\>\.]+\s*)*$/i} # do not allow file name reserved characters

  validates :key, :presence => true, :uniqueness => true

  default_scope order: 'name COLLATE NOCASE'

  after_initialize :init_file_map

  after_create :init_project_module

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
        db: { name: 'db.sqlite3', path: project_module_dir + 'db.sqlite3' },
        settings: { name: 'module.settings', path: project_module_dir + 'module.settings' },
        properties: { name: 'faims.properties', path: project_module_dir + 'faims.properties' },
        files_dir: { name: 'files', path: project_module_dir + 'files/' },
        app_files_dir: { name: 'app', path: project_module_dir + 'files/app/' },
        server_files_dir: { name: 'server', path: project_module_dir + 'files/server/' },
        data_files_dir: { name: 'data', path: project_module_dir + 'files/data/' },
        tmp_dir: { name: 'tmp', path: project_module_dir + 'tmp/' },
        package_archive: { name: "#{n}.tar.bz2", path: project_module_dir + "tmp/#{n}.tar.bz2" },
        db_archive: { name: 'db.tar.gz', path: project_module_dir + 'tmp/db.tar.gz' },
        settings_archive: { name: 'settings.tar.gz', path: project_module_dir + 'tmp/settings.tar.gz' },
        app_files_archive: { name: 'app.tar.gz', path: project_module_dir + 'tmp/app.tar.gz' },
        server_files_archive: { name: 'server.tar.gz', path: project_modules_dir + 'tmp/server.tar.gz' },
        data_files_archive: { name: 'data.tar.gz', path: project_module_dir + 'tmp/data.tar.gz' },
        validation_schema: { name: 'validation_schema.xml', path: project_module_dir + 'validation_schema.xml' },
    }
  end

  def init_project_module
    FileUtils.mkdir_p @file_map[:project_modules_dir][:path] unless File.directory? @file_map[:project_modules_dir][:path]
    FileUtils.mkdir_p @file_map[:uploads_dir][:path] unless File.directory? @file_map[:uploads_dir][:path]
    FileUtils.mkdir_p @file_map[:project_module_dir][:path] unless File.directory? @file_map[:project_module_dir][:path]
    FileUtils.mkdir_p @file_map[:tmp_dir][:path] unless File.directory? @file_map[:tmp_dir][:path]
    FileUtils.mkdir_p @file_map[:server_files_dir][:path] unless File.directory? @file_map[:server_files_dir][:path]
    FileUtils.mkdir_p @file_map[:app_files_dir][:path] unless File.directory? @file_map[:app_files_dir][:path]
    FileUtils.mkdir_p @file_map[:data_files_dir][:path] unless File.directory? @file_map[:data_files_dir][:path]
  end

  def name
    read_attribute(:name)
  end

  def name=(value)
    write_attribute(:name, value.strip.squish) if value
  end

  def vocab_id
  end

  def type
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

  # project_module archives

  def db_mgr
    mgr = FileManager.new('db', get_path(:project_module_dir), 'zcf', get_path(:db_archive))
    mgr.add_file(get_path(:db))
    mgr
  end

  def settings_mgr
    mgr = FileManager.new('settings', get_path(:project_module_dir), 'zcf', get_path(:settings_archive))
    mgr.add_file(get_path(:ui_schema))
    mgr.add_file(get_path(:ui_logic))
    mgr.add_file(get_path(:settings))
    mgr.add_file(get_path(:properties))
    mgr
  end

  def server_mgr
    mgr = FileManager.new('server', get_path(:server_files_dir), 'zcf', get_path(:server_files_archive))
    mgr.add_dir(get_path(:server_files_dir))
    mgr
  end

  def app_mgr
    mgr = FileManager.new('app', get_path(:app_files_dir), 'zcf', get_path(:app_files_archive))
    mgr.add_dir(get_path(:app_files_dir))
    mgr
  end

  def data_mgr
    mgr = FileManager.new('data', get_path(:data_files_dir), 'zcf', get_path(:data_files_archive))
    mgr.add_dir(get_path(:data_files_dir))
    mgr
  end

  def package_mgr
    mgr = FileManager.new('module', get_path(:project_module_dir), 'zcf', get_path(:package_archive))
    mgr
  end

  def has_attached_files
    FileHelper.get_file_list(get_path(:server_files_dir)).size > 0 or
        FileHelper.get_file_list(get_path(:app_files_dir)).size > 0
  end

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
                    file: 'db.sqlite3',
                    size: File.size(full_path),
                    md5: MD5Checksum.compute_checksum(full_path)
                }],
        version: db.current_version.to_s
    }
  end

  # file info helper function
  def file_mgr_info(file_mgr)
    files = []
    file_mgr.with_lock do
      file_mgr.file_list.each do |f|
        f = f.gsub(/^#{file_mgr.base_dir}/, '')
        next if /\.lock/ =~ f
        next if /\.dirty/ =~ f
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
    raise Exception, 'file not found' unless File.exists? request_file
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
    return 'Filename is not valid.' unless is_valid_filename?(path)
    dest_path = File.join(base_dir, path)
    return 'File already exists.' if File.exists? dest_path
    FileUtils.mkdir_p File.dirname(dest_path) unless Dir.exists? File.dirname(dest_path)
    FileUtils.mv file.path, dest_path
    nil
  end

  def add_data_dir(dir)
    return 'Directory name is not valid.' unless is_valid_filename?(dir)
    dest_path = File.join(get_path(:data_files_dir), dir)
    return 'Directory already exists.' if File.exists? dest_path and dir != '.'
    FileUtils.mkdir_p dest_path
    nil
  end

  def add_data_batch_file(file)
    begin
      success = TarHelper.untar('zxf', file, get_path(:data_files_dir))
      return 'Could not upload file. Please ensure file is a valid archive.' unless success
    rescue
      return 'Could not upload file. Please ensure file is a valid archive.'
    end
  end

  def is_valid_filename?(file)
    return false if file.blank?
    # TODO add regex for filename
    true
  end

  def dirty?
    settings_mgr.dirty? or db_mgr.dirty? or app_mgr.dirty? or data_mgr.dirty?
  end

  def modified_after_package(mgr)
    return true unless package_mgr.last_modified
    modified = false
    mgr.file_list.each do |f|
      next unless File.exists? f
      if File.ctime(f) > package_mgr.last_modified
        modified = true
        break
      end
    end
    modified
  end

  def package_dirty?
    package_mgr.dirty? or
        modified_after_package(settings_mgr) or
        modified_after_package(db_mgr) or
        modified_after_package(data_mgr) or
        modified_after_package(app_mgr) or
        modified_after_package(server_mgr)
  end

  def locked?
    settings_mgr.locked? or db_mgr.locked? or app_mgr.locked? or data_mgr.locked?
  end

  def with_lock
    settings_mgr.wait_for_lock
    db_mgr.wait_for_lock
    app_mgr.wait_for_lock
    data_mgr.wait_for_lock
    return yield
  ensure
    settings_mgr.clear_lock
    db_mgr.clear_lock
    app_mgr.clear_lock
    data_mgr.clear_lock
  end

  def generate_archives
    generate_database_cache
    update_archives
  end

  def update_archives
    package_project_module
  end

  def generate_database_cache(version = 0)
    version ||= 0
    file = db_version_file_path(version)
    return if File.exists? file

    # need to use exclusive lock because database may be directly cloned
    db_mgr.with_lock do
      db.create_app_database_from_version(file, version)
    end
  end

  def get_settings
    JSON.parse(File.read(get_path(:settings).as_json))
  end

  def update_settings(params)
    settings_mgr.with_lock do
      File.open(get_path(:settings), 'w') do |file|
        file.write({:name => params[:project_module][:name],
                    :key => key,
                    :season => params[:project_module][:season],
                    :description => params[:project_module][:description],
                    :permit_no => params[:project_module][:permit_no],
                    :permit_holder => params[:project_module][:permit_holder],
                    :permit_issued_by => params[:project_module][:permit_issued_by],
                    :permit_type => params[:project_module][:permit_type],
                    :contact_address => params[:project_module][:contact_address],
                    :participant => params[:project_module][:participant],
                    :srid => params[:project_module][:srid],
                    :copyright_holder => params[:project_module][:copyright_holder],
                    :client_sponsor => params[:project_module][:client_sponsor],
                    :land_owner => params[:project_module][:land_owner],
                    :has_sensitive_data => params[:project_module][:has_sensitive_data]
                   }.to_json)
        settings_mgr.make_dirt
      end
    end
  end

  def create_project_module_from(tmp_dir, user = nil)
    begin
      # copy files from temp directory to project_modules directory
      FileHelper.copy_dir(tmp_dir, get_path(:project_module_dir))

      # generate database
      Database.generate_database(get_path(:db), get_path(:data_schema), user)

      # create default faims properties
      FileHelper.touch_file(get_path(:properties))

      # generate archive
      generate_archives
    rescue Exception => e
      FileUtils.rm_rf get_path(:project_module_dir) if File.directory? get_path(:project_module_dir) # cleanup directory
      raise e
    ensure
      # ignore
    end
  end

  def update_project_module_from(tmp_dir)
    settings_mgr.with_lock do
      begin
        # copy files from temp directory to project_modules directory
        FileHelper.copy_dir(tmp_dir, get_path(:project_module_dir))

        # generate archive
        settings_mgr.make_dirt
      rescue Exception => e
        FileUtils.rm_rf get_path(:project_module_dir) if File.directory? get_path(:project_module_dir) # cleanup directory
        raise e
      ensure
        # ignore
      end
    end
  end

  def create_project_module_from_compressed_file(tmp_dir)
    begin
      # copy files from temp directory to project_modules directory
      FileHelper.copy_dir(tmp_dir, get_path(:project_module_dir), ['hash_sum'])
      # generate archive
      generate_archives
    rescue Exception => e
      FileUtils.rm_rf get_path(:project_module_dir) if File.directory? get_path(:project_module_dir) # cleanup directory
      raise e
    ensure
      # ignore
    end
  end

  def check_sum(file, md5)
    MD5Checksum.compute_checksum(file.path) == md5
  end

  def store_database(file, user)
    begin
      # add new version
      version = db.add_version(user)

      # move file to upload directory
      stored_file = File.join(ProjectModule.uploads_path, "#{key}_v#{version}")

      FileUtils.mv(file.path, stored_file)
    rescue Exception => e
      logger.error e

      raise Exception, 'Failed to store database from android.'
    ensure
      # TODO remove last db version?
    end

  end

  def self.validate_validation_schema(schema)
    return nil if schema.blank?
    return 'must be xml file' unless schema.content_type =~ /xml/
    begin
      file = schema.tempfile
      result = XSDValidator.validate_validation_schema(file.path)
    rescue => e
      result = [e]
    end
    return result.map { |x| "invalid xml at line #{x.line}" }.join("<br/>") if !result.empty?
    begin
      DatabaseValidator.new(nil, schema.tempfile.path)
    rescue Exception => e
      return 'error initialising validation rules'
    end
    return nil
  end

  def self.validate_data_schema(schema)
    return "can't be blank" if schema.blank?
    return 'must be xml file' unless schema.content_type =~ /xml/
    begin
      file = schema.tempfile
      result = XSDValidator.validate_data_schema(file.path)
    rescue => e
      result = [e]
    end
    return result.map { |x| "invalid xml at line #{x.line}" }.join("<br/>") if !result.empty?
    return nil
  end

  def self.validate_ui_schema(schema)
    return "can't be blank" if schema.blank?
    return 'must be xml file' unless schema.content_type =~ /xml/
    begin
      file = schema.tempfile
      result = XSDValidator.validate_ui_schema(file.path)
    rescue => e
      result = [e]
    end
    return result.map { |x| "invalid xml at line #{x.line}" }.join("<br/>") if !result.empty?
    return nil
  end

  def self.validate_ui_logic(schema)
    return "can't be blank" if schema.blank?
  end

  def self.validate_arch16n(arch16n)
    return nil if arch16n.blank?
    begin
      file = arch16n.tempfile
      line_num = 0
      error = ""
      File.open(file,'r').read.each_line do |line|
        line_num += 1
        next if line.blank?
        i = line.index('=')
        error += "invalid properties file at line #{line_num}<br/>" if !i
        error += "invalid properties file at line #{line_num}<br/>" if line[0..i] =~ /\s/
      end
    rescue
      return 'invalid properties file'
    end
    return nil if error.empty?
    return error
  end

  def self.validate_directory(dir)
    return false unless dir
    return false if dir.blank?
    return false unless dir =~ /^(\s*[^\/\\\?\%\*\:\|\"\'\<\>\.]+\s*)*$/i
    true
  end

  def validate_version(version)
    return false unless version
    return false if version.to_i < 1
    v = db.current_version.to_i
    return false unless v > 0
    return version.to_i <= v
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

  def package_project_module
    with_lock do
      begin
        tmp_dir = Dir.mktmpdir + '/'

        # create project_module directory to archive
        project_module_dir = tmp_dir + 'module/'
        Dir.mkdir(project_module_dir)

        hash_sum = {}

        FileHelper.get_file_list(get_path(:project_module_dir)).each do |file|
          next if File.basename(file) =~ /^(\.)/ # ignore dot files
          next if File.dirname(file) =~ /^(#{get_name(:tmp_dir)})/ # ignore tmp directory
          hash_sum[file] = MD5Checksum.compute_checksum(get_path(:project_module_dir) + file)
          FileUtils.mkdir_p project_module_dir + File.dirname(file)
          FileUtils.cp get_path(:project_module_dir) + file, project_module_dir + file
        end

        File.open(project_module_dir + '/hash_sum', 'w') do |file|
          file.write(hash_sum.to_json)
        end

        TarHelper.tar('jcf', get_path(:package_archive), tmp_dir, File.basename(project_module_dir))

        package_mgr.clean_dirt
      rescue Exception => e
        raise e
      ensure
        # cleanup
        FileUtils.rm_rf tmp_dir if File.directory? tmp_dir
      end
    end
  end

  def archive_database
    db_mgr.with_lock do
      begin
        tmp_dir = Dir.mktmpdir + '/'

        # create app database
        db.create_app_database(tmp_dir + get_name(:db))

        TarHelper.tar('zcf', get_path(:db_archive), tmp_dir, get_name(:db))
      rescue Exception => e
        raise e
      ensure
        # cleanup
        FileUtils.rm_rf tmp_dir if File.directory? tmp_dir

        db_mgr.clean_dirt
      end
    end
  end

  def archive_database_version(version, temp_path)
    db_mgr.with_lock do
      begin
        tmp_dir = Dir.mktmpdir + '/'

        # create app database
        db.create_app_database_from_version(tmp_dir + get_name(:db), version)

        TarHelper.tar('zcf', temp_path, tmp_dir, get_name(:db))
      rescue Exception => e
        raise e
      ensure
        # cleanup
        FileUtils.rm_rf tmp_dir if File.directory? tmp_dir
      end
    end
  end

  def self.checksum_uploaded_file(dir)
    hash_sum = JSON.parse(File.read(dir + '/hash_sum').as_json)
    FileHelper.get_file_list(dir).each do |file|
      next if file == 'hash_sum'
      return false unless hash_sum[file].eql?(MD5Checksum.compute_checksum(dir + '/'+ file))
    end
    true
  end

  def self.upload_project_module(params)
    tmp_dir = nil
    begin
      tar_file = params[:project_module][:project_module_file]

      tmp_dir = Dir.mktmpdir + '/'
      `tar xjf #{tar_file.tempfile.to_path.to_s} -C #{tmp_dir}`
      project_module_settings = JSON.parse(File.read(tmp_dir + 'module/module.settings').as_json)
      if !ProjectModule.checksum_uploaded_file(tmp_dir + 'module')
        return 'Wrong hash sum for the module'
      elsif !ProjectModule.find_by_key(project_module_settings['key']).blank?
        return 'This module already exists in the system'
      else
        project_module = ProjectModule.new(:name => project_module_settings['name'], :key => project_module_settings['key'])
        begin
          project_module.save
          project_module.create_project_module_from_compressed_file(tmp_dir + 'module')
          project_module.created = true
          project_module.save
        rescue
          File.rm_rf project_module.get_path(:project_module_dir) if File.directory? project_module.get_path(:project_module_dir)
          project_module.destroy
        end
        return project_module
      end

    rescue Exception
      return 'Module failed to upload'
    ensure
      FileUtils.rm_rf tmp_dir if tmp_dir
    end
  end

  def create_temp_dir_archive(dir)
    tmp_dir = Dir.mktmpdir
    base_dir = File.join(tmp_dir, 'data')
    FileHelper.get_file_list(dir).each do |file|
      FileUtils.mkdir_p File.join(base_dir, File.dirname(file))
      FileUtils.cp File.join(dir, file), File.join(base_dir, file)
    end
    tmp_file = Tempfile.new(['data_', '.tar.gz'])
    TarHelper.tar('zcf', tmp_file.path, tmp_dir, 'data')
    tmp_file.path
  ensure
    FileUtils.rm_rf tmp_dir if tmp_dir and File.directory? tmp_dir
  end

end

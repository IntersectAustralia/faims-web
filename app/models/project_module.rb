require Rails.root.join('app/models/modules/database')

class ProjectModule < ActiveRecord::Base
  include XSDValidator
  include MD5Checksum

  SRID = 4326

  attr_accessor :data_schema, :ui_schema, :ui_logic, :arch16n, :season, :description, :permit_no, :permit_holder, :permit_issued_by,:permit_type, :contact_address,
                :participant, :validation_schema, :srid, :copyright_holder, :client_sponsor, :land_owner, :has_sensitive_data, :tmpdir

  attr_accessible :name, :key, :created, :data_schema, :ui_schema, :ui_logic, :arch16n, :season, :description, :permit_no, :permit_holder, :permit_issued_by, :permit_type, :contact_address, :participant,
    :validation_schema, :srid,:copyright_holder, :client_sponsor, :land_owner, :has_sensitive_data , :tmpdir

  validates :name, :presence => true, :length => {:maximum => 255},
            :format => {:with => /\A(\s*[^\/\\\?\%\*\:\|\"\'\<\>\.]+\s*)*\z/i} # do not allow file name reserved characters

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
    mgr = FileManager.new('server', get_path(:project_module_dir), 'zcf', get_path(:server_files_archive))
    mgr.add_dir(get_path(:server_files_dir))
    mgr
  end

  def app_mgr
    mgr = FileManager.new('app', get_path(:project_module_dir), 'zcf', get_path(:app_files_archive))
    mgr.add_dir(get_path(:app_files_dir))
    mgr
  end

  def data_mgr
    mgr = FileManager.new('data', get_path(:project_module_dir), 'zcf', get_path(:data_files_archive))
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

  def settings_archive_info
    settings_mgr.update_archive

    info = nil

    settings_mgr.with_lock do
      info = {
          :file => get_path(:settings_archive),
          :size => File.size(get_path(:settings_archive)),
          :md5 => MD5Checksum.compute_checksum(get_path(:settings_archive))
      }
    end

    v = db.current_version.to_i
    info = info.merge({ :version => v.to_s }) if v > 0
    info
  end

  def db_archive_info
    db_mgr.update_archive

    info = nil

    db_mgr.with_lock do
      info = {
          :file => get_path(:db_archive),
          :size => File.size(get_path(:db_archive)),
          :md5 => MD5Checksum.compute_checksum(get_path(:db_archive))
      }
    end

    v = db.current_version.to_i
    info = info.merge({ :version => v.to_s }) if v > 0
    info
  end

  def temp_db_version_file_path(to_version)
    db_version_file_path(to_version, db.current_version)
  end

  def db_version_file_name(from_version, to_version)
    "db_v#{from_version}-#{to_version}.tar.gz"
  end

  def db_version_file_path(from_version, to_version)
    get_path(:tmp_dir) + db_version_file_name(from_version, to_version)
  end

  def db_version_archive_info(version_num)
      # create temporary archive of database
      temp_path = db_version_file_path(version_num, db.current_version)
      archive_database_version(version_num, temp_path) unless File.exists? temp_path

      info = {
        :file => temp_path,
        :size => File.size(temp_path),
        :md5 => MD5Checksum.compute_checksum(temp_path)
      }

      v = db.current_version.to_i
      info = info.merge({ :version => v.to_s }) if v > 0
      info
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
    db_mgr.make_dirt
    settings_mgr.make_dirt
    app_mgr.make_dirt
    data_mgr.make_dirt
    update_archives
  end

  def update_archives
    settings_mgr.update_archive
    app_mgr.update_archive
    data_mgr.update_archive

    # custom update archive for database
    archive_database

    # custom update archive for package
    package_project_module
  end

  def update_android_archives
    settings_mgr.update_archive
    app_mgr.update_archive
    data_mgr.update_archive

    # custom update archive for database
    archive_database
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
      FileUtils.remove_entry_secure get_path(:project_module_dir) if File.directory? get_path(:project_module_dir) # cleanup directory
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
        FileUtils.remove_entry_secure get_path(:project_module_dir) if File.directory? get_path(:project_module_dir) # cleanup directory
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
      FileUtils.remove_entry_secure get_path(:project_module_dir) if File.directory? get_path(:project_module_dir) # cleanup directory
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
      tmp_dir = Dir.mktmpdir + '/'

      TarHelper.untar('xfz', file.path, tmp_dir)

      # add new version
      version = db.add_version(user)

      unarchived_file = tmp_dir + Dir.entries(tmp_dir).select { |f| f unless File.directory? tmp_dir + f }.first
      stored_file = "#{ProjectModule.uploads_path}/#{key}_v#{version}"

      # move file to upload directory
      FileUtils.mv(unarchived_file, stored_file)

    rescue Exception => e
      raise e

      # TODO remove added version in database if created
    ensure
      # cleanup
      FileUtils.remove_entry_secure tmp_dir if File.directory? tmp_dir
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

  def server_file_list(exclude_files = nil)
    return [] unless File.directory? get_path(:server_files_dir)
    file_list = FileHelper.get_file_list(get_path(:server_files_dir))
    return file_list unless exclude_files
    file_list.select { |f| !exclude_files.include? f }
  end

  def add_server_file(file, path)
    full_path = make_path(get_path(:server_files_dir), path)
    FileUtils.cp(file.path, full_path)
  end

  def server_file_archive_info(exclude_files = nil)
    file_archive_info(get_path(:server_files_dir), server_file_list(exclude_files))
  end

  def server_file_upload(file)
    # don't need to lock server files as server files cannot be downloaded
    TarHelper.untar('xfz', file.path, get_path(:server_files_dir))
  end

  def app_file_list(exclude_files = nil)
    app_mgr.with_lock do
      non_locking_app_file_list(exclude_files)
    end
  end

  def non_locking_app_file_list(exclude_files = nil)
    return [] unless File.directory? get_path(:app_files_dir)
    file_list = FileHelper.get_file_list(get_path(:app_files_dir))
    return file_list unless exclude_files
    file_list.select { |f| !exclude_files.include? f }
  end

  def add_app_file(file, path)
    app_mgr.with_lock do
      full_path = make_path(get_path(:app_files_dir), path)
      FileUtils.cp(file.path, full_path)
      app_mgr.make_dirt
    end
  end

  def app_file_archive_info(exclude_files = nil)
    if exclude_files
      app_mgr.with_lock do
       file_archive_info(get_path(:app_files_dir), non_locking_app_file_list(exclude_files))
      end
    else
      app_mgr.update_archive

      app_mgr.with_lock do
        {
            :file => get_path(:app_files_archive),
            :size => File.size(get_path(:app_files_archive)),
            :md5 => MD5Checksum.compute_checksum(get_path(:app_files_archive))
        }
      end
    end
  end

  def app_file_upload(file)
    app_mgr.with_lock do
      TarHelper.untar('xfz', file.path, get_path(:app_files_dir))
      app_mgr.make_dirt
    end
  end

  def data_file_list(exclude_files = nil)
    data_mgr.with_lock do
      non_locking_data_file_list(exclude_files)
    end
  end

  def non_locking_data_file_list(exclude_files = nil)
    return [] unless File.directory? get_path(:data_files_dir)
    file_list = FileHelper.get_file_list(get_path(:data_files_dir))
    return file_list unless exclude_files
    file_list.select { |f| !exclude_files.include? f }
  end

  def add_data_file(file, path)
    file_path = File.join(get_path(:data_files_dir), path)
    return 'File already exists' if File.exists? file_path
    data_mgr.with_lock do
      dir = (File.directory? file_path) ? file_path : File.dirname(file_path)
      FileUtils.mkdir_p dir
      FileUtils.cp(file.path, file_path)
      data_mgr.make_dirt
    end
    nil
  end

  def add_batch_file(file)
    begin
      success = nil
      data_mgr.with_lock do
        success = `tar zxf #{file.path} -C #{get_path(:data_files_dir)}; echo $?`.strip
        data_mgr.make_dirt
      end
      return nil if success == '0'
      return 'Could not upload file. Please ensure file is a valid archive.'
    rescue
      return 'Could not upload file. Please ensure file is a valid archive.'
    end
  end

  def data_file_archive_info(exclude_files = nil)
    if exclude_files
      data_mgr.with_lock do
        file_archive_info(get_path(:data_files_dir), non_locking_data_file_list(exclude_files))
      end
    else
      data_mgr.update_archive

      data_mgr.with_lock do
        {
            :file => get_path(:data_files_archive),
            :size => File.size(get_path(:data_files_archive)),
            :md5 => MD5Checksum.compute_checksum(get_path(:data_files_archive))
        }
      end
    end
  end

  def data_file_upload(file)
    data_mgr.with_lock do
      TarHelper.untar('xfz', file.path, get_path(:data_files_dir))
      data_mgr.make_dirt
    end
  end

  def create_data_dir(dir)
    full_dir = File.join(get_path(:data_files_dir), dir)
    return 'Directory already exists' if File.directory? full_dir
    FileUtils.mkdir_p full_dir
    nil
  end

  def make_path(dir, path)
    FileUtils.mkdir_p dir unless File.directory? dir
    full_path = dir + '/' + File.dirname(path)
    FileUtils.mkdir_p full_path
    full_path
  end

  def file_archive_info(dir, files)
    tmp_dir = Dir.mktmpdir + '/'
    temp_file = tmp_dir + 'files_archive.tar.gz'

    TarHelper.tar('zcf', temp_file, files, dir)

    {
        :file => temp_file,
        :size => File.size(temp_file),
        :md5 => MD5Checksum.compute_checksum(temp_file)
    }
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

        TarHelper.tar('jcf', get_path(:package_archive), File.basename(project_module_dir), tmp_dir)

        package_mgr.clean_dirt
      rescue Exception => e
        raise e
      ensure
        # cleanup
        FileUtils.remove_entry_secure tmp_dir if File.directory? tmp_dir
      end
    end
  end

  def archive_database
    db_mgr.with_lock do
      begin
        tmp_dir = Dir.mktmpdir + '/'

        # create app database
        db.create_app_database(tmp_dir + get_name(:db))

        TarHelper.tar('zcf', get_path(:db_archive), get_name(:db), tmp_dir)
      rescue Exception => e
        raise e
      ensure
        # cleanup
        FileUtils.remove_entry_secure tmp_dir if File.directory? tmp_dir

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

        TarHelper.tar('zcf', temp_path, get_name(:db), tmp_dir)
      rescue Exception => e
        raise e
      ensure
        # cleanup
        FileUtils.remove_entry_secure tmp_dir if File.directory? tmp_dir
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
      TarHelper.untar('xjf', tar_file.tempfile.to_path.to_s, tmp_dir)
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
      FileUtils.remove_entry_secure tmp_dir if tmp_dir
    end
  end

  def create_temp_dir_archive(dir)
    tmp_dir = Dir.mktmpdir
    files = FileHelper.get_file_list(dir).each do |file|
      FileUtils.mkdir_p File.join(tmp_dir, File.dirname(file))
      FileUtils.cp File.join(dir, file), File.join(tmp_dir, file)
    end
    tmp_file = Tempfile.new(['data_', '.tar.gz'])
    TarHelper.tar('zcf', tmp_file.path, files, tmp_dir)
    tmp_file.path
  ensure
    FileUtils.remove_entry_secure tmp_dir if tmp_dir and File.directory? tmp_dir
  end

end

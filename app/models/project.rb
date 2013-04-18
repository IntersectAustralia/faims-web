require Rails.root.join('app/projects/models/database')

class Project < ActiveRecord::Base
  include XSDValidator
  include Archive::Tar
  include MD5Checksum

  attr_accessor :data_schema, :ui_schema, :ui_logic, :arch16n, :season, :description, :permit_no, :permit_holder, :contact_address, :participant

  attr_accessible :name, :key, :data_schema, :ui_schema, :ui_logic, :arch16n, :season, :description, :permit_no, :permit_holder, :contact_address, :participant, :vocab_id, :type

  validates :name, :presence => true, :length => {:maximum => 255},
            :format => {:with => /^(\s*[^\/\\\?\%\*\:\|\"\'\<\>\.]+\s*)*$/i} # do not allow file name reserved characters

  validates :key, :presence => true, :uniqueness => true

  default_scope order: 'name COLLATE NOCASE'

  def name=(value)
    write_attribute(:name, value.strip.squish) if value
  end

  def vocab_id
  end

  def type
  end

  def db
    Database.new(self)
  end

  def dir_name
    key
  end

  def dir_path
    Project.projects_path + '/' + dir_name
  end

  def filepath
    dir_path + '/' + Project.filename
  end

  def package_path
    dir_path + '/' + Project.package_name(key)
  end

  def db_file_path
    dir_path + '/' + Project.db_file_name
  end

  def data_schema_path
    dir_path + '/' + Project.data_schema_name
  end

  def ui_logic_path
    dir_path + '/' + Project.ui_logic_name
  end

  def ui_schema_path
    dir_path + '/' + Project.ui_schema_name
  end

  def db_path
    dir_path + '/' + Project.db_name
  end

  def faims_properties_path
    dir_path + '/' + Project.faims_properties_name
  end

  def faims_project_properties_name
    'faims_' + name.gsub(/\s+/, '_') + '.properties'
  end

  def faims_project_properties_path
    dir_path + '/' + faims_project_properties_name
  end

  def project_settings_path
    dir_path + '/' + Project.project_settings_name
  end

  def server_files_dir_path
    dir_path + '/' + Project.server_files_dir_name
  end

  def app_files_dir_path
    dir_path + '/' + Project.app_files_dir_name
  end

  def project_setting
    File.read(dir_path + '/' + Project.project_settings_name).as_json
  end

  def latest_version
    v = db.current_version
    v = '0' unless v
    v.to_s
  end

  def temp_db_version_file_path(version)
    temp_db_dir_path + '/' + Project.db_version_file_name(version, latest_version)
  end

  def temp_project_file_path
    dir_path + '/' + Project.package_name(key)
  end

  def temp_db_dir_path
    dir_path + '/tmp'
  end

  def is_locked
    Project.is_locked(project_key)
  end

  def is_dirty
    Project.is_dirty(project_key)
  end

  def with_lock
    Project.try_lock_project(key)
    result = yield
    Project.unlock_project(key)
    result
  end

  def dirty
    Project.dirty(project_key)
  end

  def clean
    Project.clean(project_key)
  end

  def archive_info
    update_archives

    info = {
        :file => Project.filename,
        :size => File.size(filepath),
        :md5 => MD5Checksum.compute_checksum(filepath)
    }
    v = latest_version.to_i
    info = info.merge({ :version => v }) if v > 0
    info
  end

  def archive_db_info
    update_archives

    info = {
        :file => Project.db_file_name,
        :size => File.size(db_file_path),
        :md5 => MD5Checksum.compute_checksum(db_file_path)
    }
    v = latest_version.to_i
    info = info.merge({ :version => v }) if v > 0
    info
  end

  def archive_db_version_info(version_num)
      # create db tmp dir
      FileUtils.mkdir temp_db_dir_path unless File.directory? temp_db_dir_path

      # create temporary archive of database
      temp_path = temp_db_version_file_path(version_num)
      Project.archive_database_version_for(key, version_num, temp_path) unless File.exists? temp_path
      info = {
        :file => Project.db_version_file_name(version_num, latest_version),
        :size => File.size(temp_path),
        :md5 => MD5Checksum.compute_checksum(temp_path)
      }
      v = latest_version.to_i
      info = info.merge({ :version => v }) if v > 0
      info
  end

  def update_archives(force = false)
    Project.update_archives_for(key, force)
  end

  def create_project_from(tmp_dir)

    begin
      Dir.mkdir(Project.projects_path) unless File.directory? Project.projects_path # make sure projects directory exists

      FileUtils.rm_rf dir_path if File.directory? dir_path # overwrite current project directory
      Dir.mkdir(dir_path)

      # copy files from temp directory to projects directory
      TarHelper.copy_dir(tmp_dir, dir_path)

      # generate database
      Database.generate_database(dir_path + '/' + Project.db_name, dir_path + '/' + Project.data_schema_name)

      # create default faims properties
      TarHelper.touch_file(dir_path + '/' + Project.faims_properties_name)

      # generate archive
      update_archives(true)
    rescue Exception => e
      puts "Error creating project"
      FileUtils.rm_rf dir_path if File.directory? dir_path # cleanup directory
      raise e
    end
  end

  def create_project_from_compressed_file(tmp_dir)

    begin
      Dir.mkdir(Project.projects_path) unless File.directory? Project.projects_path # make sure projects directory exists

      FileUtils.rm_rf dir_path if File.directory? dir_path # overwrite current project directory
      Dir.mkdir(dir_path)

      # copy files from temp directory to projects directory
      TarHelper.copy_dir(tmp_dir, dir_path)

      # generate archive
      update_archives(true)
    rescue Exception => e
      puts "Error creating project"
      FileUtils.rm_rf dir_path if File.directory? dir_path # cleanup directory
      raise e
    end
  end

  def check_sum(file, md5)
    current_md5 = MD5Checksum.compute_checksum(file.path)
    return true if current_md5 == md5
    return false
  end

  def store_database(file, user)
    begin
      tmp_dir = Dir.mktmpdir(dir_path + '/') + '/'

      TarHelper.untar('xfz', file.path, tmp_dir)

      # add new version
      version = db.add_version(user)

      unarchived_file = tmp_dir + Dir.entries(tmp_dir).select { |f| f unless File.directory? tmp_dir + f }.first
      stored_file = "#{Project.uploads_path}/#{key}_v#{version}"

      # create upload directory if it doesn't exist
      Dir.mkdir(Project.uploads_path) unless File.directory? Project.uploads_path

      # move file to upload directory
      FileUtils.mv(unarchived_file, stored_file)

    rescue Exception => e
      puts "Error storing database"
      raise e

      # TODO remove added version in database if created
    ensure
      # cleanup
      FileUtils.rm_rf tmp_dir if File.directory? tmp_dir
    end

  end

  def self.validate_data_schema(schema)
    return "can't be blank" if schema.blank?
    return "must be xml file" if schema.content_type != "text/xml"
    begin
      file = schema.tempfile
      result = XSDValidator.validate_data_schema(file.path)
    rescue => e
      logger.error "Exception validating data schema #{e}"
      result = nil
    end
    return "invalid xml" if result.nil? || !result.empty?
    return nil
  end

  def self.validate_ui_schema(schema)
    return "can't be blank" if schema.blank?
    return "must be xml file" if schema.content_type != "text/xml"
    begin
      file = schema.tempfile
      result = XSDValidator.validate_ui_schema(file.path)
    rescue => e
      logger.error "Exception validating ui schema #{e}"
      result = nil
    end
    return "invalid xml" if result.nil? || !result.empty?
    return nil
  end

  def self.validate_arch16n(arch16n,projectname)
    return "invalid file name" if !(arch16n.original_filename).eql?("faims_"+ projectname.gsub(/\s/, '_')+".properties")
    begin
      file = arch16n.tempfile
      File.open(file,'r').read.each_line do |line|
        line.strip!
        return "invalid properties file" if line[0] == ?=
        i = line.index('=')
        return "invalid properties file" if !i
        return "invalid properties file" if line[i + 1..-1].strip.blank?
      end
    rescue
      return "invalid properties file"
    end
    return nil
  end

  def validate_version(version)
    return false unless version
    return false if version.to_i < 1
    v = latest_version.to_i
    return false unless v > 0
    return version.to_i <= v
  end

  def server_file_list(exclude_files = nil)
    return [] unless File.directory? server_files_dir_path
    file_list = Project.get_file_list(server_files_dir_path)
    return file_list unless exclude_files
    file_list.select { |f| !exclude_files.include? f }
  end

  def app_file_list(exclude_files = nil)
    return [] unless File.directory? app_files_dir_path
    file_list = Project.get_file_list(app_files_dir_path)
    return file_list unless exclude_files
    file_list.select { |f| !exclude_files.include? f }
  end

  def self.get_file_list(dir, base = '')
    list = []
    Dir.entries(dir).each do |file|
      next if file == '.' or file == '..'
      if File.directory? dir + '/' + file
        list = list.concat(Project.get_file_list(dir + '/' + file, base + file + '/'))
      else
        list.push(base + file)
      end
    end
    list.sort
  end

  def add_server_file(file, path)
    full_path = make_path(server_files_dir_path, path)
    FileUtils.cp(file.path, full_path)
  end

  def add_app_file(file, path)
    full_path = make_path(app_files_dir_path, path)
    FileUtils.cp(file.path, full_path)
  end

  def make_path(dir, path)
    FileUtils.mkdir_p dir unless File.directory? dir
    full_path = dir + '/' + File.dirname(path)
    FileUtils.mkdir_p full_path
    full_path
  end

  def server_file_archive_info(exclude_files = nil)
    file_archive_info(server_files_dir_path, server_file_list(exclude_files))
  end

  def app_file_archive_info(exclude_files = nil)
    file_archive_info(app_files_dir_path, app_file_list(exclude_files))
  end

  def file_archive_info(dir, files)
    tmp_dir = Dir.mktmpdir
    temp_file = tmp_dir + '/archive.tar.gz'

    files_str = files.map { |f| "#{f} " }.join

    TarHelper.tar('zcf', temp_file, files, dir)

    {
        :file => temp_file,
        :size => File.size(temp_file),
        :md5 => MD5Checksum.compute_checksum(temp_file)
    }
  end

  def server_file_upload(file)
    # make sure dir exists
    FileUtils.mkdir_p server_files_dir_path unless File.directory? server_files_dir_path

    TarHelper.untar('xfz', file.path, server_files_dir_path)
  end

  def app_file_upload(file)
    # make sure dir exists
    FileUtils.mkdir_p app_files_dir_path unless File.directory? app_files_dir_path

    TarHelper.untar('xfz', file.path, app_files_dir_path)

    dirty
  end

  # static

  def self.filename
    'project.tar.gz'
  end

  def self.package_name(projectkey)
    settings = JSON.parse(File.read(Project.projects_path + '/' + projectkey + '/' + Project.project_settings_name))
    settings['name'].gsub(/\s+/, '_') + '.tar.bz2'
  end

  def self.db_file_name
    'db.tar.gz'
  end

  def self.data_schema_name
    'data_schema.xml'
  end

  def self.db_name
    'db.sqlite3'
  end

  def self.ui_schema_name
    'ui_schema.xml'
  end

  def self.ui_logic_name
    'ui_logic.bsh'
  end

  def self.faims_properties_name
    'faims.properties'
  end

  def self.project_settings_name
    'project.settings'
  end

  def self.db_version_file_name(fromVersion, toVersion)
    'db_v' + fromVersion + '-' + toVersion + '.tar.gz'
  end

  def self.projects_path
    return Rails.root.to_s + '/tmp/projects' if Rails.env == 'test'
    Rails.application.config.server_projects_directory
  end

  def self.uploads_path
    return Rails.root.to_s + '/tmp/uploads' if Rails.env == 'test'
    Rails.application.config.server_uploads_directory
  end

  def self.sync_files_dir_name
    'files'
  end

  def self.server_files_dir_name
    'files/server'
  end

  def self.app_files_dir_name
    'files/app'
  end

  def self.lock_file_name
    '.lock'
  end

  def self.dirty_file_name
    '.dirty'
  end

  def self.is_locked(project_key)
    File.exist?(lock_file(project_key))
  end

  def self.lock_file(project_key)
    Project.projects_path + '/' + project_key + '/' + lock_file_name if project_key
  end

  def self.try_lock_project(project_key)
    return unless project_key
    loop do
      break unless File.exist?(lock_file(project_key))
      sleep 1
    end
    TarHelper.touch_file(lock_file(project_key))
  end

  def self.unlock_project(project_key)
    FileUtils.rm lock_file(project_key) if project_key
  end

  def self.is_dirty(project_key)
    File.exist?(dirty_file(project_key))
  end

  def self.dirty_file(project_key)
    Project.projects_path + '/' + project_key + '/' + dirty_file_name if project_key
  end

  def self.dirty(project_key)
    TarHelper.touch_file(dirty_file(project_key)) if project_key
  end

  def self.clean(project_key)
    FileUtils.rm dirty_file(project_key) if project_key
  end

  def self.package_project_for(project_key)
    # archive includes database, ui_schema.xml, ui_logic.xml, project.settings and properties files
    dir_path = projects_path + '/' + project_key + '/'
    filepath = dir_path + '/' + Project.package_name(project_key)

    begin
      tmp_dir = Dir.mktmpdir(projects_path + '/') + '/'

      # create project directory to archive
      project_dir = tmp_dir + 'project/'
      Dir.mkdir(project_dir)

      hash_sum = {}

      FileUtils.cp_r(Dir[dir_path + '*'],project_dir)

      Dir.glob(dir_path + '**/*') do |file|
        next if File.basename(file) == '.' or File.basename(file) == '..'
        next if File.basename(file) == Project.filename or File.basename(file) == Project.db_file_name
        hash_sum[File.basename(file)] = MD5Checksum.compute_checksum(file) if !File.directory?(file) and File.exists? file
      end

      File.open(project_dir + '/hash_sum', 'w') do |file|
        file.write(hash_sum.to_json)
      end

      try_lock_project(project_key)

      TarHelper.tar('jcf', filepath, File.basename(project_dir), tmp_dir, [Project.package_name(project_key), Project.filename, Project.db_file_name].select { |f| File.exists? project_dir + f })
    rescue Exception => e
      puts "Error packaging project"
      raise e
    ensure
      # cleanup
      FileUtils.rm_rf tmp_dir if File.directory? tmp_dir

      unlock_project(project_key)
    end
  end

  def self.checksum_uploaded_file(dir)
    hash_sum = JSON.parse(File.read(dir + '/hash_sum').as_json)
    Dir.glob(dir + "**/*") do |file|
      next if File.basename(file) == '.' or File.basename(file) == '..' or File.basename(file) == 'hash_sum'
      if !File.directory?(file)
        if !hash_sum[File.basename(file)].eql?(MD5Checksum.compute_checksum(file))
          return false
        end
      end
    end
    true
  end

  def self.update_archives_for(project_key, force)
    if force or Project.is_dirty(project_key)

      archive_project_for(project_key)
      archive_database_for(project_key)

      Project.clean(project_key)
    end
  end

  def self.archive_project_for(project_key)
    # archive includes database, ui_schema.xml, ui_logic.xml, project.settings and properties files
    dir_path = projects_path + '/' + project_key + '/'
    dir_name = File.basename(dir_path)
    settings = JSON.parse(File.read(dir_path + Project.project_settings_name))
    filepath = dir_path + Project.filename

    begin
      tmp_dir = Dir.mktmpdir(dir_path + '/') + '/'

      # create project directory to archive
      project_dir = tmp_dir + dir_name + '/'
      Dir.mkdir(project_dir)

      # create app database
      Database.create_app_database(project_key, dir_path + Project.db_name, project_dir + Project.db_name)

      files = [Project.ui_schema_name, Project.ui_logic_name, Project.project_settings_name,
               Project.faims_properties_name, 'faims_' + settings['name'].gsub(/\s+/, '_') + '.properties']

      # copy files to tmp directory
      files.each do |file|
        FileUtils.cp(dir_path + file, project_dir + file) if File.exists? dir_path + file
      end

      # copy server/app files to tmp directory
      FileUtils.mkdir_p project_dir + Project.sync_files_dir_name
      FileUtils.cp_r(dir_path + Project.app_files_dir_name, project_dir + Project.app_files_dir_name) if File.directory? dir_path + Project.app_files_dir_name

      try_lock_project(project_key)

      TarHelper.tar('zcf', filepath, File.basename(dir_path), tmp_dir)
    rescue Exception => e
      puts "Error archiving project"
      raise e
    ensure
      # cleanup
      FileUtils.rm_rf tmp_dir if File.directory? tmp_dir

      unlock_project(project_key)
    end
  end

  def self.archive_database_for(project_key)
    # archive includes database
    dir_path = projects_path + '/' + project_key + '/'
    db_file_path = dir_path + Project.db_file_name

    begin
      tmp_dir = Dir.mktmpdir(dir_path + '/') + '/'

      # create app database
      Database.create_app_database(project_key, dir_path + Project.db_name, tmp_dir + Project.db_name)

      try_lock_project(project_key)

      TarHelper.tar('zcf', db_file_path, File.basename(tmp_dir + Project.db_name), tmp_dir)
    rescue Exception => e
      puts "Error archiving database"
      raise e
    ensure
      # cleanup
      FileUtils.rm_rf tmp_dir if File.directory? tmp_dir

      unlock_project(project_key)
    end
  end

  def self.archive_database_version_for(project_key, version, temp_path)
     # archive includes database
    dir_path = projects_path + '/' + project_key + '/'
    db_file_path = temp_path
    begin
      tmp_dir = Dir.mktmpdir(dir_path + '/') + '/'

      # create app database
      Database.create_app_database_from_version(project_key, dir_path + Project.db_name, tmp_dir + Project.db_name, version)

      try_lock_project(project_key)

      TarHelper.tar('zcf', db_file_path, File.basename(tmp_dir + Project.db_name), tmp_dir)

      return db_file_path
    rescue Exception => e
      puts "Error archiving database"
      raise e
    ensure
      # cleanup
      FileUtils.rm_rf tmp_dir if File.directory? tmp_dir

      unlock_project(project_key)
    end

  end

  private

end

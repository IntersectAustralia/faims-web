require Rails.root.join('app/models/projects/database')

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

  after_initialize :init_file_map

  after_create :init_project

  def init_file_map
    projects_dir = Project.projects_path
    uploads_dir = Project.uploads_path
    project_dir = projects_dir + "/#{key}/"
    @file_map = {
        projects_dir: { name: 'projects', path: projects_dir },
        uploads_dir: { name: 'uploads', path: uploads_dir },
        project_dir: { name: key, path: project_dir },
        data_schema: { name: 'data_schema.xml', path: project_dir + 'data_schema.xml' },
        ui_schema: { name: 'ui_schema.xml', path: project_dir + 'ui_schema.xml' },
        ui_logic: { name: 'ui_logic.bsh', path: project_dir + 'ui_logic.bsh' },
        db: { name: 'db.sqlite3', path: project_dir + 'db.sqlite3' },
        settings: { name: 'project.settings', path: project_dir + 'project.settings' },
        properties: { name: 'faims.properties', path: project_dir + 'faims.properties' },
        project_properties: { name: "faims_#{name}.properties", path: project_dir + "faims_#{name}.properties" },
        files_dir: { name: 'files', path: project_dir + 'files/' },
        server_files_dir: { name: 'server', path: project_dir + 'files/server/' },
        app_files_dir: { name: 'app', path: project_dir + 'files/app/' },
        tmp_dir: { name: 'tmp', path: project_dir + 'tmp/' },
        package_archive: { name: "#{name}.tar.bz2", path: project_dir + "tmp/#{name}.tar.bz2" },
        project_archive: { name: 'project.tar.gz', path: project_dir + 'tmp/project.tar.gz' },
        db_archive: { name: 'db.tar.gz', path: project_dir + 'tmp/db.tar.gz' },
    }
  end

  def init_project
    FileUtils.mkdir_p @file_map[:projects_dir][:path] unless File.directory? @file_map[:projects_dir][:path]
    FileUtils.mkdir_p @file_map[:uploads_dir][:path] unless File.directory? @file_map[:uploads_dir][:path]
    FileUtils.mkdir_p @file_map[:project_dir][:path] unless File.directory? @file_map[:project_dir][:path]
    FileUtils.mkdir_p @file_map[:tmp_dir][:path] unless File.directory? @file_map[:tmp_dir][:path]
    FileUtils.mkdir_p @file_map[:server_files_dir][:path] unless File.directory? @file_map[:server_files_dir][:path]
    FileUtils.mkdir_p @file_map[:app_files_dir][:path] unless File.directory? @file_map[:app_files_dir][:path]
  end

  def name
    n = read_attribute(:name)
    n.gsub(/\s+/, '_') if n
  end

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

  def get_name(symbol)
    @file_map[symbol][:name]
  end

  def get_path(symbol)
    @file_map[symbol][:path].to_s
  end

  def has_attached_files
    true
  end

  def with_lock
    begin
      try_lock_project
      return yield
    rescue Exception => e
      raise e
    ensure
      unlock_project
    end
  end

  def archive_info
    update_archives

    info = {
        :file => get_name(:project_archive),
        :size => File.size(get_path(:project_archive)),
        :md5 => MD5Checksum.compute_checksum(get_path(:project_archive))
    }
    v = db.current_version.to_i
    info = info.merge({ :version => v.to_s }) if v > 0
    info
  end

  def db_archive_info
    update_archives

    info = {
        :file => get_name(:db_archive),
        :size => File.size(get_path(:db_archive)),
        :md5 => MD5Checksum.compute_checksum(get_path(:db_archive))
    }
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
      archive_database_version_for(version_num, temp_path) unless File.exists? temp_path
      info = {
        :file => db_version_file_name(version_num, db.current_version),
        :size => File.size(temp_path),
        :md5 => MD5Checksum.compute_checksum(temp_path)
      }
      v = db.current_version.to_i
      info = info.merge({ :version => v.to_s }) if v > 0
      info
  end

  def update_archives
    if is_dirty
      begin
        archive_project_for
        archive_database_for
      rescue Exception => e
        raise e
      ensure
        clean
      end
    end
  end

  def update_settings(params)
    File.open(get_path(:settings), 'w') do |file|
      file.write({:name => params[:project][:name],
                  :key => key,
                  :season => params[:project][:season],
                  :description => params[:project][:description],
                  :permit_no => params[:project][:permit_no],
                  :permit_holder => params[:project][:permit_holder],
                  :contact_address => params[:project][:contact_address],
                  :participant => params[:project][:participant]
                 }.to_json)
    end
  end

  def create_project_from(tmp_dir)
    begin      
      # copy files from temp directory to projects directory
      FileHelper.copy_dir(tmp_dir, get_path(:project_dir))

      # generate database
      Database.generate_database(get_path(:db), get_path(:data_schema))

      # create default faims properties
      FileHelper.touch_file(get_path(:properties))

      # generate archive
      dirty
      update_archives
    rescue Exception => e
      FileUtils.rm_rf get_path(:project_dir) if File.directory? get_path(:project_dir) # cleanup directory
      raise e
    end
  end

  def create_project_from_compressed_file(tmp_dir)
    begin
      # copy files from temp directory to projects directory
      FileHelper.copy_dir(tmp_dir, get_path(:project_dir), ['hash_sum'])

      # generate archive
      dirty
      update_archives
    rescue Exception => e
      FileUtils.rm_rf get_path(:project_dir) if File.directory? get_path(:project_dir) # cleanup directory
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
      tmp_dir = Dir.mktmpdir(get_path(:project_dir)) + '/'

      TarHelper.untar('xfz', file.path, tmp_dir)

      # add new version
      version = db.add_version(user)

      unarchived_file = tmp_dir + Dir.entries(tmp_dir).select { |f| f unless File.directory? tmp_dir + f }.first
      stored_file = "#{Project.uploads_path}/#{key}_v#{version}"

      # move file to upload directory
      FileUtils.mv(unarchived_file, stored_file)

    rescue Exception => e
      raise e

      # TODO remove added version in database if created
    ensure
      # cleanup
      FileUtils.rm_rf tmp_dir if File.directory? tmp_dir
    end

  end

  def self.validate_data_schema(schema)
    return "can't be blank" if schema.blank?
    return 'must be xml file' if schema.content_type != 'text/xml'
    begin
      file = schema.tempfile
      result = XSDValidator.validate_data_schema(file.path)
    rescue => e
      result = nil
    end
    return 'invalid xml' if result.nil? || !result.empty?
    return nil
  end

  def self.validate_ui_schema(schema)
    return "can't be blank" if schema.blank?
    return 'must be xml file' if schema.content_type != 'text/xml'
    begin
      file = schema.tempfile
      result = XSDValidator.validate_ui_schema(file.path)
    rescue => e
      result = nil
    end
    return 'invalid xml' if result.nil? || !result.empty?
    return nil
  end

  def self.validate_ui_logic(schema)
    return "can't be blank" if schema.blank?
  end

  def self.validate_arch16n(arch16n, project_name)
    return nil if arch16n.blank?
    return 'invalid file name' if !(arch16n.original_filename).eql?("faims_#{project_name.gsub(/\s+/, '_')}.properties")
    begin
      file = arch16n.tempfile
      File.open(file,'r').read.each_line do |line|
        line.strip!
        return 'invalid properties file' if line[0] == ?=
        i = line.index('=')
        return 'invalid properties file' if !i
        return 'invalid properties file' if line[i + 1..-1].strip.blank?
      end
    rescue
      return 'invalid properties file'
    end
    return nil
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

  def app_file_list(exclude_files = nil)
    return [] unless File.directory? get_path(:app_files_dir)
    file_list = FileHelper.get_file_list(get_path(:app_files_dir))
    return file_list unless exclude_files
    file_list.select { |f| !exclude_files.include? f }
  end

  def add_server_file(file, path)
    full_path = make_path(get_path(:server_files_dir), path)
    FileUtils.cp(file.path, full_path)
  end

  def add_app_file(file, path)
    full_path = make_path(get_path(:app_files_dir), path)
    FileUtils.cp(file.path, full_path)
  end

  def make_path(dir, path)
    FileUtils.mkdir_p dir unless File.directory? dir
    full_path = dir + '/' + File.dirname(path)
    FileUtils.mkdir_p full_path
    full_path
  end

  def server_file_archive_info(exclude_files = nil)
    file_archive_info(get_path(:server_files_dir), server_file_list(exclude_files))
  end

  def app_file_archive_info(exclude_files = nil)
    file_archive_info(get_path(:app_files_dir), app_file_list(exclude_files))
  end

  def file_archive_info(dir, files)
    tmp_dir = Dir.mktmpdir
    temp_file = tmp_dir + '/archive.tar.gz'

    TarHelper.tar('zcf', temp_file, files, dir)

    {
        :file => temp_file,
        :size => File.size(temp_file),
        :md5 => MD5Checksum.compute_checksum(temp_file)
    }
  end

  def server_file_upload(file)
    TarHelper.untar('xfz', file.path, get_path(:server_files_dir))
  end

  def app_file_upload(file)
    TarHelper.untar('xfz', file.path, get_path(:app_files_dir))

    dirty
  end

  # static

  def self.projects_path
    return Rails.root.to_s + '/tmp/projects' if Rails.env == 'test'
    Rails.application.config.server_projects_directory
  end

  def self.uploads_path
    return Rails.root.to_s + '/tmp/uploads' if Rails.env == 'test'
    Rails.application.config.server_uploads_directory
  end

  def self.lock_file_name
    '.lock'
  end

  def self.dirty_file_name
    '.dirty'
  end

  def is_locked
    File.exist?(lock_file)
  end

  def lock_file
    get_path(:project_dir) + '/' + Project.lock_file_name
  end

  def try_lock_project
    loop do
      break unless is_locked
      sleep 1
    end
    FileHelper.touch_file(lock_file)
  end

  def unlock_project
    FileUtils.rm lock_file if is_locked
  end

  def is_dirty
    File.exist?(dirty_file)
  end

  def dirty_file
    get_path(:project_dir) + '/' + Project.dirty_file_name
  end

  def dirty
    FileHelper.touch_file(dirty_file)
  end

  def clean
    FileUtils.rm dirty_file if is_dirty
  end

  def package_project_for
    with_lock do
      begin
        tmp_dir = Dir.mktmpdir(Project.projects_path + '/') + '/'

        # create project directory to archive
        project_dir = tmp_dir + 'project/'
        Dir.mkdir(project_dir)

        hash_sum = {}

        FileUtils.cp_r(Dir[get_path(:project_dir) + '/*'],project_dir)

        Dir.glob(get_path(:project_dir) + '/**/*') do |file|
          next if File.basename(file) == '.' or File.basename(file) == '..'
          hash_sum[File.basename(file)] = MD5Checksum.compute_checksum(file) if !File.directory?(file) and File.exists? file
        end

        File.open(project_dir + '/hash_sum', 'w') do |file|
          file.write(hash_sum.to_json)
        end

        TarHelper.tar('jcf', get_path(:package_archive), File.basename(project_dir), tmp_dir,
          [Project.lock_file_name,
           Project.dirty_file_name].select { |f| File.exists? project_dir + f })
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

  def archive_project_for
    with_lock do
      begin
        tmp_dir = Dir.mktmpdir(get_path(:project_dir)) + '/'

        # create project directory to archive
        project_dir = tmp_dir + get_name(:project_dir) + '/'
        Dir.mkdir(project_dir)

        # create app database
        db.create_app_database(project_dir + get_name(:db))

        files = [get_name(:ui_schema), get_name(:ui_logic), get_name(:settings),
                 get_name(:properties), get_name(:project_properties)]

        # copy files to tmp directory
        files.each do |file|
          FileUtils.cp(get_path(:project_dir) + '/' + file, project_dir + file) if File.exists? get_path(:project_dir) + '/' + file
        end

        # copy server/app files to tmp directory
        FileUtils.cp_r(get_path(:app_files_dir), project_dir + get_name(:app_files_dir)) if File.directory? get_path(:app_files_dir)

        TarHelper.tar('zcf', get_path(:project_archive), get_name(:project_dir), tmp_dir)
      rescue Exception => e
        raise e
      ensure
        # cleanup
        FileUtils.rm_rf tmp_dir if File.directory? tmp_dir
      end
    end
  end

  def archive_database_for
    with_lock do
      begin
        tmp_dir = Dir.mktmpdir(get_path(:project_dir)) + '/'

        # create app database
        db.create_app_database(tmp_dir + get_name(:db))

        TarHelper.tar('zcf', get_path(:db_archive), get_name(:db), tmp_dir)
      rescue Exception => e
        raise e
      ensure
        # cleanup
        FileUtils.rm_rf tmp_dir if File.directory? tmp_dir
      end
    end
  end

  def archive_database_version_for(version, temp_path)
    with_lock do
      begin
        tmp_dir = Dir.mktmpdir(get_path(:project_dir)) + '/'

        # create app database
        db.create_app_database_from_version(tmp_dir + get_name(:db), version)

        TarHelper.tar('zcf', temp_path, get_name(:db), tmp_dir)
      rescue Exception => e
        raise e
      ensure
        # cleanup
        FileUtils.rm_rf tmp_dir if File.directory? tmp_dir
      end
    end
  end

end

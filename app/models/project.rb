require Rails.root.join('app/models/projects/database')

class Project < ActiveRecord::Base
  include XSDValidator
  include Archive::Tar
  include MD5Checksum

  attr_accessor :data_schema, :ui_schema, :ui_logic, :arch16n, :season, :description, :permit_no, :permit_holder, :contact_address, :participant, :validation_schema

  attr_accessible :name, :key, :data_schema, :ui_schema, :ui_logic, :arch16n, :season, :description, :permit_no, :permit_holder, :contact_address, :participant, :vocab_id, :type,
    :validation_schema

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
    n = name.gsub(/\s+/, '_') if name
    n ||= ''
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
        project_properties: { name: "faims_#{n}.properties", path: project_dir + "faims_#{n}.properties" },
        files_dir: { name: 'files', path: project_dir + 'files/' },
        server_files_dir: { name: 'server', path: project_dir + 'files/server/' },
        app_files_dir: { name: 'app', path: project_dir + 'files/app/' },
        data_files_dir: { name: 'data', path: project_dir + 'files/data/' },
        tmp_dir: { name: 'tmp', path: project_dir + 'tmp/' },
        package_archive: { name: "#{n}.tar.bz2", path: project_dir + "tmp/#{n}.tar.bz2" },
        db_archive: { name: 'db.tar.gz', path: project_dir + 'tmp/db.tar.gz' },
        settings_archive: { name: 'settings.tar.gz', path: project_dir + 'tmp/settings.tar.gz' },
        app_files_archive: { name: 'app.tar.gz', path: project_dir + 'tmp/app.tar.gz' },
        data_files_archive: { name: 'data.tar.gz', path: project_dir + 'tmp/data.tar.gz' },
        validation_schema: { name: 'validation_schema.xml', path: project_dir + 'validation_schema' },
    }
  end

  def init_project
    FileUtils.mkdir_p @file_map[:projects_dir][:path] unless File.directory? @file_map[:projects_dir][:path]
    FileUtils.mkdir_p @file_map[:uploads_dir][:path] unless File.directory? @file_map[:uploads_dir][:path]
    FileUtils.mkdir_p @file_map[:project_dir][:path] unless File.directory? @file_map[:project_dir][:path]
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

  # project database
  def db
    Database.new(self)
  end

  # project file name and path getters
  def get_name(symbol)
    @file_map[symbol][:name]
  end

  def get_path(symbol)
    @file_map[symbol][:path].to_s
  end

  # project archives

  def db_mgr
    mgr = FileManager.new('db', get_path(:project_dir))
    mgr
  end

  def settings_mgr
    mgr = FileManager.new('settings', get_path(:project_dir))
    mgr.add_file(get_path(:ui_schema))
    mgr.add_file(get_path(:ui_logic))
    mgr.add_file(get_path(:settings))
    mgr.add_file(get_path(:properties))
    mgr.add_file(get_path(:project_properties))
    mgr
  end

  def app_mgr
    mgr = FileManager.new('app', get_path(:project_dir))
    mgr.add_dir(get_path(:app_files_dir))
    mgr
  end

  def data_mgr
    mgr = FileManager.new('data', get_path(:project_dir))
    mgr.add_dir(get_path(:data_files_dir))
    mgr
  end

  def package_mgr
    mgr = FileManager.new('project', get_path(:project_dir))
    mgr
  end

  def has_attached_files
    FileHelper.get_file_list(get_path(:server_files_dir)).size > 0 or
        FileHelper.get_file_list(get_path(:app_files_dir)).size > 0
  end

  def settings_archive_info
    settings_mgr.update_archive('zcf', get_path(:settings_archive))

    info = {
        :file => get_path(:settings_archive),
        :size => File.size(get_path(:settings_archive)),
        :md5 => MD5Checksum.compute_checksum(get_path(:settings_archive))
    }
    v = db.current_version.to_i
    info = info.merge({ :version => v.to_s }) if v > 0
    info
  end

  def db_archive_info
    db_mgr.update_archive('zcf', get_path(:db_archive))

    info = {
        :file => get_path(:db_archive),
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

  def android_archives_dirty?
    settings_mgr.dirty? or db_mgr.dirty? or app_mgr.dirty? or data_mgr.dirty?
  end

  def update_android_archives
    settings_mgr.update_archive('zcf', get_path(:settings_archive))
    app_mgr.update_archive('zcf', get_path(:app_files_archive))
    data_mgr.update_archive('zcf', get_path(:data_files_archive))
    archive_database
  end

  def generate_archives
    db_mgr.make_dirt
    settings_mgr.make_dirt
    app_mgr.make_dirt
    data_mgr.make_dirt
    package_mgr.make_dirt
    update_archives
  end

  def update_archives
    #db_mgr.update_archive('zcf', get_path(:db_archive))
    settings_mgr.update_archive('zcf', get_path(:settings_archive))
    app_mgr.update_archive('zcf', get_path(:app_files_archive))
    data_mgr.update_archive('zcf', get_path(:data_files_archive))
    #package_mgr.update_archive('zcf', get_path(:package_archive))

    # TODO create db file manager for archiving database
    archive_database

    # TODO create package file manager for archiving package
    package_project
  end

  def update_settings(params)
    settings_mgr.with_lock do
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
        settings_mgr.make_dirt
      end
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
      generate_archives
    rescue Exception => e
      raise e
      FileUtils.rm_rf get_path(:project_dir) if File.directory? get_path(:project_dir) # cleanup directory
    ensure
      # ignore
    end
  end

  def create_project_from_compressed_file(tmp_dir)
    begin
      # copy files from temp directory to projects directory
      FileHelper.copy_dir(tmp_dir, get_path(:project_dir), ['hash_sum'])

      # generate archive
      generate_archives
    rescue Exception => e
      raise e
      FileUtils.rm_rf get_path(:project_dir) if File.directory? get_path(:project_dir) # cleanup directory
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

  def self.validate_validation_schema(schema)
    return "can't be blank" if schema.blank?
    return 'must be xml file' if schema.content_type != 'text/xml'
    begin
      file = schema.tempfile
      result = XSDValidator.validate_validation_schema(file.path)
    rescue => e
      result = nil
    end
    return 'invalid xml' if result.nil? || !result.empty?
    return nil
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
      app_mgr.update_archive('zcf', get_path(:app_files_archive))

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

  # NOTE this function behaves differently to add_app_file
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

  def data_file_archive_info(exclude_files = nil)
    if exclude_files
      data_mgr.with_lock do
        file_archive_info(get_path(:data_files_dir), non_locking_data_file_list(exclude_files))
      end
    else
      data_mgr.update_archive('zcf', get_path(:data_files_archive))

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

  def self.projects_path
    return Rails.root.to_s + '/tmp/projects' if Rails.env == 'test'
    Rails.application.config.server_projects_directory
  end

  def self.uploads_path
    return Rails.root.to_s + '/tmp/uploads' if Rails.env == 'test'
    Rails.application.config.server_uploads_directory
  end

  def package_project
    package_mgr.with_lock do
      begin
        tmp_dir = Dir.mktmpdir + '/'

        # create project directory to archive
        project_dir = tmp_dir + 'project/'
        Dir.mkdir(project_dir)

        hash_sum = {}

        FileHelper.get_file_list(get_path(:project_dir)).each do |file|
          next if File.basename(file) =~ /^(\.)/ # ignore dot files
          next if File.dirname(file) =~ /^(#{get_name(:tmp_dir)})/ # ignore tmp directory
          hash_sum[file] = MD5Checksum.compute_checksum(get_path(:project_dir) + file)
          FileUtils.mkdir_p project_dir + File.dirname(file)
          FileUtils.cp get_path(:project_dir) + file, project_dir + file
        end

        File.open(project_dir + '/hash_sum', 'w') do |file|
          file.write(hash_sum.to_json)
        end

        TarHelper.tar('jcf', get_path(:package_archive), File.basename(project_dir), tmp_dir)
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

        TarHelper.tar('zcf', get_path(:db_archive), get_name(:db), tmp_dir)
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

        TarHelper.tar('zcf', temp_path, get_name(:db), tmp_dir)
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

  def self.upload_project(params)
    tmp_dir = nil
    begin
      tar_file = params[:project][:project_file]
      if !(tar_file.content_type =~ /bzip/)
        return 'Unsupported format of file, please upload the correct file'
      else
        tmp_dir = Dir.mktmpdir + '/'
        `tar xjf #{tar_file.tempfile.to_path.to_s} -C #{tmp_dir}`
        project_settings = JSON.parse(File.read(tmp_dir + 'project/project.settings').as_json)
        if !Project.checksum_uploaded_file(tmp_dir + 'project/')
          return 'Wrong hash sum for the project'  
        elsif !Project.find_by_key(project_settings['key']).blank?
          return 'This project already exists in the system'
        else
          project = Project.new(:name => project_settings['name'], :key => project_settings['key'])
          project.transaction do
            project.save
            project.create_project_from_compressed_file(tmp_dir + 'project')
          end
          return project
        end
      end
    rescue Exception
      return 'Uploaded project file is corrupted'
    ensure
      FileUtils.rm_rf tmp_dir if tmp_dir
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
    FileUtils.rm_rf tmp_dir if tmp_dir and File.directory? tmp_dir
  end

end

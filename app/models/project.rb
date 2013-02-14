class Project < ActiveRecord::Base
  include XSDValidator
  include DatabaseGenerator
  include Archive::Tar

  attr_accessible :name, :key, :data_schema, :ui_schema, :ui_logic, :arch16n

  validates :name, :presence => true, :uniqueness => true, :length => {:maximum => 255},
            :format => {:with => /^(\s*[^\/\\\?\%\*\:\|\"\'\<\>\.]+\s*)*$/i} # do not allow file name reserved characters

  validates :key, :presence => true, :uniqueness => true

  default_scope order(:name)

  def name=(value)
    write_attribute(:name, value.strip.squish) if value
  end

  def data_schema
  end

  def data_schema=(value)
  end

  def ui_schema
  end

  def ui_schema=(value)
  end

  def ui_logic
  end

  def ui_logic=(value)
  end

  def arch16n
  end

  def arch16n=(value)
  end

  def projects_path
    return Rails.root.to_s + '/tmp/projects' if Rails.env = 'test'
    Rails.application.config.server_projects_directory
  end

  def uploads_path
    return Rails.root.to_s + '/tmp/uploads' if Rails.env = 'test'
    Rails.application.config.server_uploads_directory
  end

  def dir_name
    name.gsub(/\s/, '_') if name
  end

  def dir_path
    projects_path + '/' + dir_name
  end

  def filename
    'project.tar.gz'
  end

  def filepath
    dir_path + '/' + filename
  end

  def db_file_name
    'db.tar.gz'
  end

  def db_file_path
    dir_path + '/' + db_file_name
  end

  def data_schema_name
    'data_schema.xml'
  end

  def data_schema_path
    dir_path + '/' + data_schema_name
  end

  def db_name
    'db.sqlite3'
  end

  def db_path
    dir_path + '/' + db_name
  end

  def ui_schema_name
    'ui_schema.xml'
  end

  def ui_schema_path
    dir_path + '/' + ui_schema_name
  end

  def ui_logic_name
    'ui_logic.bsh'
  end

  def ui_logic_path
    dir_path + '/' + ui_logic_name
  end

  def faims_properties_name
    'faims.properties'
  end

  def faims_properties_path
    dir_path + '/' + faims_properties_name
  end

  def faims_project_properties_name
    'faims_' + name.gsub(/\s+/, '_') + '.properties'
  end

  def faims_project_properties_path
    dir_path + '/' + faims_project_properties_name
  end

  def project_settings_name
    'project.settings'
  end

  def project_settings_path
    dir_path + '/' + project_settings_name
  end

  def archive
    # archive includes database, ui_schema.xml, ui_logic.xml, project.settings and properties files
    begin
      tmp_dir = Dir.mktmpdir(dir_path + '/') + '/'

      # create project directory to archive
      dir = tmp_dir + dir_name + '/'
      Dir.mkdir(dir)

      # create app database
      db_file = dir + 'db.sqlite3'
      DatabaseGenerator.create_app_database(db_path, db_file)

      # copy files to tmp directory
      FileUtils.cp(ui_schema_path, dir + ui_schema_name)
      FileUtils.cp(ui_logic_path, dir + ui_logic_name)
      FileUtils.cp(project_settings_path, dir + project_settings_name)
      FileUtils.cp(faims_properties_path, dir + faims_properties_name)
      FileUtils.cp(faims_project_properties_path, dir + faims_project_properties_name) if
          File.exists? faims_project_properties_path

      # archive project
      #tgz = Zlib::GzipWriter.new(File.open(filepath, 'wb'), Zlib::BEST_COMPRESSION, Zlib::DEFAULT_STRATEGY)
      #Minitar.pack(tmp_dir, tgz)

      # TODO currently minitar doesn't have directory change option
      `tar zcf #{filepath} -C #{tmp_dir} #{File.basename(dir)}`
    rescue Exception => e
      puts "Error archiving project"
      raise e
    ensure
      # cleanup
      FileUtils.rm_rf tmp_dir if File.directory? tmp_dir
    end
  end

  def archive_info
    {
        :file => filename,
        :size => File.size(filepath),
        :md5 => Digest::MD5.hexdigest(File.read(filepath))
    }
  end

  def archive_db
    # archive includes database
    begin
      tmp_dir = Dir.mktmpdir(dir_path + '/') + '/'

      # create app database
      db_file = tmp_dir + 'db.sqlite3'
      DatabaseGenerator.create_app_database(db_path, db_file)

      # archive database
      #tgz = Zlib::GzipWriter.new(File.open(db_file_path, 'wb'), Zlib::BEST_COMPRESSION, Zlib::DEFAULT_STRATEGY)
      #Minitar.pack(db_file, tgz)

      # TODO currently minitar doesn't have directory change option
      `tar zcf #{db_file_path} -C #{tmp_dir} #{File.basename(db_file)}`
    rescue Exception => e
      puts "Error archiving project"
      raise e
    ensure
      # cleanup
      FileUtils.rm_rf tmp_dir if File.directory? tmp_dir
    end
  end

  def archive_db_info
    {
        :file => db_file_name,
        :size => File.size(db_file_path),
        :md5 => Digest::MD5.hexdigest(File.read(db_file_path))
    }
  end

  def update_archives
    archive
    archive_db
  end

  def create_project_from(tmp_dir)
    begin
      Dir.mkdir(projects_path) unless File.directory? projects_path # make sure projects directory exists

      FileUtils.rm_rf dir_path if File.directory? dir_path # overwrite current project directory
      Dir.mkdir(dir_path)

      # copy files from temp directory to projects directory
      Dir.entries(tmp_dir).each { |f| FileUtils.cp(tmp_dir + '/' + f, dir_path + '/') unless File.directory? f }

      # generate database
      DatabaseGenerator.generate_database(dir_path + "/db.sqlite3", dir_path + "/data_schema.xml")

      # create project settings
      File.open(dir_path + "/project.settings", 'w') do |file|
        file.write({:name => name, key:key}.to_json)
      end

      # create default faims properties
      File.open(dir_path + "/faims.properties", 'w') do |file|
        file.write("")
      end

      # generate archive
      update_archives
    rescue Exception => e
      puts "Error creating project"
      FileUtils.rm_rf dir_path if File.directory? dir_path # cleanup directory
      raise e
    end
  end

  def check_sum(db_file,md5)
    current_md5 = Digest::MD5.hexdigest(db_file.read)
    return true if current_md5 == md5
    return false
  end

  def store_database(file, user)
    begin
      tmp_dir = Dir.mktmpdir(dir_path + '/') + '/'

      # unarchive database
      #tgz = Zlib::GzipReader.new(File.open(file, 'rb'))
      #Minitar.unpack(tgz, tmp_dir)

      # TODO minitar doesn't have directory change option
      `tar zxf #{file.path} -C #{tmp_dir}`

      version = DatabaseGenerator.execute_query(db_path, "select max(versionnum) from version;").first.first
      version ||= 0

      # move file to upload directory
      unarchived_file = tmp_dir + Dir.entries(tmp_dir).select { |f| f unless File.directory? tmp_dir + f }.first
      stored_file = "#{uploads_path}/#{key}_#{version}_#{user}.sqlite3"

      # create upload directory if it doesn't exist
      Dir.mkdir(uploads_path) unless File.directory? uploads_path

      FileUtils.mv(unarchived_file, stored_file)
    rescue Exception => e
      puts "Error merging database"
      raise e
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
  private

end

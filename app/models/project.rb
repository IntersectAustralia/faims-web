class Project < ActiveRecord::Base
  include XSDValidator
  include DatabaseGenerator
  include Archive::Tar

  attr_accessible :name, :key, :data_schema, :ui_schema, :ui_logic, :arch16n, :season, :description, :permit_no, :permit_holder, :contact_address, :participant

  validates :name, :presence => true, :length => {:maximum => 255},
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

  def season
  end

  def season=(value)
  end

  def description
  end

  def description=(value)
  end

  def permit_no
  end

  def permit_no=(value)
  end

  def permit_holder
  end

  def permit_holder=(value)
  end

  def contact_address
  end

  def contact_address=(value)
  end

  def participant
  end

  def participant=(value)
  end

  def ui_logic
  end

  def ui_logic=(value)
  end

  def arch16n
  end

  def arch16n=(value)
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

  def project_setting
    File.read(dir_path + '/' + Project.project_settings_name)
  end

  def archive_info
    info = {
        :file => Project.filename,
        :size => File.size(filepath),
        :md5 => Digest::MD5.hexdigest(File.read(filepath))
    }
    version = DatabaseGenerator.current_version(db_path)
    info = info.merge({ :version => version.first, :timestamp => version.second }) if version
    info
  end

  def archive_db_info
    info = {
        :file => Project.db_file_name,
        :size => File.size(db_file_path),
        :md5 => Digest::MD5.hexdigest(File.read(db_file_path))
    }
    version = DatabaseGenerator.current_version(db_path)
    info = info.merge({ :version => version.first, :timestamp => version.second }) if version
    info
  end

  def update_archives
    Project.update_archives_for(key)
  end

  def create_project_from(tmp_dir)

    begin
      Dir.mkdir(Project.projects_path) unless File.directory? Project.projects_path # make sure projects directory exists

      FileUtils.rm_rf dir_path if File.directory? dir_path # overwrite current project directory
      Dir.mkdir(dir_path)

      # copy files from temp directory to projects directory
      Dir.entries(tmp_dir).each { |f| FileUtils.cp(tmp_dir + '/' + f, dir_path + '/') unless File.directory? f }

      # generate database
      DatabaseGenerator.generate_database(dir_path + "/db.sqlite3", dir_path + "/data_schema.xml")

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

      # TODO minitar doesn't have directory change option
      `tar zxf #{file.path} -C #{tmp_dir}`

      # add new version
      version = DatabaseGenerator.add_version(db_path, user)

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

  # static

  def self.filename
    'project.tar.gz'
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

  def self.projects_path
    return Rails.root.to_s + '/tmp/projects' if Rails.env == 'test'
    Rails.application.config.server_projects_directory
  end

  def self.uploads_path
    return Rails.root.to_s + '/tmp/uploads' if Rails.env == 'test'
    Rails.application.config.server_uploads_directory
  end

  def self.update_archives_for(project_key)
    archive_project_for(project_key)
    archive_database_for(project_key)
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
      DatabaseGenerator.create_app_database(dir_path + Project.db_name, project_dir + Project.db_name)

      files = [Project.ui_schema_name, Project.ui_logic_name, Project.project_settings_name,
               Project.faims_properties_name, 'faims_' + settings['name'].gsub(/\s+/, '_') + '.properties']

      # copy files to tmp directory
      files.each do |file|
        FileUtils.cp(dir_path + file, project_dir + file) if File.exists? dir_path + file
      end

      # TODO currently minitar doesn't have directory change option
      `tar zcf #{filepath} -C #{tmp_dir} #{File.basename(dir_path)}`
    rescue Exception => e
      puts "Error archiving project"
      raise e
    ensure
      # cleanup
      FileUtils.rm_rf tmp_dir if File.directory? tmp_dir
    end
  end

  def self.archive_database_for(project_key)
    # archive includes database
    dir_path = projects_path + '/' + project_key + '/'
    db_file_path = dir_path + Project.db_file_name

    begin
      tmp_dir = Dir.mktmpdir(dir_path + '/') + '/'

      # create app database
      DatabaseGenerator.create_app_database(dir_path + Project.db_name, tmp_dir + Project.db_name)

      # TODO currently minitar doesn't have directory change option
      `tar zcf #{db_file_path} -C #{tmp_dir} #{File.basename(tmp_dir + Project.db_name)}`
    rescue Exception => e
      puts "Error archiving project"
      raise e
    ensure
      # cleanup
      FileUtils.rm_rf tmp_dir if File.directory? tmp_dir
    end
  end

  private

end

class Project < ActiveRecord::Base
  include XSDValidator
  include DatabaseGenerator

  attr_accessible :name, :data_schema, :ui_schema, :ui_logic, :arch16n

  validates :name, :presence => true, :uniqueness => true, :length => {:maximum => 255},
            :format => {:with => /^(\s*[^\/\\\?\%\*\:\|\"\'\<\>\.]+\s*)*$/i} # do not allow file name reserved characters

  before_validation :update_project

  default_scope order(:name)

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

  def dirname
    name.gsub(/\s/, '_') if name
  end

  def dirpath
    Rails.root.join(projects_dir, name.gsub(/\s/, '_')).to_s if name
  end

  def filename
    name.gsub(/\s/, '_') + '.tar.gz'
  end

  def filepath
    dirpath + '.tar.gz'
  end

  def projects_dir
    Rails.env == 'test' ? 'tmp/projects' : 'projects'
  end

  def projects_path
    Rails.root.join(projects_dir).to_s
  end

  def archive
    `tar zcf #{filepath} -C #{projects_path} #{dirname}` # todo: find purely ruby method
  end

  def archive_info
    {
        :file => filename,
        :size => File.size(filepath),
        :md5 => Digest::MD5.hexdigest(File.read(filepath))
    }
  end

  def create_project_from(tmpdir)
    begin
      Dir.mkdir(projects_path) unless File.directory? projects_path # make sure directory exists

      FileUtils.rm_rf dirpath if File.directory? dirpath # remove directory if one already exists
      FileUtils.rm_rf filepath if File.exists? filepath # remove archive if one already exists

      Dir.mkdir(dirpath)

      # copy files into directory
      FileUtils.cp(tmpdir + "/data_schema.xml", dirpath + "/data_schema.xml") #temporary
      FileUtils.cp(tmpdir + "/ui_schema.xml", dirpath + "/ui_schema.xml")
      FileUtils.cp(tmpdir + "/ui_logic.bsh", dirpath + "/ui_logic.bsh")
      FileUtils.cp(tmpdir + "/faims.properties", dirpath + "/faims_"+ name.gsub(/\s/, '') +".properties")
      DatabaseGenerator.generate_database(dirpath + "/db.sqlite3", dirpath + "/data_schema.xml")
      File.open(dirpath + "/project.settings", 'w') do |file|
        file.write({:project => name}.to_json)
      end

      # generate archive
      archive #Todo: this will need to be called each time the database or settings are updated
    rescue Exception => e
      puts "Error copying files"
      FileUtils.rm_rf dirpath if File.directory? dirpath # cleanup directory
      FileUtils.rm filepath if filepath and File.exists? filepath # cleanup archive
      raise e
    end
  end

  def self.validate_data_schema(schema)
    return "can't be blank" if schema.blank?
    return "must be xml file" if schema.content_type != "text/xml"
    begin
      file = create_temp_file(schema)
      result = XSDValidator.validate_data_schema(file.path)
      file.unlink
    rescue
      logger.error "Exception validating data schema"
      logger.error $!.backtrace
      result = nil
    end
    return "invalid xml" if result.nil? || !result.empty?
    return nil
  end

  def self.validate_ui_schema(schema)
    return "can't be blank" if schema.blank?
    return "must be xml file" if schema.content_type != "text/xml"
    begin
      logger.debug "Validating UI Schema"
      file = create_temp_file(schema)
      result = XSDValidator.validate_ui_schema(file.path)
      logger.debug "Results = #{result}"
      file.unlink
    rescue => e
      logger.error "Exception validating ui schema #{e}"
      result = nil
    end
    return "invalid xml" if result.nil? || !result.empty?
    return nil
  end

  def self.validate_arch16n(arch16n)
    return "can't be blank" if arch16n.blank?
    begin
      logger.debug "Validating arch16n"
      file = create_temp_file(arch16n)
      File.open(file,'r').read.each_line do |line|
        line.strip!
        return "invalid properties file" if line[0] == ?=
        i = line.index('=');
        return "invalid properties file" if !i
        return "invalid properties file" if line[i + 1..-1].strip.blank?
      end
    rescue
      logger.error "Exception validating properties file"
      return "invalid properties file"
    end
    return nil
  end
  private

  def update_project
    name.squish! if name
    name.strip! if name
  end

  def self.create_temp_file(schema)
    file = Tempfile.new('schema')
    file.binmode
    file.write(schema.read)
    file.close
    file
  end

end

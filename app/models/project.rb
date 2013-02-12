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
    dirname + '.tar.gz'
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

  def dbname
    dirname + '_db.tar.gz'
  end

  def dbpath
    dirpath + '_db.tar.gz'
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

  def archive_db
    `tar zcf #{dbpath} -C #{dirpath} db.sqlite3` # todo: find purely ruby method
  end

  def archive_db_info
    {
        :file => dbname,
        :size => File.size(dbpath),
        :md5 => Digest::MD5.hexdigest(File.read(dbpath))
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
      if File.exist?(tmpdir + "/faims_"+name.gsub(/\s/, '_')+".properties")
        FileUtils.cp(tmpdir + "/faims_"+name.gsub(/\s/, '_')+".properties", dirpath + "/faims_"+ name.gsub(/\s/, '_') +".properties")
      end
      FileUtils.cp(File.expand_path("../../../lib/assets/faims.properties", __FILE__), dirpath + "/faims.properties")
      DatabaseGenerator.generate_database(dirpath + "/db.sqlite3", dirpath + "/data_schema.xml")
      File.open(dirpath + "/project.settings", 'w') do |file|
        file.write({:name => name, id:id}.to_json)
      end

      # generate archive
      archive #Todo: this will need to be called each time the database or settings are updated
      archive_db
    rescue Exception => e
      puts "Error copying files"
      FileUtils.rm_rf dirpath if File.directory? dirpath # cleanup directory
      FileUtils.rm filepath if filepath and File.exists? filepath # cleanup archive
      raise e
    end
  end

  def check_sum(db_file,md5)
    current_md5 = Digest::MD5.hexdigest(db_file.read)
    return true if current_md5 == md5
    return false
  end

  def merge_database(file)
    tmp_dir = Dir.mktmpdir(dirpath + '/') + '/'
    # create tmp dir
    FileUtils.rm_rf tmp_dir if File.directory? tmp_dir
    FileUtils.mkdir tmp_dir
    # untar database into tmp dir
    `tar xfz #{file.path} -C #{tmp_dir}`
    # merge database
    file = Dir.entries(tmp_dir)[2]
    DatabaseGenerator.merge_database(dirpath + "/db.sqlite3", tmp_dir + file)
    # cleanup
    FileUtils.rm_rf tmp_dir if File.directory? tmp_dir
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
        i = line.index('=');
        return "invalid properties file" if !i
        return "invalid properties file" if line[i + 1..-1].strip.blank?
      end
    rescue
      return "invalid properties file"
    end
    return nil
  end
  private

  def update_project
    name.squish! if name
    name.strip! if name
  end

  def self.create_temp_file(file)
    file = Tempfile.new('temp_file')
    file.binmode
    file.write(file.read)
    file.close
    file
  end

end

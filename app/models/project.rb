class Project < ActiveRecord::Base
  include XSDValidator
  include DatabaseGenerator

  attr_accessible :name, :data_schema, :ui_schema

  validates :name, :presence => true, :uniqueness => true, :length => { :maximum => 255 },
            :format => { :with => /^(\s*[^\/\\\?\%\*\:\|\"\'\<\>\.]+\s*)*$/i } # do not allow file name reserved characters

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

  def filename
    name.gsub(/\s/, '_') if name
  end

  def archive
    file = Rails.root.join(projects_dir).to_s + "/" + filename + ".tar.gz"
    `tar zcf #{file} -C #{Rails.root.join(projects_dir).to_s} #{filename}` # todo: find purely ruby method
  end

  def archive_info
    file = Rails.root.join(projects_dir).to_s + "/" + filename + ".tar.gz"
    {
        :file => filename + ".tar.gz",
        :size => File.size(file),
        :md5 => Digest::MD5.hexdigest(File.read(file))
    }
  end

  def create_project_from(tmpdir)
    begin 
      Dir.mkdir(Rails.root.join(projects_dir)) unless 
        File.directory? Rails.root.join(projects_dir) # make sure directory exists

      dir_name = Rails.root.join(projects_dir, filename).to_s
      archive_name = Rails.root.join(projects_dir).to_s + "/" + filename + ".tar.gz"

      FileUtils.rm_rf dir_name if 
        File.directory? dir_name # remove directory if one already exists
      FileUtils.rm archive_name if 
        File.exists? archive_name # remove archive if one already exists

      Dir.mkdir(dir_name)

      # copy files into directory
      FileUtils.mv(tmpdir + "/data_schema.xml", dir_name + "/data_schema.xml") #temporary
      FileUtils.mv(tmpdir + "/ui_schema.xml", dir_name + "/ui_schema.xml")
      DatabaseGenerator.generate_database(dir_name + "/db.sqlite3", dir_name + "/data_schema.xml")
      File.open(dir_name + "/project.settings", 'w') do |file|
        file.write({:project => name}.to_json)
      end

      # generate archive
      archive #Todo: this will need to be called each time the database or settings are updated
    rescue Exception => e
      FileUtils.rm_rf dir_name if 
        File.directory? dir_name # cleanup directory
        FileUtils.rm archive_name if archive_name and File.exists? archive_name
      raise e
    end
  end

  def self.validate_data_schema(schema)
    return "can't be blank" if schema.blank?
    return "must be xml file" if schema.content_type != "text/xml"
    file = create_temp_schema(schema)
    result = XSDValidator.validate_data_schema(file.path)
    file.unlink
    return "invalid xml" unless result.empty?
    return nil
  end

  def self.validate_ui_schema(schema)
    return "can't be blank" if schema.blank?
    return "must be xml file" if schema.content_type != "text/xml"
    file = create_temp_schema(schema)
    result = XSDValidator.validate_ui_schema(file.path)
    file.unlink
    return "invalid xml" unless result.empty?
    return nil
  end

  private

    def update_project
      name.squish! if name
      name.strip! if name
    end

    def projects_dir
      Rails.env == 'test' ? 'tmp/projects' : 'projects'
    end

    def self.create_temp_schema(schema)
      file = Tempfile.new('schema')
      file.write(schema.read)
      file.close
      file
    end

end

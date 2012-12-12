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

  def create_project_from(tmpdir)
    setup_projects_dir
    dir_name = Rails.root.join(projects_dir, name).to_s
    FileUtils.rm_rf dir_name if File.directory? dir_name
    Dir.mkdir(dir_name)
    FileUtils.mv(tmpdir + "/data_schema.xml", dir_name + "/data_schema.xml") #temporary
    FileUtils.mv(tmpdir + "/ui_schema.xml", dir_name + "/ui_schema.xml")
    DatabaseGenerator.generate_database(dir_name + "/db.sqlite3",dir_name + "/data_schema.xml")
    File.open(dir_name + "/project.settings", 'w') do |file|
      file.write({:project => name}.to_json)
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

    def setup_projects_dir
      Dir.mkdir(Rails.root.join('tmp')) unless File.directory? Rails.root.join('tmp')
      Dir.mkdir(Rails.root.join(projects_dir)) unless File.directory? Rails.root.join(projects_dir) # make sure directory existsq
    end

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

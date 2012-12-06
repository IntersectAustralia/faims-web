class Project < ActiveRecord::Base

  attr_accessible :name, :data_schema, :ui_schema

  validates :name, :presence => true, :uniqueness => true

  before_validation :update_project

  def data_schema
  end

  def data_schema=(value)
  end

  def ui_schema
  end

  def ui_schema=(value)
  end

  def create_project_from(tmpdir)
    dir_name = Rails.root.join(projects_dir, name).to_s
    Dir.mkdir(dir_name)
    FileUtils.mv(tmpdir + "/data_schema.xml", dir_name + "/data_schema.xml")
    FileUtils.mv(tmpdir + "/ui_schema.xml", dir_name + "/ui_schema.xml")
  end

  def self.validate_data_schema(schema)
    return "can't be blank" if schema.blank?
    return "must be xml file" if schema.content_type != "text/xml"
    # TODO: validate data schema against xsd
    return nil
  end

  def self.validate_ui_schema(schema)
    return "can't be blank" if schema.blank?
    return "must be xml file" if schema.content_type != "text/xml"
    # TODO: validate ui schema against xsd
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

end

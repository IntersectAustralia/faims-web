class Project < ActiveRecord::Base

  attr_accessible :name, :data_schema, :ui_schema

  validates :name, :presence => true, :uniqueness => true

  def data_schema
  end

  def data_schema=(value)
  end

  def ui_schema
  end

  def ui_schema=(value)
  end

end

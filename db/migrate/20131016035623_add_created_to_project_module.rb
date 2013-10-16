class AddCreatedToProjectModule < ActiveRecord::Migration
  def change
    add_column :project_modules, :created, :boolean
  end
end

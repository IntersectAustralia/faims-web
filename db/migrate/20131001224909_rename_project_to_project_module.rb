class RenameProjectToProjectModule < ActiveRecord::Migration
  def up
    rename_table :projects, :project_modules
  end

  def down
    rename_table :project_modules, :projects
  end
end

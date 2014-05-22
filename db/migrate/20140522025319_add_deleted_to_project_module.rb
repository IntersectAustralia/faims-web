class AddDeletedToProjectModule < ActiveRecord::Migration
  def change
    add_column :project_modules, :deleted, :boolean
  end
end

class AddKeyToProjectsTable < ActiveRecord::Migration
  def change
    add_column :projects, :key, :string
  end
end

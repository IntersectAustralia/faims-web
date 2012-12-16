require File.dirname(__FILE__) + '/../database_generator.rb'
include DatabaseGenerator

def create_projects(size)
  count = 0
  while (count < size) do
    count = count + 1
    p = Project.create(:name => "Project #{count}")
    
    FileUtils.rm_rf p.dirpath if File.directory? p.dirpath
    Dir.mkdir p.projects_path unless File.directory? p.projects_path
    Dir.mkdir p.dirpath

    `cp #{Rails.root.join('features', 'assets', 'data_schema.xml')} #{p.dirpath}`
    `cp #{Rails.root.join('features', 'assets', 'ui_schema.xml')} #{p.dirpath}`

    `touch #{p.dirpath + "/project.settings"}`

    DatabaseGenerator.generate_database(p.dirpath + '/db.sqlite3', p.dirpath + '/data_schema.xml')
    
    p.archive # create archive file

    puts "Created project #{p.name}"
  end
end


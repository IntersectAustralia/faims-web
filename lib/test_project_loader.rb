include DatabaseGenerator

def create(size)

  count = 0
  while (count < size) do
    count = count + 1
    p = Project.create(:name => "Project #{count} Site")
    
    FileUtils.rm_rf p.dirpath if File.directory? p.dirpath

    Dir.mkdir p.dirpath

    `cp #{Rails.root.join('features', 'assets', 'data_schema.xml')} #{p.dirpath}`
    `cp #{Rails.root.join('features', 'assets', 'ui_schema.xml')} #{p.dirpath}`

    `touch #{p.dirpath + "/project.settings"}`

    DatabaseGenerator.generate_database(p.dirpath + '/db.sqlite3', p.dirpath + '/data_schema.xml')
    
    p.archive

  end
end

if ARGV[0]
  create(ARGV[0])
else
  create(100)
end


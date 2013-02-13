def make_project(name)
  p = Project.create(:name => name, :key => SecureRandom.uuid)
  p.create_project_from(Rails.root.join('features', 'assets').to_s)
  p.archive
end

def is_valid_settings_file(filename)
  JSON.parse(File.read(filename))["id"].should =~ /^\S{8}-\S{4}-\S{4}-\S{4}-\S{12}$/
end
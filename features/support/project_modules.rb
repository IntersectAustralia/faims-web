def make_project_module(name)
  begin
    project_module = ProjectModule.create(:name => name, :key => SecureRandom.uuid, :created => true)
    FileUtils.cp_r(Dir[Rails.root.join("features/assets/#{project_module.name.downcase.gsub(/\s/,'_')}/*")], Rails.root.join("tmp/modules/#{project_module.key}"))
    project_module.generate_temp_files
    project_module
  rescue Exception => e
    raise e
  end
end

def is_valid_settings_file(filename)
  JSON.parse(File.read(filename))['key'].should =~ /^\S{8}-\S{4}-\S{4}-\S{4}-\S{12}$/
end
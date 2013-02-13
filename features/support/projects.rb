def make_project(name)
  begin
    tmp_dir = Dir.mktmpdir(Rails.root.to_s + '/tmp/')
    assets_dir = Rails.root.to_s + '/features/assets/'
    FileUtils.cp(assets_dir + 'data_schema.xml', tmp_dir + '/data_schema.xml' )
    FileUtils.cp(assets_dir + 'ui_schema.xml', tmp_dir + '/ui_schema.xml' )
    FileUtils.cp(assets_dir + 'ui_logic.bsh', tmp_dir + '/ui_logic.bsh' )
    p = Project.create(:name => name, :key => SecureRandom.uuid)
    p.create_project_from(tmp_dir)
    p
  rescue Exception => e
    raise e
  ensure
    FileUtils.rm_rf tmp_dir if File.directory? tmp_dir
  end
end

def is_valid_settings_file(filename)
  JSON.parse(File.read(filename))["id"].should =~ /^\S{8}-\S{4}-\S{4}-\S{4}-\S{12}$/
end
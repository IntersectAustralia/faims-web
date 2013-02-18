def make_project(name)
  begin
    tmp_dir = Dir.mktmpdir(Rails.root.to_s + '/tmp/')
    assets_dir = Rails.root.to_s + '/features/assets/'
    FileUtils.cp(assets_dir + 'data_schema.xml', tmp_dir + '/data_schema.xml' )
    FileUtils.cp(assets_dir + 'ui_schema.xml', tmp_dir + '/ui_schema.xml' )
    FileUtils.cp(assets_dir + 'ui_logic.bsh', tmp_dir + '/ui_logic.bsh' )
    FileUtils.cp(assets_dir + 'project.settings', tmp_dir + '/project.settings' )
    project = Project.create(:name => name, :key => SecureRandom.uuid)
    project.create_project_from(tmp_dir)
    project
  rescue Exception => e
    raise e
  ensure
    FileUtils.rm_rf tmp_dir if File.directory? tmp_dir
  end
end

def is_valid_settings_file(filename)
  JSON.parse(File.read(filename))["key"].should =~ /^\S{8}-\S{4}-\S{4}-\S{4}-\S{12}$/
end

def md5(file)
  Digest::MD5.hexdigest(File.read(file))
end

def archived_file_match(archived_file, file)
  begin
    tmp_dir = Dir.mktmpdir(Rails.root.to_s + '/tmp/') + '/'

    `tar xfz #{archived_file} -C #{tmp_dir}`

    unarchived_file = tmp_dir + Dir.entries(tmp_dir).select { |f| f unless File.directory? tmp_dir + f }.first

    md5(unarchived_file) == md5(file)
  rescue Exception => e
    raise e
  ensure
      FileUtils.rm_rf tmp_dir if File.directory? tmp_dir
  end
end
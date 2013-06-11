def setup
  tmp_dir = Rails.root.join('tmp').to_s
  FileUtils.mkdir tmp_dir unless File.directory? tmp_dir
end

def make_project(name)
  begin
    setup
    tmp_dir = Dir.mktmpdir(Rails.root.to_s + '/tmp/')
    assets_dir = Rails.root.to_s + '/features/assets/'
    FileUtils.cp(assets_dir + 'data_schema.xml', tmp_dir + '/data_schema.xml' )
    FileUtils.cp(assets_dir + 'ui_schema.xml', tmp_dir + '/ui_schema.xml' )
    FileUtils.cp(assets_dir + 'ui_logic.bsh', tmp_dir + '/ui_logic.bsh' )
    FileUtils.cp(assets_dir + 'project.settings', tmp_dir + '/project.settings' )
    FileUtils.cp(assets_dir + 'validation_schema.xml', tmp_dir + '/validation_schema.xml' )
    project = Project.create(:name => name, :key => SecureRandom.uuid)
    project.create_project_from(tmp_dir)
    project
  rescue Exception => e
    raise e
  ensure
    FileUtils.rm_rf tmp_dir if tmp_dir and File.directory? tmp_dir
  end
end

def is_valid_settings_file(filename)
  JSON.parse(File.read(filename))['key'].should =~ /^\S{8}-\S{4}-\S{4}-\S{4}-\S{12}$/
end

def md5(file)
  MD5Checksum.compute_checksum(file)
end

def archived_file_match(archived_file, file)
  begin
    tmp_dir = Dir.mktmpdir(Rails.root.to_s + '/tmp/') + '/'

    `tar xfz #{archived_file} -C #{tmp_dir}`

    unarchived_file = tmp_dir + Dir.entries(tmp_dir).select { |f| f unless File.directory? tmp_dir + f }.first

    md5(unarchived_file).should == md5(file)
  rescue Exception => e
    raise e
  ensure
      FileUtils.rm_rf tmp_dir if File.directory? tmp_dir
  end
end

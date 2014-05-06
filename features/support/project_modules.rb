def make_project_module(name)
  begin
    project_module = ProjectModule.create(:name => name, :key => SecureRandom.uuid, :created => true)
    FileUtils.cp_r(Dir[Rails.root.join("features/assets/#{project_module.name.downcase.gsub(/\s/,'_')}/*")], Rails.root.join("tmp/modules/#{project_module.key}"))
    project_module
  rescue Exception => e
    raise e
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
    tmp_dir = Dir.mktmpdir(nil, Rails.root.to_s + '/tmp/') + '/'

    `tar xfz #{archived_file} -C #{tmp_dir}`

    unarchived_file = tmp_dir + Dir.entries(tmp_dir).select { |f| f unless File.directory? tmp_dir + f }.first

    md5(unarchived_file).should == md5(file)
  rescue Exception => e
    raise e
  ensure
      FileUtils.rm_rf tmp_dir if File.directory? tmp_dir
  end
end

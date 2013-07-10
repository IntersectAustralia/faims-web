require File.expand_path("../../../spec/tools/helpers/database_generator_spec_helper", __FILE__)
require File.expand_path("../../support/projects", __FILE__)

And /^I pick file "([^"]*)" for "([^"]*)"$/ do |file, field|
  attach_file(field, File.expand_path("../../assets/" + file, __FILE__)) unless file.blank?
end

When /^(?:|I )press "([^"]*)" for "([^"]*)"$/ do |button, field|
  first(:xpath, "//label[contains(., '#{field}')]/..").find(:css, ".btn[value='#{button}']").click
end

And /^I have a projects dir$/ do
  Dir.mkdir('tmp') unless File.directory? 'tmp'
  FileUtils.rm_rf('tmp/projects')
  FileUtils.rm_rf('tmp/uploads')
  Dir.mkdir('tmp/projects')
  Dir.mkdir('tmp/uploads')
end

And /^I should not see errors for upload "([^"]*)"$/ do |field|
  page.should have_no_selector(:xpath, "//label[contains(., '#{field}')]/../../span[@class='help-inline']")
end

And /^I have project "([^"]*)"$/ do |name|
  make_project name
end

Then /^I should see "([^"]*)" with error "([^"]*)"$/ do |field, error|
  page.should have_selector(:xpath, "//label[contains(., '#{field}')]/../span[@class='help-inline' and text()=\"#{error}\"]")
end

Given /^I have projects$/ do |table|
  table.hashes.each do |hash|
    make_project hash[:name]
  end
end

Then /^I should see projects$/ do |table|
  table.hashes.each do |hash|
    Project.find_by_name(hash[:name]).should_not be_nil
  end
end

Then /^I have project files for "([^"]*)"$/ do |name|
  dir_name = Project.find_by_name(name).get_name(:project_dir)
  File.directory?(Rails.root.join('tmp/projects', dir_name)).should be_true
  File.exists?(Rails.root.join('tmp/projects', dir_name, 'db.sqlite3')).should be_true
  File.exists?(Rails.root.join('tmp/projects', dir_name, 'ui_schema.xml')).should be_true
  File.exists?(Rails.root.join('tmp/projects', dir_name, 'ui_logic.bsh')).should be_true
  File.exists?(Rails.root.join('tmp/projects', dir_name, 'project.settings')).should be_true
  File.exists?(Rails.root.join('tmp/projects', dir_name, 'faims.properties')).should be_true

  settings_file = Rails.root.join('tmp/projects', dir_name, 'project.settings')
  is_valid_settings_file settings_file
end

Then /^I should see json for projects$/ do
  projects = Project.all.map { |p| {key:p.key, name:p.name} }
  page.should have_content(projects.to_json)
end

Then /^I should see json for "([^"]*)" settings$/ do |name|
  page.should have_content(Project.find_by_name(name).settings_archive_info.to_json)
end

Then /^I should download settings for "([^"]*)"$/ do |name|
  project = Project.find_by_name(name)
  page.response_headers["Content-Disposition"].should == "attachment; filename=\"" + project.get_name(:settings_archive) + "\""
  file = File.open(project.get_path(:settings_archive), 'r')
  page.source == file.read
end

And /^I upload database "([^"]*)" to (.*) succeeds$/ do |db_file, name|
  project = Project.find_by_name(name)
  upload_db_file = File.open(File.expand_path("../../assets/" + db_file + ".tar.gz", __FILE__))
  md5 = MD5Checksum.compute_checksum(upload_db_file)
  project.check_sum(upload_db_file,md5).should be_true
end

And /^I upload sync database "([^"]*)" to (.*) succeeds$/ do |db_file, name|
  project = Project.find_by_name(name)
  upload_db_file = File.open(File.expand_path("../../assets/" + db_file + ".tar.gz", __FILE__))
  md5 = MD5Checksum.compute_checksum(upload_db_file)
  project.check_sum(upload_db_file,md5).should be_true
end

And /^I upload database "([^"]*)" to (.*) fails/ do |db_file, name|
  lambda {
    project = Project.find_by_name(name)
    upload_db_file = File.open(File.expand_path("../../assets/" + db_file + ".tar.gz", __FILE__))
    md5 = MD5Checksum.compute_checksum(upload_db_file)
    project.check_sum(upload_db_file,md5).should be_true
  }.should raise_error
end

Then /^I should have stored "([^"]*)" into (.*)$/ do |db_file, name|
  project = Project.find_by_name(name)
  uploaded_file = File.open(File.expand_path("../../assets/" + db_file + ".tar.gz", __FILE__), 'r+')
  project.store_database(uploaded_file, 0)
  stored_file = Project.uploads_path + '/' + Dir.entries(Project.uploads_path).select { |f| f unless File.directory? f }.first

  # check stored file format (TODO why can't i use merge daemon)
  /^(?<key>[^_]+)_v(?<version>\d+)$/.match(File.basename(stored_file)).should_not be_nil

  # check if uploaded_file unarchived matches stored_file
  archived_file_match(uploaded_file.path, stored_file).should be_true
end

Then /^I should have stored sync "([^"]*)" into (.*)$/ do |db_file, name|
  project = Project.find_by_name(name)
  uploaded_file = File.open(File.expand_path("../../assets/" + db_file + ".tar.gz", __FILE__), 'r+')
  project.store_database(uploaded_file, 0)

  stored_file = Project.uploads_path + '/' + Dir.entries(Project.uploads_path).select { |f| f unless File.directory? f }.first

  # check stored file format (TODO why can't i use merge daemon)
  /^(?<key>[^_]+)_v(?<version>\d+)$/.match(File.basename(stored_file)).should_not be_nil

  # check if uploaded_file unarchived matches stored_file
  archived_file_match(uploaded_file.path, stored_file).should be_true
end

Then /^I should not have stored "([^"]*)" into (.*)$/ do |db_file, name|
  project = Project.find_by_name(name)
  uploaded_file = File.open(File.expand_path("../../assets/" + db_file + ".tar.gz", __FILE__), 'r+')
  project.store_database(uploaded_file, 0)

  stored_file = Project.uploads_path + '/' + Dir.entries(Project.uploads_path).select { |f| f unless File.directory? f }.first

  # check if uploaded_file unarchived matches stored_file
  archived_file_match(uploaded_file.path, stored_file).should be_true
end

And /^I upload corrupted database "([^"]*)" to (.*) fails$/ do |db_file, name|
  project = Project.find_by_name(name)
  upload_db_file = File.open(File.expand_path("../../assets/" + db_file + ".tar.gz", __FILE__), 'r+')
  md5 = MD5Checksum.compute_checksum(upload_db_file) + '55'
  project.check_sum(upload_db_file,md5).should be_false
end

Then /^I should see json for "([^"]*)" db/ do |name|
  page.should have_content(Project.find_by_name(name).db_archive_info.to_json)
end

Then /^I should download db file for "([^"]*)"$/ do |name|
  project = Project.find_by_name(name)
  page.response_headers["Content-Disposition"].should == "attachment; filename=\"" + project.get_name(:db_archive) + "\""
  file = File.open(project.get_path(:db_archive), 'r')
  page.source == file.read
end

Then /^I should download db file for "([^"]*)" from version (.*)$/ do |name, version|
  project = Project.find_by_name(name)
  info = project.db_version_archive_info(version)
  page.response_headers["Content-Disposition"].should == "attachment; filename=\"" + File.basename(info[:file]) + "\""
  file = File.open(project.temp_db_version_file_path(version), 'r')
  page.source == file.read
end

And /^I have synced (.*) times for "([^"]*)"$/ do |num, name|
  project = Project.find_by_name(name)
  (1..num.to_i).each do |i|
    SpatialiteDB.new(project.get_path(:db)).execute("insert into version (versionnum, uploadtimestamp, userid, ismerged) select #{i}, CURRENT_TIMESTAMP, 0, 1;")
  end
end

Then /^I should see json for "([^"]*)" settings with version (.*)$/ do |name, version|
  page.should have_content(Project.find_by_name(name).settings_archive_info.to_json)
  page.should have_content("\"version\":\"#{version}\"")
end

Then /^I should see json for "([^"]*)" database with version (.*)$/ do |name, version|
  page.should have_content(Project.find_by_name(name).db_archive_info.to_json)
  page.should have_content("\"version\":\"#{version}\"")
end

Then /^I should see json for "([^"]*)" version (.*) db with version (.*)$/ do |name, requested_version, version|
  page.should have_content(Project.find_by_name(name).db_version_archive_info(requested_version).to_json)
  page.should have_content("\"version\":\"#{version}\"")
end

When /^I click on "([^"]*)"$/ do |name|
  project = Project.find_by_name(name)
  visit ("/projects/" + project.id.to_s)
end

Then /^I should see bad request page$/ do
  page.status_code.should == 400
end

Then /^I should see empty file list$/ do
  page.should have_content({files:[]}.to_json)
end

And /^I have server only files for "([^"]*)"$/ do |name, table|
  project = Project.find_by_name(name)
  table.hashes.each do |row|
    project.add_server_file(File.open(Rails.root.to_s + '/features/assets/' + row[:file], 'r'), row[:file])
  end
end

And /^I have app files for "([^"]*)"$/ do |name, table|
  project = Project.find_by_name(name)
  table.hashes.each do |row|
    project.add_app_file(File.open(Rails.root.to_s + '/features/assets/' + row[:file], 'r'), row[:file])
  end
  project.update_archives
end

And /^I have data files for "([^"]*)"$/ do |name, table|
  project = Project.find_by_name(name)
  table.hashes.each do |row|
    project.add_data_file(File.open(Rails.root.to_s + '/features/assets/' + row[:file], 'r'), row[:file])
  end
  project.update_archives
end

Then /^I should see files$/ do |table|
  files = []
  table.hashes.each do |row|
      files.push(row[:file])
  end
  files = files.sort
  page.should have_content({files:files}.to_json)
end

Then /^I should see json for "([^"]*)" server files archive$/ do |name|
  project = Project.find_by_name(name)
  info = project.server_file_archive_info
  page.should have_content("\"size\":#{info[:size]}")
end

Then /^I should see json for "([^"]*)" app files archive$/ do |name|
  project = Project.find_by_name(name)
  info = project.app_file_archive_info
  page.should have_content("\"size\":#{info[:size]}")
end

Then /^I should see json for "([^"]*)" data files archive$/ do |name|
  project = Project.find_by_name(name)
  info = project.data_file_archive_info
  page.should have_content("\"size\":#{info[:size]}")
end

Then /^I should see json for "([^"]*)" server files archive given I already have files$/ do |name, table|
  project = Project.find_by_name(name)
  files = []
  table.hashes.each do |row|
    files.push(row[:file])
  end
  info = project.server_file_archive_info(files)
  page.should have_content("\"size\":#{info[:size]}")
end

Then /^I should see json for "([^"]*)" app files archive given I already have files$/ do |name, table|
  project = Project.find_by_name(name)
  files = []
  table.hashes.each do |row|
    files.push(row[:file])
  end
  info = project.app_file_archive_info(files)
  page.should have_content("\"size\":#{info[:size]}")
end

Then /^I should see json for "([^"]*)" data files archive given I already have files$/ do |name, table|
  project = Project.find_by_name(name)
  files = []
  table.hashes.each do |row|
    files.push(row[:file])
  end
  info = project.data_file_archive_info(files)
  page.should have_content("\"size\":#{info[:size]}")
end

And /^I request for (.+) with files$/ do |name, table|
  page_name = path_to(name)
  files = []
  table.hashes.each do |row|
    files.push(row[:file])
  end
  files_list = files.map{ |f| "files[]=#{f}&" }.join
  visit page_name + "?#{files_list}"
end

Then /^I archive and download server files for "([^"]*)"$/ do |name|
  project = Project.find_by_name(name)
  info = project.server_file_archive_info
  check_archive_download_files('server', name, info, project.server_file_list)
end

Then /^I archive and download server files for "([^"]*)" given I already have files$/ do |name, table|
  files = []
  table.hashes.each do |row|
    files.push(row)
  end
  project = Project.find_by_name(name)
  info = project.server_file_archive_info(files)
  check_archive_download_files('server', name, info, project.server_file_list, files)
end

Then /^I archive and download app files for "([^"]*)"$/ do |name|
  project = Project.find_by_name(name)
  info = project.app_file_archive_info
  check_archive_download_files('app', name, info, project.app_file_list)
end

Then /^I archive and download app files for "([^"]*)" given I already have files$/ do |name, table|
  files = []
  table.hashes.each do |row|
    files.push(row)
  end
  project = Project.find_by_name(name)
  info = project.app_file_archive_info(files)
  check_archive_download_files('app', name, info, project.app_file_list, files)
end

Then /^I archive and download data files for "([^"]*)"$/ do |name|
  project = Project.find_by_name(name)
  info = project.data_file_archive_info
  check_archive_download_files('data', name, info, project.data_file_list)
end

Then /^I archive and download data files for "([^"]*)" given I already have files$/ do |name, table|
  files = []
  table.hashes.each do |row|
    files.push(row)
  end
  project = Project.find_by_name(name)
  info = project.data_file_archive_info(files)
  check_archive_download_files('data', name, info, project.data_file_list, files)
end

def check_archive_download_files(type, name, info, project_files, exclude_files = nil)
  visit path_to("the android #{type} files download link for #{name}") + "?file=#{info[:file]}"

  page.response_headers["Content-Disposition"].should == "attachment; filename=\"" + File.basename(info[:file]) + "\""
  file = File.open(info[:file], 'r')
  page.source == file.read

  # check if files all exist
  project = Project.find_by_name(name)
  tmp_dir = project.get_path(:project_dir) + '/' + SecureRandom.uuid

  download_list = get_archive_list(tmp_dir, file)

  exclude_files ||= []

  # check if file is part of directory list
  download_list.select{ |f| !project_files.include? f }.size.should == 0

  # check if file is not in exclude list
  download_list.select{ |f| exclude_files.include? f }.size.should == 0

  FileUtils.rm_rf tmp_dir

end

def get_archive_list(dir, archive)
  Dir.mkdir(dir)

  `tar xfz #{archive.path} -C #{dir}`

  file_list = FileHelper.get_file_list(dir)

  FileUtils.rm_rf dir

  file_list
end

Then /^I should download project package file for "([^"]*)"$/ do |name|
  project = Project.find_by_name(name)
  page.response_headers["Content-Disposition"].should == "attachment; filename=\"" + project.get_name(:package_archive) + "\""
  file = File.open(project.get_path(:package_archive), 'r')
  page.source == file.read
end

Then /^I automatically archive project package "([^"]*)"$/ do |name|
  project = Project.find_by_name(name)
  project.package_project
end

Then /^I automatically download project package "([^"]*)"$/ do |name|
  project = Project.find_by_name(name)
  visit ("/projects/" + project.id.to_s + "/download_project")
end

And /^I upload server files "([^"]*)" to (.*) succeeds$/ do |file, name|
  filepath = Rails.root.to_s + "/features/assets/" + file
  project = Project.find_by_name(name)

  upload_file = File.open(filepath, 'r')
  project.server_file_upload(upload_file)
end

And /^I upload app files "([^"]*)" to (.*) succeeds$/ do |file, name|
  filepath = Rails.root.to_s + "/features/assets/" + file
  project = Project.find_by_name(name)

  upload_file = File.open(filepath, 'r')
  project.app_file_upload(upload_file)
end

And /^I upload data files "([^"]*)" to (.*) succeeds$/ do |file, name|
  filepath = Rails.root.to_s + "/features/assets/" + file
  project = Project.find_by_name(name)

  upload_file = File.open(filepath, 'r')
  project.data_file_upload(upload_file)
end

Then /^I should have stored server files "([^"]*)" for (.*)$/ do |file, name|
  filepath = Rails.root.to_s + '/features/assets/' + file
  project = Project.find_by_name(name)

  upload_file = File.open(filepath, 'r')

  tmp_dir = project.get_path(:project_dir) + '/' + SecureRandom.uuid
  upload_list = get_archive_list(tmp_dir, upload_file)

  # check if uploaded files exist on server file list
  server_list = project.server_file_list
  upload_list.select { |f| !server_list.include? f }.size.should == 0
end

Then /^I should have stored app files "([^"]*)" for (.*)$/ do |file, name|
  filepath = Rails.root.to_s + '/features/assets/' + file
  project = Project.find_by_name(name)

  upload_file = File.open(filepath, 'r')

  tmp_dir = project.get_path(:project_dir) + '/' + SecureRandom.uuid
  upload_list = get_archive_list(tmp_dir, upload_file)

  # check if uploaded files exist on app file list
  app_list = project.app_file_list
  upload_list.select { |f| !app_list.include? f }.size.should == 0
end

Then /^I should have stored data files "([^"]*)" for (.*)$/ do |file, name|
  filepath = Rails.root.to_s + '/features/assets/' + file
  project = Project.find_by_name(name)

  upload_file = File.open(filepath, 'r')

  tmp_dir = project.get_path(:project_dir) + '/' + SecureRandom.uuid
  upload_list = get_archive_list(tmp_dir, upload_file)

  # check if uploaded files exist on data file list
  data_list = project.data_file_list
  upload_list.select { |f| !data_list.include? f }.size.should == 0
end

And /^I upload server files "([^"]*)" to (.*) fails$/ do |file, name|
  Project.find_by_name(name).should be_nil
end

And /^I upload app files "([^"]*)" to (.*) fails$/ do |file, name|
  Project.find_by_name(name).should be_nil
end

And /^I upload data files "([^"]*)" to (.*) fails$/ do |file, name|
  Project.find_by_name(name).should be_nil
end

And(/^I enter "([^"]*)" and submit the form$/) do |keywords|
  page.fill_in 'query', :with => keywords
  page.click_button 'Search'
end

And(/^I select the first record$/) do
  first('.inner > li > a').click
end

Then /^I should see attached files/ do |table|
  table.hashes.each do |hash|
    hash.values.each do |value|
      page.should have_content(value)
    end
  end
end

Then(/^I click file with name "([^"]*)"$/) do |name|
  pending
end

When(/^I should download attached file with name "([^"]*)"$/) do |name|
  pending
end

When(/^I select "([^"]*)" for the attribute$/) do |name|
  select name, :from => 'attribute_id'
end

Then(/^I should see vocabularies$/) do |table|
  table.hashes.each do |hash|
    hash.values.each do |value|
      page.should have_xpath("//input[@value='#{value}']")
    end
  end
end

When(/^I modify vocabulary "([^"]*)" with "([^"]*)"$/) do |original, value|
  find(:xpath, "//input[@value='#{original}']").set value
end

When(/^I add "([^"]*)" to the vobulary list$/) do |value|
  all(:xpath, "//input[@name='vocab_name[]']").last.set value
end

When(/^Project "([^"]*)" should have the same file "([^"]*)"$/) do |project_name, file_name|
  project = Project.find_by_name(project_name)
  project_hash_sum = MD5Checksum.compute_checksum(project.get_path(:project_dir) + file_name)
  file_hash_sum =  MD5Checksum.compute_checksum(File.expand_path("../../assets/" + file_name, __FILE__))
  (project_hash_sum.eql?(file_hash_sum)).should be_true
end

def check_project_archive_updated(project)
  begin
    tmp_dir = Dir.mktmpdir(Rails.root.to_s + '/tmp/')

    `tar xfz #{project.get_path(:project_archive)} -C #{tmp_dir}`

    tmp_project_dir = tmp_dir + '/' + project.key

    compare_dir(project.get_path(:app_files_dir), tmp_project_dir + '/' + project.get_name(:app_files_dir))
  rescue Exception => e
    raise e
  ensure
    FileUtils.rm_rf tmp_dir if File.directory? tmp_dir
  end
end

def compare_dir(dir1, dir2)
  return false unless File.directory? dir1
  return false unless File.directory? dir2
  file_list1 = FileHelper.get_file_list(dir1)
  file_list2 = FileHelper.get_file_list(dir2)
  return false unless file_list1.size == file_list2.size
  for i in (1..file_list1.size) do
    md5(dir1 + '/' + file_list1.shift).should == md5(dir2 + '/' + file_list2.shift)
  end
  return true
end

And /^I should have setting "([^"]*)" for "([^"]*)" as "([^"]*)"$/ do |setting_name, name, srid|
  project = Project.find_by_name(name)
  settings = JSON.parse(File.read(project.get_path(:settings)).as_json)
  settings[setting_name].should == srid
end
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
  page.should have_selector(:xpath, "//label[contains(., '#{field}')]/../span[@class='help-inline' and contains(text(),\"#{error}\")]")
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
  if all(:xpath, "//input[@value = \"#{name}\"]").size > 0
    find(:xpath, "//input[@value = \"#{name}\"]").click
  else
    (1..3).each do
      if all(:xpath, "//a[contains(text(), \"#{name}\")]").size == 0
        sleep(1)
      else
        find(:xpath, "//a[contains(text(), \"#{name}\")]").click
        break
      end
    end
  end
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
  if all('.inner > li > a').size > 0
    first('.inner > li > a').click
  else
    first('.inner > input').click
  end
end

And(/^I delete the first record$/) do
  first('#remove-member > a').click
end

Then /^I should see attached files$/ do |table|
  table.hashes.each do |hash|
    hash.values.each do |value|
      page.should have_xpath("//a[contains(text(), \"#{value}\")]")
    end
  end
end

Then /^I should see non attached files$/ do |table|
  table.hashes.each do |hash|
    hash.values.each do |value|
      page.should_not have_xpath("//p[contains(text(), \"#{value}\")]")
    end
  end
end

Then /^I remove all files for "([^"]*)"$/ do |name|
   p = Project.find_by_name(name)
   FileUtils.rm_rf p.get_path(:files_dir)
end

Then(/^I click file with name "([^"]*)"$/) do |name|
  pending
end

When(/^I should download attached file with name "([^"]*)"$/) do |name|
  pending
end

When(/^I select "([^"]*)" for the attribute$/) do |name|
  select name, :from => 'attribute_id'
  sleep(1)
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
  sleep(1)
end

When(/^I add "([^"]*)" to the vocabulary list$/) do |value|
  all(:xpath, "//input[@name='vocab_name[]']").last.set value
  sleep(1)
end

When(/^Project "([^"]*)" should have the same file "([^"]*)"$/) do |project_name, file_name|
  project = Project.find_by_name(project_name)
  project_hash_sum = MD5Checksum.compute_checksum(project.get_path(:project_dir) + file_name)
  file_hash_sum =  MD5Checksum.compute_checksum(File.expand_path("../../assets/" + file_name, __FILE__))
  (project_hash_sum.eql?(file_hash_sum)).should be_true
end

When(/^I should have user for selection$/) do |table|
  table.hashes.each do |hash|
    hash.values.each do |value|
      page.should have_xpath("//select/option[text() = '#{value}']")
    end
  end
end

When(/^I select "([^"]*)" from the user list$/) do |name|
  select name, :from => 'user_id'
end

When(/^I should have user for project$/) do |table|
  table.hashes.each do |hash|
    hash.values.each do |value|
      page.should have_xpath("//input[@value='#{value}']")
    end
  end
end

Then(/^I should see records$/) do |table|
  table.hashes.each do |hash|
    hash.values.each do |value|
      page.should have_xpath("//a[contains(text(),\"#{value}\")]")
    end
  end
end

When(/^I should not see records$/) do |table|
  table.hashes.each do |hash|
    hash.values.each do |value|
      page.should_not have_xpath("//a[contains(text(),\"#{value}\")]")
    end
  end
end

When(/^I should see related arch entities$/) do |table|
  table.hashes.each do |hash|
    hash.values.each do |value|
      page.should have_xpath("//a[contains(text(),\"#{value}\")]")
    end
  end
end

When(/^I should not see related arch entities$/) do |table|
  table.hashes.each do |hash|
    hash.values.each do |value|
      page.should_not have_xpath("//a[contains(text(),\"#{value}\")]")
    end
  end
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

And /^I have database "([^"]*)" for "([^"]*)"$/ do |db, project|
  p = Project.find_by_name(project)
  FileUtils.cp Rails.root.join("features/assets/#{db}"), p.get_path(:db)
end

Then /^I should see "([^"]*)" with "([^"]*)"$/ do |link, error|
  page.should have_xpath("//a[contains(text(),\"#{link}\")]/div[contains(text(), \"#{error}\")]")
end

Then /^I history should have conflicts$/ do
   page.should have_css(".box-warning")
end

Then /^I history should not have conflicts$/ do
  page.should_not have_css(".box-warning")
end

And /^I follow link "([^"]*)"$/ do |link|
  find(:xpath, "//input[@value=\"#{link}\"]").click
end

And /^I add "([^"]*)" to "([^"]*)"$/ do |email, name|
  user = User.find_by_email(email)
  project = Project.find_by_name(name)
  project.db.update_list_of_users(user, User.first.id)
end

And /^I update attribute "([^"]*)" with "([^"]*)"$/ do |name, value|
  find(:xpath, "//h4[contains(text(), '#{name}')]/following-sibling::div/div/label[contains(text(), 'Freetext')]/following-sibling::input").set value
  find(:xpath, "//h4[contains(text(), '#{name}')]/following-sibling::div/input[@value='Update']").click
end

Then /^I see attribute "([^"]*)" with "([^"]*)"$/ do |name, value|
  find(:xpath, "//h4[contains(text(), '#{name}')]/following-sibling::div/div/label[contains(text(), 'Freetext')]/following-sibling::input").value.should == value
end

And /^I click "([^"]*)" for "([^"]*)"$/ do |button, dir|
  find(:xpath, "//a[contains(text(), '#{dir}')]/../following-sibling::span/div/a[contains(text(), '#{button}')]").click
end

And /^I attach project file "([^"]*)" for "([^"]*)"$/ do |file, dir|
  all(:xpath, "//a[contains(text(), '#{dir}')]/../following-sibling::span/div/div/form/div/following-sibling::div/input[1]").first.set Rails.root.join("features/assets/#{file}")
  all(:xpath, "//a[contains(text(), '#{dir}')]/../following-sibling::span/div/div/form/div/following-sibling::div/input[2]").first.click
end

Then /^I upload project files$/ do |table|
  table.hashes.each do |hash|
    step "I click \"upload file\" for \"#{hash[:dir]}\""
    step "I attach project file \"#{hash[:file]}\" for \"#{hash[:dir]}\""
  end
end

Then /^I should see project files$/ do |table|
  table.hashes.each do |hash|
    page.should have_xpath("//div[@class='dir clearfix'][./div[@class='dir-header']/h3/span/a[text()='#{hash[:dir]}']]/ul/li/a[contains(text(), '#{hash[:file]}')]")
  end
end

And /^I enter directory "([^"]*)" for "([^"]*)"$/ do |child_dir, dir|
  all(:xpath, "//a[contains(text(), '#{dir}')]/../following-sibling::span/div/div/form/div/following-sibling::div/input[1]").last.set child_dir
  all(:xpath, "//a[contains(text(), '#{dir}')]/../following-sibling::span/div/div/form/div/following-sibling::div/input[2]").last.click
end

Then /^I create project directories$/ do |table|
  table.hashes.each do |hash|
    step "I click \"create directory\" for \"#{hash[:dir]}\""
    step "I enter directory \"#{hash[:child_dir]}\" for \"#{hash[:dir]}\""
  end
end

Then /^I should see project directories$/ do |table|
  table.hashes.each do |hash|
    page.should have_xpath("//div[@class='dir clearfix'][./div[@class='dir-header']/h3/span/a[text()='#{hash[:dir]}']]/ul/div[@class='dir clearfix']/div[@class='dir-header']/h3/span/a[text()='#{hash[:child_dir]}']")
  end
end

And /^I delete project file "([^"]*)" for "([^"]*)"$/ do |file, dir|
  (1..3).each do
    if all(:xpath, "//div[@class='dir clearfix'][./div[@class='dir-header']/h3/span/a[text()='#{dir}']]/ul/li[./a[contains(text(), '#{file}')]]/following-sibling::a").size == 0
      sleep(1)
    else
      all(:xpath, "//div[@class='dir clearfix'][./div[@class='dir-header']/h3/span/a[text()='#{dir}']]/ul/li[./a[contains(text(), '#{file}')]]/following-sibling::a").first.click
      break
    end
  end
end

Then /^I delete project files$/ do |table|
  table.hashes.each do |hash|
    step "I delete project file \"#{hash[:file]}\" for \"#{hash[:dir]}\""
    step 'I confirm'
  end
end

And /^I delete project directory "([^"]*)" for "([^"]*)"$/ do |child_dir, dir|
  find(:xpath, "//div[@class='dir clearfix'][./div[@class='dir-header']/h3/span/a[text()='#{dir}']]/ul/div[@class='dir clearfix']/div[@class='dir-header']/h3/span/a[text()='#{child_dir}']/../following-sibling::span/a").click
end

Then /^I delete project directories$/ do |table|
  table.hashes.each do |hash|
    step "I delete project directory \"#{hash[:child_dir]}\" for \"#{hash[:dir]}\""
    step 'I confirm'
  end
end

And /^I confirm$/ do
  page.driver.browser.switch_to.alert.accept
end

And /^I perform HTTP authentication$/ do
  username = AndroidController::ANDROID_USER
  password = AndroidController::ANDROID_TOKEN
  if page.driver.respond_to?(:basic_auth)
    #puts 'Responds to basic_auth'
    page.driver.basic_auth(username, password)
  elsif page.driver.respond_to?(:basic_authorize)
    #puts 'Responds to basic_authorize'
    page.driver.basic_authorize(username, password)
  elsif page.driver.respond_to?(:browser) && page.driver.browser.respond_to?(:basic_authorize)
    #puts 'Responds to browser_basic_authorize'
    page.driver.browser.basic_authorize(username, password)
  else
    raise "I don't know how to log in!"
  end
end
WAIT_RANGE = (1..5)

require File.expand_path("../../../spec/tools/helpers/database_generator_spec_helper", __FILE__)
require File.expand_path("../../support/project_modules", __FILE__)

And /^I pick file "([^"]*)" for "([^"]*)"$/ do |file, field|
  attach_file(field, File.expand_path("../../assets/" + file, __FILE__)) unless file.blank?
end

When /^(?:|I )press "([^"]*)" for "([^"]*)"$/ do |button, field|
  first(:xpath, "//label[contains(., '#{field}')]/..").find(:css, ".btn[value='#{button}']").click
end

And /^I have a project modules dir$/ do
  Dir.mkdir('tmp') unless File.directory? 'tmp'
  FileUtils.rm_rf('tmp/modules')
  FileUtils.rm_rf('tmp/uploads')
  Dir.mkdir('tmp/modules')
  Dir.mkdir('tmp/uploads')
end

And /^I should not see errors for upload "([^"]*)"$/ do |field|
  page.should have_no_selector(:xpath, "//label[contains(., '#{field}')]/../../span[@class='help-inline']")
end

And /^I have project module "([^"]*)"$/ do |name|
  make_project_module name
end

Then /^I should see "([^"]*)" with error "([^"]*)"$/ do |field, error|
  page.should have_selector(:xpath, "//label[contains(., '#{field}')]/../span[@class='help-inline' and contains(text(),\"#{error}\")]")
end

Given /^I have project modules$/ do |table|
  table.hashes.each do |hash|
    make_project_module hash[:name]
  end
end

Then /^I should see project modules$/ do |table|
  table.hashes.each do |hash|
    ProjectModule.find_by_name(hash[:name]).should_not be_nil
  end
end

Then /^I have project module files for "([^"]*)"$/ do |name|
  dir_name = ProjectModule.find_by_name(name).get_name(:project_module_dir)
  File.directory?(Rails.root.join('tmp/modules', dir_name)).should be_true
  File.exists?(Rails.root.join('tmp/modules', dir_name, 'db.sqlite3')).should be_true
  File.exists?(Rails.root.join('tmp/modules', dir_name, 'ui_schema.xml')).should be_true
  File.exists?(Rails.root.join('tmp/modules', dir_name, 'ui_logic.bsh')).should be_true
  File.exists?(Rails.root.join('tmp/modules', dir_name, 'module.settings')).should be_true
  File.exists?(Rails.root.join('tmp/modules', dir_name, 'faims.properties')).should be_true

  settings_file = Rails.root.join('tmp/modules', dir_name, 'module.settings')
  is_valid_settings_file settings_file
end

Then /^I should see json for project modules$/ do
  project_modules = ProjectModule.where(created:true).map { |p| {key:p.key, name:p.name} }
  page.should have_content(project_modules.to_json)
end

Then /^I should see json for "([^"]*)" settings$/ do |name|
  page.should have_content(ProjectModule.find_by_name(name).settings_archive_info.to_json)
end

Then /^I should download settings for "([^"]*)"$/ do |name|
  project_module = ProjectModule.find_by_name(name)
  page.response_headers["Content-Disposition"].should == "attachment; filename=\"" + project_module.get_name(:settings_archive) + "\""
  file = File.open(project_module.get_path(:settings_archive), 'r')
  page.source == file.read
end

And /^I upload database "([^"]*)" to (.*) succeeds$/ do |db_file, name|
  project_module = ProjectModule.find_by_name(name)
  upload_db_file = File.open(File.expand_path("../../assets/" + db_file + ".tar.gz", __FILE__))
  md5 = MD5Checksum.compute_checksum(upload_db_file)
  project_module.check_sum(upload_db_file,md5).should be_true
end

And /^I upload sync database "([^"]*)" to (.*) succeeds$/ do |db_file, name|
  project_module = ProjectModule.find_by_name(name)
  upload_db_file = File.open(File.expand_path("../../assets/" + db_file + ".tar.gz", __FILE__))
  md5 = MD5Checksum.compute_checksum(upload_db_file)
  project_module.check_sum(upload_db_file,md5).should be_true
end

And /^I upload database "([^"]*)" to (.*) fails/ do |db_file, name|
  lambda {
    project_module = ProjectModule.find_by_name(name)
    upload_db_file = File.open(File.expand_path("../../assets/" + db_file + ".tar.gz", __FILE__))
    md5 = MD5Checksum.compute_checksum(upload_db_file)
    project_module.check_sum(upload_db_file,md5).should be_true
  }.should raise_error
end

Then /^I should have stored "([^"]*)" into (.*)$/ do |db_file, name|
  project_module = ProjectModule.find_by_name(name)
  uploaded_file = File.open(File.expand_path("../../assets/" + db_file + ".tar.gz", __FILE__), 'r+')
  project_module.store_database(uploaded_file, 0)
  stored_file = ProjectModule.uploads_path + '/' + Dir.entries(ProjectModule.uploads_path).select { |f| f unless File.directory? f }.first

  # check stored file format (TODO why can't i use merge daemon)
  /^(?<key>[^_]+)_v(?<version>\d+)$/.match(File.basename(stored_file)).should_not be_nil

  # check if uploaded_file unarchived matches stored_file
  archived_file_match(uploaded_file.path, stored_file).should be_true
end

Then /^I should have stored sync "([^"]*)" into (.*)$/ do |db_file, name|
  project_module = ProjectModule.find_by_name(name)
  uploaded_file = File.open(File.expand_path("../../assets/" + db_file + ".tar.gz", __FILE__), 'r+')
  project_module.store_database(uploaded_file, 0)

  stored_file = ProjectModule.uploads_path + '/' + Dir.entries(ProjectModule.uploads_path).select { |f| f unless File.directory? f }.first

  # check stored file format (TODO why can't i use merge daemon)
  /^(?<key>[^_]+)_v(?<version>\d+)$/.match(File.basename(stored_file)).should_not be_nil

  # check if uploaded_file unarchived matches stored_file
  archived_file_match(uploaded_file.path, stored_file).should be_true
end

Then /^I should not have stored "([^"]*)" into (.*)$/ do |db_file, name|
  project_module = ProjectModule.find_by_name(name)
  uploaded_file = File.open(File.expand_path("../../assets/" + db_file + ".tar.gz", __FILE__), 'r+')
  project_module.store_database(uploaded_file, 0)

  stored_file = ProjectModule.uploads_path + '/' + Dir.entries(ProjectModule.uploads_path).select { |f| f unless File.directory? f }.first

  # check if uploaded_file unarchived matches stored_file
  archived_file_match(uploaded_file.path, stored_file).should be_true
end

And /^I upload corrupted database "([^"]*)" to (.*) fails$/ do |db_file, name|
  project_module = ProjectModule.find_by_name(name)
  upload_db_file = File.open(File.expand_path("../../assets/" + db_file + ".tar.gz", __FILE__), 'r+')
  md5 = MD5Checksum.compute_checksum(upload_db_file) + '55'
  project_module.check_sum(upload_db_file,md5).should be_false
end

Then /^I should see json for "([^"]*)" db/ do |name|
  page.should have_content(ProjectModule.find_by_name(name).db_archive_info.to_json)
end

Then /^I should download db file for "([^"]*)"$/ do |name|
  project_module = ProjectModule.find_by_name(name)
  page.response_headers["Content-Disposition"].should == "attachment; filename=\"" + project_module.get_name(:db_archive) + "\""
  file = File.open(project_module.get_path(:db_archive), 'r')
  page.source == file.read
end

Then /^I should download db file for "([^"]*)" from version (.*)$/ do |name, version|
  project_module = ProjectModule.find_by_name(name)
  info = project_module.db_version_archive_info(version)
  page.response_headers["Content-Disposition"].should == "attachment; filename=\"" + File.basename(info[:file]) + "\""
  file = File.open(project_module.temp_db_version_file_path(version), 'r')
  page.source == file.read
end

And /^I have synced (.*) times for "([^"]*)"$/ do |num, name|
  project_module = ProjectModule.find_by_name(name)
  (1..num.to_i).each do |i|
    SpatialiteDB.new(project_module.get_path(:db)).execute("insert into version (versionnum, uploadtimestamp, userid, ismerged) select #{i}, CURRENT_TIMESTAMP, 0, 1;")
  end
end

Then /^I should see json for "([^"]*)" settings with version (.*)$/ do |name, version|
  page.should have_content(ProjectModule.find_by_name(name).settings_archive_info.to_json)
  page.should have_content("\"version\":\"#{version}\"")
end

Then /^I should see json for "([^"]*)" database with version (.*)$/ do |name, version|
  page.should have_content(ProjectModule.find_by_name(name).db_archive_info.to_json)
  page.should have_content("\"version\":\"#{version}\"")
end

Then /^I should see json for "([^"]*)" version (.*) db with version (.*)$/ do |name, requested_version, version|
  page.should have_content(ProjectModule.find_by_name(name).db_version_archive_info(requested_version).to_json)
  page.should have_content("\"version\":\"#{version}\"")
end

When /^I click on "([^"]*)"$/ do |name|
  if all(:xpath, "//input[@value = \"#{name}\"]").size > 0
    find(:xpath, "//input[@value = \"#{name}\"]").click
  else
    WAIT_RANGE.each do
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
  project_module = ProjectModule.find_by_name(name)
  table.hashes.each do |row|
    project_module.add_server_file(File.open(Rails.root.to_s + '/features/assets/' + row[:file], 'r'), row[:file])
  end
end

And /^I have app files for "([^"]*)"$/ do |name, table|
  project_module = ProjectModule.find_by_name(name)
  table.hashes.each do |row|
    project_module.add_app_file(File.open(Rails.root.to_s + '/features/assets/' + row[:file], 'r'), row[:file])
  end
  project_module.update_archives
end

And /^I have data files for "([^"]*)"$/ do |name, table|
  project_module = ProjectModule.find_by_name(name)
  table.hashes.each do |row|
    project_module.add_data_file(File.open(Rails.root.to_s + '/features/assets/' + row[:file], 'r'), row[:file])
  end
  project_module.update_archives
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
  project_module = ProjectModule.find_by_name(name)
  info = project_module.server_file_archive_info
  page.should have_content("\"size\":#{info[:size]}")
end

Then /^I should see json for "([^"]*)" app files archive$/ do |name|
  project_module = ProjectModule.find_by_name(name)
  info = project_module.app_file_archive_info
  page.should have_content("\"size\":#{info[:size]}")
end

Then /^I should see json for "([^"]*)" data files archive$/ do |name|
  project_module = ProjectModule.find_by_name(name)
  info = project_module.data_file_archive_info
  page.should have_content("\"size\":#{info[:size]}")
end

Then /^I should see json for "([^"]*)" server files archive given I already have files$/ do |name, table|
  project_module = ProjectModule.find_by_name(name)
  files = []
  table.hashes.each do |row|
    files.push(row[:file])
  end
  info = project_module.server_file_archive_info(files)
  page.should have_content("\"size\":#{info[:size]}")
end

Then /^I should see json for "([^"]*)" app files archive given I already have files$/ do |name, table|
  project_module = ProjectModule.find_by_name(name)
  files = []
  table.hashes.each do |row|
    files.push(row[:file])
  end
  info = project_module.app_file_archive_info(files)
  page.should have_content("\"size\":#{info[:size]}")
end

Then /^I should see json for "([^"]*)" data files archive given I already have files$/ do |name, table|
  project_module = ProjectModule.find_by_name(name)
  files = []
  table.hashes.each do |row|
    files.push(row[:file])
  end
  info = project_module.data_file_archive_info(files)
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
  project_module = ProjectModule.find_by_name(name)
  info = project_module.server_file_archive_info
  check_archive_download_files('server', name, info, project_module.server_file_list)
end

Then /^I archive and download server files for "([^"]*)" given I already have files$/ do |name, table|
  files = []
  table.hashes.each do |row|
    files.push(row)
  end
  project_module = ProjectModule.find_by_name(name)
  info = project_module.server_file_archive_info(files)
  check_archive_download_files('server', name, info, project_module.server_file_list, files)
end

Then /^I archive and download app files for "([^"]*)"$/ do |name|
  project_module = ProjectModule.find_by_name(name)
  info = project_module.app_file_archive_info
  check_archive_download_files('app', name, info, project_module.app_file_list)
end

Then /^I archive and download app files for "([^"]*)" given I already have files$/ do |name, table|
  files = []
  table.hashes.each do |row|
    files.push(row)
  end
  project_module = ProjectModule.find_by_name(name)
  info = project_module.app_file_archive_info(files)
  check_archive_download_files('app', name, info, project_module.app_file_list, files)
end

Then /^I archive and download data files for "([^"]*)"$/ do |name|
  project_module = ProjectModule.find_by_name(name)
  info = project_module.data_file_archive_info
  check_archive_download_files('data', name, info, project_module.data_file_list)
end

Then /^I archive and download data files for "([^"]*)" given I already have files$/ do |name, table|
  files = []
  table.hashes.each do |row|
    files.push(row)
  end
  project_module = ProjectModule.find_by_name(name)
  info = project_module.data_file_archive_info(files)
  check_archive_download_files('data', name, info, project_module.data_file_list, files)
end

def check_archive_download_files(type, name, info, project_module_files, exclude_files = nil)
  visit path_to("the android #{type} files download link for #{name}") + "?file=#{info[:file]}"

  page.response_headers["Content-Disposition"].should == "attachment; filename=\"" + File.basename(info[:file]) + "\""
  file = File.open(info[:file], 'r')
  page.source == file.read

  # check if files all exist
  project_module = ProjectModule.find_by_name(name)
  tmp_dir = project_module.get_path(:project_module_dir) + '/' + SecureRandom.uuid

  download_list = get_archive_list(tmp_dir, file)

  exclude_files ||= []

  # check if file is part of directory list
  download_list.select{ |f| !project_module_files.include? f }.size.should == 0

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

Then /^I should download project module package file for "([^"]*)"$/ do |name|
  project_module = ProjectModule.find_by_name(name)
  page.response_headers["Content-Disposition"].should == "attachment; filename=\"" + project_module.get_name(:package_archive) + "\""
  file = File.open(project_module.get_path(:package_archive), 'r')
  page.source == file.read
end

Then /^I automatically archive project module package "([^"]*)"$/ do |name|
  project_module = ProjectModule.find_by_name(name)
  project_module.package_project_module
end

Then /^I automatically download project module package "([^"]*)"$/ do |name|
  project_module = ProjectModule.find_by_name(name)
  visit ("/project_modules/" + project_module.id.to_s + "/download_project_module")
end

And /^I upload server files "([^"]*)" to (.*) succeeds$/ do |file, name|
  filepath = Rails.root.to_s + "/features/assets/" + file
  project_module = ProjectModule.find_by_name(name)

  upload_file = File.open(filepath, 'r')
  project_module.server_file_upload(upload_file)
end

And /^I upload app files "([^"]*)" to (.*) succeeds$/ do |file, name|
  filepath = Rails.root.to_s + "/features/assets/" + file
  project_module = ProjectModule.find_by_name(name)

  upload_file = File.open(filepath, 'r')
  project_module.app_file_upload(upload_file)
end

And /^I upload data files "([^"]*)" to (.*) succeeds$/ do |file, name|
  filepath = Rails.root.to_s + "/features/assets/" + file
  project_module = ProjectModule.find_by_name(name)

  upload_file = File.open(filepath, 'r')
  project_module.data_file_upload(upload_file)
end

Then /^I should have stored server files "([^"]*)" for (.*)$/ do |file, name|
  filepath = Rails.root.to_s + '/features/assets/' + file
  project_module = ProjectModule.find_by_name(name)

  upload_file = File.open(filepath, 'r')

  tmp_dir = project_module.get_path(:project_module_dir) + '/' + SecureRandom.uuid
  upload_list = get_archive_list(tmp_dir, upload_file)

  # check if uploaded files exist on server file list
  server_list = project_module.server_file_list
  upload_list.select { |f| !server_list.include? f }.size.should == 0
end

Then /^I should have stored app files "([^"]*)" for (.*)$/ do |file, name|
  filepath = Rails.root.to_s + '/features/assets/' + file
  project_module = ProjectModule.find_by_name(name)

  upload_file = File.open(filepath, 'r')

  tmp_dir = project_module.get_path(:project_module_dir) + '/' + SecureRandom.uuid
  upload_list = get_archive_list(tmp_dir, upload_file)

  # check if uploaded files exist on app file list
  app_list = project_module.app_file_list
  upload_list.select { |f| !app_list.include? f }.size.should == 0
end

Then /^I should have stored data files "([^"]*)" for (.*)$/ do |file, name|
  filepath = Rails.root.to_s + '/features/assets/' + file
  project_module = ProjectModule.find_by_name(name)

  upload_file = File.open(filepath, 'r')

  tmp_dir = project_module.get_path(:project_module_dir) + '/' + SecureRandom.uuid
  upload_list = get_archive_list(tmp_dir, upload_file)

  # check if uploaded files exist on data file list
  data_list = project_module.data_file_list
  upload_list.select { |f| !data_list.include? f }.size.should == 0
end

And /^I upload server files "([^"]*)" to (.*) fails$/ do |file, name|
  ProjectModule.find_by_name(name).should be_nil
end

And /^I upload app files "([^"]*)" to (.*) fails$/ do |file, name|
  ProjectModule.find_by_name(name).should be_nil
end

And /^I upload data files "([^"]*)" to (.*) fails$/ do |file, name|
  ProjectModule.find_by_name(name).should be_nil
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
  first('.remove-member > a').click
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
   p = ProjectModule.find_by_name(name)
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
  attribute_id = find(:css, '#attribute')[:value]
  table.hashes.each do |hash|
    page.should have_css(".vocab-list-#{attribute_id} input[name='vocab_name[]'][value='#{hash[:name]}']")
    page.should have_css(".vocab-list-#{attribute_id} input[name='vocab_description[]'][value='#{hash[:description]}']")
    page.should have_css(".vocab-list-#{attribute_id} input[name='picture_url[]'][value='#{hash[:pictureURL]}']")
  end
end

Then(/^I click on "([^"]*)" for the attribute$/) do |name|
  attribute_id = find(:css, '#attribute')[:value]
  find(:css, ".vocab-list-#{attribute_id}").find('a', text: name).click()
end

When(/^I modify vocabulary "([^"]*)" with "([^"]*)"$/) do |original, value|
  attribute_id = find(:css, '#attribute')[:value]
  find(:css, ".vocab-list-#{attribute_id} input[name='vocab_name[]'][value='#{original}']").set value
  sleep(1)
end

When(/^I add "([^"]*)" to the vocabulary list$/) do |value|
  attribute_id = find(:css, '#attribute')[:value]
  all(:css, ".vocab-list-#{attribute_id} input[name='vocab_name[]']").last.set value
  sleep(1)
end

When(/^I add "([^"]*)" as description to the vocabulary list$/) do |value|
  attribute_id = find(:css, '#attribute')[:value]
  all(:css, ".vocab-list-#{attribute_id} input[name='vocab_description[]']").last.set value
  sleep(1)
end
When(/^I add "([^"]*)" as picture url to the vocabulary list$/) do |value|
  attribute_id = find(:css, '#attribute')[:value]
  all(:css, ".vocab-list-#{attribute_id} input[name='picture_url[]']").last.set value
  sleep(1)
end

Then(/^I click add child for vocabulary "([^"]*)"$/) do |vocab_name|
  attribute_id = find(:css, '#attribute')[:value]
  find(:css, ".vocab-list-#{attribute_id}").find(:xpath, ".//input[@value='#{vocab_name}']/../a").click()
end

Then(/^I click insert for vocabulary "([^"]*)"$/) do |vocab_name|
  attribute_id = find(:css, '#attribute')[:value]
  find(:css, ".vocab-list-#{attribute_id}").find(:xpath, ".//input[@value='#{vocab_name}']/../div/a").click()
end

When(/^I add "([^"]*)" as child for "([^"]*)"$/) do |value, vocab_name|
  attribute_id = find(:css, '#attribute')[:value]
  find(:css, ".vocab-list-#{attribute_id}").all(:xpath, ".//input[@value='#{vocab_name}']/../div/div").last.find(:css, "input[name='vocab_name[]']").set value
end

When(/^I add "([^"]*)" as child description for "([^"]*)"$/) do |value, vocab_name|
  attribute_id = find(:css, '#attribute')[:value]
  find(:css, ".vocab-list-#{attribute_id}").all(:xpath, ".//input[@value='#{vocab_name}']/../div/div").last.find(:css, "input[name='vocab_description[]']").set value
end

When(/^I add "([^"]*)" as child picture url for "([^"]*)"$/) do |value, vocab_name|
  attribute_id = find(:css, '#attribute')[:value]
  find(:css, ".vocab-list-#{attribute_id}").all(:xpath, ".//input[@value='#{vocab_name}']/../div/div").last.find(:css, "input[name='picture_url[]']").set value
end

When(/^I should see child vocabularies for "([^"]*)"$/) do |vocab_name, table|
  attribute_id = find(:css, '#attribute')[:value]
  div = find(:css, ".vocab-list-#{attribute_id}").find(:xpath, ".//input[@value='#{vocab_name}']/../div")
  table.hashes.each do |hash|
    div.should have_css("input[name='vocab_name[]'][value='#{hash[:name]}']")
    div.should have_css("input[name='vocab_description[]'][value='#{hash[:description]}']")
    div.should have_css("input[name='picture_url[]'][value='#{hash[:pictureURL]}']")
  end
end

When(/^Module "([^"]*)" should have the same file "([^"]*)"$/) do |project_module_name, file_name|
  project_module = ProjectModule.find_by_name(project_module_name)
  project_module_hash_sum = MD5Checksum.compute_checksum(project_module.get_path(:project_module_dir) + file_name)
  file_hash_sum =  MD5Checksum.compute_checksum(File.expand_path("../../assets/" + file_name, __FILE__))
  (project_module_hash_sum.eql?(file_hash_sum)).should be_true
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

When(/^I should have user for project module$/) do |table|
  table.hashes.each do |hash|
    hash.values.each do |value|
      page.should have_xpath("//input[@value='#{value}']")
    end
  end
end

When(/^I should not have user for project module$/) do |table|
  table.hashes.each do |hash|
    hash.values.each do |value|
      page.should_not have_xpath("//input[@value='#{value}']")
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

def check_project_module_archive_updated(project_module)
  begin
    tmp_dir = Dir.mktmpdir(nil, Rails.root.to_s + '/tmp/')

    `tar xfz #{project_module.get_path(:project_module_archive)} -C #{tmp_dir}`

    tmp_project_module_dir = tmp_dir + '/' + project_module.key

    compare_dir(project_module.get_path(:app_files_dir), tmp_project_module_dir + '/' + project_module.get_name(:app_files_dir))
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
  project_module = ProjectModule.find_by_name(name)
  settings = JSON.parse(File.read(project_module.get_path(:settings)).as_json)
  settings[setting_name].should == srid
end

And /^I have database "([^"]*)" for "([^"]*)"$/ do |db, project_module|
  p = ProjectModule.find_by_name(project_module)
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
  project_module = ProjectModule.find_by_name(name)
  project_module.db.update_list_of_users(user, User.first.id)
end

And /^I click "([^"]*)" for "([^"]*)"$/ do |button, dir|
  find(:xpath, "//a[contains(text(), '#{dir}')]/../following-sibling::span/div/a[contains(text(), '#{button}')]").click
end

And /^I attach project module file "([^"]*)" for "([^"]*)"$/ do |file, dir|
  all(:xpath, "//a[contains(text(), '#{dir}')]/../following-sibling::span/div/div/form/div/following-sibling::div/input[1]").first.set Rails.root.join("features/assets/#{file}")
  all(:xpath, "//a[contains(text(), '#{dir}')]/../following-sibling::span/div/div/form/div/following-sibling::div/input[2]").first.click
end

Then /^I upload project module files$/ do |table|
  table.hashes.each do |hash|
    step "I click \"upload file\" for \"#{hash[:dir]}\""
    step "I attach project module file \"#{hash[:file]}\" for \"#{hash[:dir]}\""
  end
end

Then /^I should see project module files$/ do |table|
  table.hashes.each do |hash|
    page.should have_xpath("//div[@class='dir clearfix'][./div[@class='dir-header']/h3/span/a[text()='#{hash[:dir]}']]/ul/li/a[contains(text(), '#{hash[:file]}')]")
  end
end

Then /^I should not see project module files$/ do |table|
  table.hashes.each do |hash|
    page.should_not have_xpath("//div[@class='dir clearfix'][./div[@class='dir-header']/h3/span/a[text()='#{hash[:dir]}']]/ul/li/a[contains(text(), '#{hash[:file]}')]")
  end
end

And /^I enter directory "([^"]*)" for "([^"]*)"$/ do |child_dir, dir|
  all(:xpath, "//a[contains(text(), '#{dir}')]/../following-sibling::span/div/div/form/div/following-sibling::div/input[1]").last.set child_dir
  all(:xpath, "//a[contains(text(), '#{dir}')]/../following-sibling::span/div/div/form/div/following-sibling::div/input[2]").last.click
end

Then /^I create project module directories$/ do |table|
  table.hashes.each do |hash|
    step "I click \"create directory\" for \"#{hash[:dir]}\""
    step "I enter directory \"#{hash[:child_dir]}\" for \"#{hash[:dir]}\""
  end
end

Then /^I should see project module directories$/ do |table|
  table.hashes.each do |hash|
    page.should have_xpath("//div[@class='dir clearfix'][./div[@class='dir-header']/h3/span/a[text()='#{hash[:dir]}']]/ul/div[@class='dir clearfix']/div[@class='dir-header']/h3/span/a[text()='#{hash[:child_dir]}']")
  end
end

Then /^I should not see project module directories$/ do |table|
  table.hashes.each do |hash|
    page.should_not have_xpath("//div[@class='dir clearfix'][./div[@class='dir-header']/h3/span/a[text()='#{hash[:dir]}']]/ul/div[@class='dir clearfix']/div[@class='dir-header']/h3/span/a[text()='#{hash[:child_dir]}']")
  end
end

And /^I delete project module file "([^"]*)" for "([^"]*)"$/ do |file, dir|
  WAIT_RANGE.each do
    if all(:xpath, "//div[@class='dir clearfix'][./div[@class='dir-header']/h3/span/a[text()='#{dir}']]/ul/li[./a[contains(text(), '#{file}')]]/following-sibling::a").size == 0
      sleep(1)
    else
      all(:xpath, "//div[@class='dir clearfix'][./div[@class='dir-header']/h3/span/a[text()='#{dir}']]/ul/li[./a[contains(text(), '#{file}')]]/following-sibling::a").first.click
      break
    end
  end
end

And /^I delete root directory$/ do
  WAIT_RANGE.each do
    if all(:xpath, "//div[@class='dir clearfix']/div[@class='dir-header']/h3/span/a[text()='data']/../following-sibling::span/a").size == 0
      sleep(1)
    else
      all(:xpath, "//div[@class='dir clearfix']/div[@class='dir-header']/h3/span/a[text()='data']/../following-sibling::span/a").first.click
      break
    end
  end
  step 'I confirm'
end

Then /^I delete project module files$/ do |table|
  table.hashes.each do |hash|
    step "I delete project module file \"#{hash[:file]}\" for \"#{hash[:dir]}\""
    step 'I confirm'
  end
end

And /^I delete project module directory "([^"]*)" for "([^"]*)"$/ do |child_dir, dir|
  find(:xpath, "//div[@class='dir clearfix'][./div[@class='dir-header']/h3/span/a[text()='#{dir}']]/ul/div[@class='dir clearfix']/div[@class='dir-header']/h3/span/a[text()='#{child_dir}']/../following-sibling::span/a").click
end

Then /^I delete project module directories$/ do |table|
  table.hashes.each do |hash|
    step "I delete project module directory \"#{hash[:child_dir]}\" for \"#{hash[:dir]}\""
    step 'I confirm'
  end
end

And /^I confirm$/ do
  checked = nil
  WAIT_RANGE.each do
    begin
      page.driver.browser.switch_to.alert.accept
      checked = true
      break
    rescue
      sleep(1)
    end
  end
  page.driver.browser.switch_to.alert.accept unless checked
end

And /^I should see dialog "([^"]*)"$/ do |message|
  checked = nil
  WAIT_RANGE.each do
    begin
      page.driver.browser.switch_to.alert.text.should == message
      checked = true
      break
    rescue
      sleep(1)
    end
  end
  page.driver.browser.switch_to.alert.text.should == message unless checked
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

And /^files are locked for "([^"]*)"$/ do |name|
  project_module = ProjectModule.find_by_name(name)
  project_module.data_mgr.wait_for_lock
end

And /^database is locked for "([^"]*)"$/ do |name|
  project_module = ProjectModule.find_by_name(name)
  project_module.db_mgr.wait_for_lock
end

And /^settings is locked for "([^"]*)"$/ do |name|
  project_module = ProjectModule.find_by_name(name)
  project_module.settings_mgr.wait_for_lock
end

And /^I select records$/ do |table|
  table.hashes.each do |hash|
    find(:xpath, "//input[@type='checkbox'][./following-sibling::li/a[contains(text(),\"#{hash[:name]}\")]]").set(true)
  end
end

And /^I select the "([^"]*)" record to merge to$/ do |first|
  first(:css, "#select-#{first}").click
end

And /^I select merge fields$/ do |table|
  table.hashes.each do |hash|
    first(:xpath, "//td[contains(@class, 'merge-#{hash[:column]}')]/input[@type='radio'][./following-sibling::div/div/table/tbody/tr/td/h5[contains(text(), '#{hash[:field]}')]]").click
  end
end

And /^I update field "([^"]*)" of type "([^"]*)" with values "([^"]*)"$/ do |field, type, values_str|
  values = values_str.split(';')
  values = [''] if values.empty?
  values.each_with_index do |value, index|
    value.strip!
    if type == 'vocab'
      WAIT_RANGE.each do
        break if all(:xpath, "//div[@class = 'row-fluid']/label/h4[contains(text(),'#{field}')]/../../div/div/div/select[contains(@name, '#{type}')]").size > 0
      end
      all(:xpath, "//div[@class = 'row-fluid']/label/h4[contains(text(),'#{field}')]/../../div/div/div/select[contains(@name, '#{type}')]/option[contains(text(),'#{value}')]")[index].select_option
    else
      WAIT_RANGE.each do
        break if all(:xpath, "//div[@class = 'row-fluid']/label/h4[contains(text(),'#{field}')]/../../div/input[contains(@name,'#{type}')]").size > 0
      end
      all(:xpath, "//div[@class = 'row-fluid']/label/h4[contains(text(),'#{field}')]/../../div/input[contains(@name,'#{type}')]")[index].set value
    end
  end
end

And /^I click on update for attribute with field "([^"]*)"$/ do |field|
  first(:xpath, "//div[@class = 'row-fluid']/label/h4[contains(text(),'#{field}')]/../../div/input[@value='Update']").click
end

And /^I update fields with values$/ do |table|
  table.hashes.each do |hash|
    step "I update field \"#{hash[:field]}\" of type \"#{hash[:type]}\" with values \"#{hash[:values]}\""
    step "I click on update for attribute with field \"#{hash[:field]}\""
    sleep(1)
  end
end

And /^I should see field "([^"]*)" of type "([^"]*)" with values "([^"]*)"$/ do |field, type, values_str|
  values = values_str.split(';')
  values = [''] if values.empty?
  values.each_with_index do |value, index|
    value.strip!
    if type == 'vocab'
      WAIT_RANGE.each do
        break if all(:xpath, "//div[@class = 'row-fluid']/label/h4[contains(text(),'#{field}')]/../../div/div/div/select[contains(@name, '#{type}')]").size > 0
      end
      all(:xpath, "//div[@class = 'row-fluid']/label/h4[contains(text(),'#{field}')]/../../div/div/div/select[contains(@name, '#{type}')]/option[contains(text(),'#{value}')]")[index].text.should == value
    else
      WAIT_RANGE.each do
        break if all(:xpath, "//div[@class = 'row-fluid']/label/h4[contains(text(),'#{field}')]/../../div/input[contains(@name,'#{type}')]").size > 0
      end
      all(:xpath, "//div[@class = 'row-fluid']/label/h4[contains(text(),'#{field}')]/../../div/input[contains(@name,'#{type}')]")[index].value.should == value
    end
  end
end

And /^I should see fields with values$/ do |table|
  table.hashes.each do |hash|
    step "I should see field \"#{hash[:field]}\" of type \"#{hash[:type]}\" with values \"#{hash[:values]}\""
  end
end

And /^I should see field "([^"]*)" with error "([^"]*)"$/ do |field, error|
  WAIT_RANGE.each do
    break if all(:xpath, "//div[contains(@class, 'row-fluid')][./label/h4[contains(text(), '#{field}')]]/following-sibling::div/li[contains(text(), '#{error}')]").size > 0
  end
  all(:xpath, "//div[contains(@class, 'row-fluid')][./label/h4[contains(text(), '#{field}')]]/following-sibling::div/li[contains(text(), '#{error}')]").size.should == 1
end

And /^I should see fields with errors$/ do |table|
  table.hashes.each do |hash|
    step "I should see field \"#{hash[:field]}\" with error \"#{hash[:error]}\""
  end
end

And /^I wait for popup to close$/ do

end

And /^I refresh page$/ do
  visit(current_path)
end
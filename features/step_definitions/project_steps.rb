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
  Dir.mkdir('tmp/projects')
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
  dir_name = Project.find_by_name(name).dir_name
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

Then /^I should see json for "([^"]*)" archived file$/ do |name|
  page.should have_content(Project.find_by_name(name).archive_info.to_json)
end

Then /^I should download file for "([^"]*)"$/ do |name|
  project = Project.find_by_name(name)
  page.response_headers["Content-Disposition"].should == "attachment; filename=\"" + Project.filename + "\""
  file = File.open(project.filepath, 'r')
  page.source == file.read
end

And /^I upload database "([^"]*)" to (.*) succeeds$/ do |db_file, name|
  project = Project.find_by_name(name)
  upload_db_file = File.open(File.expand_path("../../assets/" + db_file + ".tar.gz", __FILE__))
  md5 = Digest::MD5.hexdigest(File.read(upload_db_file))
  project.check_sum(upload_db_file,md5).should be_true
end

Then /^I should have stored "([^"]*)" into (.*)$/ do |db_file, name|
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
  md5 = Digest::MD5.hexdigest(File.read(upload_db_file)) + '55'
  project.check_sum(upload_db_file,md5).should be_false
end

Then /^I should see json for "([^"]*)" archived db file$/ do |name|
  page.should have_content(Project.find_by_name(name).archive_db_info.to_json)
end

Then /^I should download db file for "([^"]*)"$/ do |name|
  project = Project.find_by_name(name)
  page.response_headers["Content-Disposition"].should == "attachment; filename=\"" + Project.db_file_name + "\""
  file = File.open(project.db_file_path, 'r')
  page.source == file.read
end

And /^I have synced (.*) times for "([^"]*)"$/ do |num, name|
  project = Project.find_by_name(name)
  (1..num.to_i).each do |i|
    Database.execute_query(project.db_path, "insert into version (versionnum, uploadtimestamp, userid, ismerged) select #{i}, CURRENT_TIMESTAMP, 0, 1;")
  end
  p Database.current_version(project.db_path)
end

Then /^I should see json for "([^"]*)" archived file with version (.*)$/ do |name, version|
  page.should have_content(Project.find_by_name(name).archive_info.to_json)
  page.should have_content("\"version\":#{version}")
end

Then /^I should see json for "([^"]*)" archived db file with version (.*)$/ do |name, version|
  page.should have_content(Project.find_by_name(name).archive_db_info.to_json)
  page.should have_content("\"version\":#{version}")
end

When /^I click on "([^"]*)"$/ do |name|
  project = Project.find_by_name(name)
  visit ("/projects/" + project.id.to_s)
end
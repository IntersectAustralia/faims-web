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
  page.response_headers["Content-Disposition"].should == "attachment; filename=\"" + project.filename + "\""
  file = File.open(project.filepath, 'r')
  page.source == file.read
end

And /^I upload database "([^"]*)" to (.*)$/ do |db_file, name|
  project = Project.find_by_name(name)
  upload_db_file = File.open(File.expand_path("../../assets/" + db_file + ".tar.gz", __FILE__))
  md5 = Digest::MD5.hexdigest(File.read(upload_db_file))
  project.check_sum(upload_db_file,md5).should be_true
end

Then /^I should have merged "([^"]*)" into (.*)$/ do |db_file, name|
  project = Project.find_by_name(name)
  archived_upload_db_file = File.open(File.expand_path("../../assets/" + db_file + ".tar.gz", __FILE__), 'r+')
  upload_db_file = File.open(File.expand_path("../../assets/" + db_file + ".sqlite3", __FILE__), 'r+')
  proj_db_file = File.open(File.expand_path(project.dir_path+"/db.sqlite3", __FILE__), 'r+')
  temp_db_file = backup_database(proj_db_file)
  project.merge_database(archived_upload_db_file)

  is_database_merged(proj_db_file, temp_db_file, upload_db_file).should be_true
end

And /^I upload corrupted database "([^"]*)" to (.*)$/ do |db_file, name|
  project = Project.find_by_name(name)
  upload_db_file = File.open(File.expand_path("../../assets/" + db_file + ".tar.gz", __FILE__), 'r+')
  md5 = Digest::MD5.hexdigest(File.read(upload_db_file)) + '55'
  project.check_sum(upload_db_file,md5).should be_false
end

Then /^I should have not merged "([^"]*)" into (.*)$/ do |db_file, name|
  project = Project.find_by_name(name)
  #archived_upload_db_file = File.open(File.expand_path("../../assets/" + db_file + ".tar.gz", __FILE__), 'r+')
  upload_db_file = File.open(File.expand_path("../../assets/" + db_file + ".sqlite3", __FILE__), 'r+')
  proj_db_file = File.open(File.expand_path(project.dir_path+"/db.sqlite3", __FILE__), 'r+')
  temp_db_file = backup_database(proj_db_file)

  is_database_merged(proj_db_file, temp_db_file, upload_db_file).should be_false
end

Then /^I should see json for "([^"]*)" archived db file$/ do |name|
  page.should have_content(Project.find_by_name(name).archive_db_info.to_json)
end

Then /^I should download db file for "([^"]*)"$/ do |name|
  project = Project.find_by_name(name)
  page.response_headers["Content-Disposition"].should == "attachment; filename=\"" + project.db_file_name + "\""
  file = File.open(project.db_file_path, 'r')
  page.source == file.read
end
When /^I click on "([^"]*)"$/ do |name|
  project = Project.find_by_name(name)
  visit ("/projects/" + project.id.to_s)
end
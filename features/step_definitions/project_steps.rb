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
  dirname = Project.find_by_name(name).dirname
  File.directory?(Rails.root.join('tmp/projects', dirname)).should be_true
  File.exists?(Rails.root.join('tmp/projects', dirname, 'db.sqlite3')).should be_true
  File.exists?(Rails.root.join('tmp/projects', dirname, 'ui_schema.xml')).should be_true
  File.exists?(Rails.root.join('tmp/projects', dirname, 'project.settings')).should be_true
end

Then /^I should see json for projects$/ do
  page.should have_content(Project.all.to_json)
end

Then /^I should see json for "([^"]*)" archived file$/ do |name|
end

Then /^I should download file for "([^"]*)"$/ do |name|
end

def make_project(name)
  p = Project.create(:name => name)
  dirname = p.dirname
  `mkdir #{Rails.root.join('tmp', 'projects', dirname).to_s}`
  `touch #{Rails.root.join('tmp', 'projects', dirname, 'db.sqlite3').to_s}`
  `touch #{Rails.root.join('tmp', 'projects', dirname, 'ui_schema.xml').to_s}`
  `touch #{Rails.root.join('tmp', 'projects', dirname, 'project.settings').to_s}`
  p.archive
end

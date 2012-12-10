And /^I pick file "([^"]*)" for "([^"]*)"$/ do |file, field|
  attach_file(field, File.expand_path("../../assets/" + file, __FILE__)) unless file.blank?
end

When /^(?:|I )press "([^"]*)" for "([^"]*)"$/ do |button, field|
  first(:xpath, "//label[contains(., '#{field}')]/..").find(:css, ".btn[value='#{button}']").click
end

And /^I have a projects dir$/ do
  FileUtils.rm_rf('tmp/projects')
  Dir.mkdir('tmp/projects')
end

And /^I should not see errors for upload "([^"]*)"$/ do |field|
  page.should have_no_selector(:xpath, "//label[contains(., '#{field}')]/../../span[@class='help-inline']")
end

And /^I have project "([^"]*)"$/ do |name|
  Project.create(:name => name)
end

Then /^I should see "([^"]*)" with error "([^"]*)"$/ do |field, error|
  page.should have_selector(:xpath, "//label[contains(., '#{field}')]/../span[@class='help-inline' and text()=\"#{error}\"]")
end

Given /^I have projects$/ do |table|
  table.hashes.each do |hash|
    Project.create(:name => hash[:name])
  end
end

Then /^I should see projects$/ do |table|
  table.hashes.each do |hash|
    Project.find_by_name(hash[:name]).should_not be_nil
  end
end

Then /^I have project files for "([^"]*)"$/ do |name|
  File.directory?(Rails.root.join('tmp/projects', name)).should be_true
  File.exists?(Rails.root.join('tmp/projects', name, 'db.sqlite3')).should be_true
  File.exists?(Rails.root.join('tmp/projects', name, 'ui_schema.xml')).should be_true
  File.exists?(Rails.root.join('tmp/projects', name, 'project.settings')).should be_true
end

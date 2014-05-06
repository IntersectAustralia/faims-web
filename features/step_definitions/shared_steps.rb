Then /^I should see "([^"]*)" table with$/ do |table_id, expected_table|
  actual = find("table##{table_id}").all('tr').map { |row| row.all('th, td').map { |cell| cell.text.strip } }
  expected_table.diff!(actual)
end

Then /^I should see field "([^"]*)" with value "([^"]*)"$/ do |field, value|
  # this assumes you're using the helper to render the field which sets the div id based on the field name
  div_id = field.tr(" ,", "_").downcase
  # use a quoted selector so it doesn't pass through the selectors.rb logic
  div_scope = "\"div#display_#{div_id}\""
  with_scope(div_scope) do
    page.should have_content(field)
    page.should have_content(value)
  end
end

Then /^I should see row "([^"]*)" with value "([^"]*)"$/ do |field, value|
  within(first(:css, "tr:contains('#{field}')")) do
    find(:css, "td:contains('#{value}')")
  end
end

Then /^I should see fields displayed$/ do |table|
  # as above, this assumes you're using the helper to render the field which sets the div id based on the field name
  table.hashes.each do |row|
    field = row[:field]
    value = row[:value]
    div_id = field.tr(" ,", "_").downcase
    div_scope = "div#display_#{div_id}"
    with_scope(div_scope) do
      page.should have_content(field)
      page.should have_content(value)
    end
  end
end

Then /^I should see button "([^"]*)"$/ do |arg1|
  page.should have_xpath("//input[@value='#{arg1}']")
end

Then /^I should see image "([^"]*)"$/ do |arg1|
  page.should have_xpath("//img[contains(@src, #{arg1})]")
end

Then /^I should not see button "([^"]*)"$/ do |arg1|
  page.should have_no_xpath("//input[@value='#{arg1}']")
end

Then /^I should see button "([^"]*)" within "([^\"]*)"$/ do |button, scope|
  with_scope(scope) do
    page.should have_xpath("//input[@value='#{button}']")
  end
end

Then /^I should not see button "([^"]*)" within "([^\"]*)"$/ do |button, scope|
  with_scope(scope) do
    page.should have_no_xpath("//input[@value='#{button}']")
  end
end

Then /^I should get a security error "([^"]*)"$/ do |message|
  page.should have_content(message)
  current_path = URI.parse(current_url).path
  current_path.should == path_to("the home page")
end

Then /^I should see link "([^"]*)"$/ do |text|
  page.should have_link(text)
end

Then /^I should not see link "([^"]*)"$/ do |text|
  page.should_not have_link(text)
end

Then /^I should see link "([^\"]*)" within "([^\"]*)"$/ do |text, scope|
  with_scope(scope) do
    page.should have_link(text)
  end
end

Then /^I should not see link "([^\"]*)" within "([^\"]*)"$/ do |text, scope|
  with_scope(scope) do
    page.should_not have_link(text)
  end
end

When /^(?:|I )deselect "([^"]*)" from "([^"]*)"(?: within "([^"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    unselect(value, :from => field)
  end
end

When /^I select$/ do |table|
  table.hashes.each do |hash|
    When "I select \"#{hash[:value]}\" from \"#{hash[:field]}\""
  end
end

When /^I fill in$/ do |table|
  table.hashes.each do |hash|
    When "I fill in \"#{hash[:field]}\" with \"#{hash[:value]}\""
  end
end

# can be helpful for @javascript features in lieu of "show me the page
Then /^pause$/ do
  puts "Press Enter to continue"
  STDIN.getc
end

Given /^I am the admin$/ do |table|
  table.hashes.each do |hash|
    r = Role.create(name: 'superuser')
    u = User.new(hash.merge({password: "Pas$w0rd", password_confirmation: "Pas$w0rd"}))
    u.activate
    u.role = r
    u.save!
  end
end

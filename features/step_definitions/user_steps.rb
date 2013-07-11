Then /^I should see users$/ do |table|
  table.hashes.each do |hash|
    find(:xpath, "//td[contains(., '#{hash[:first_name]}')]/..//td[contains(., '#{hash[:last_name]}')]").should_not be_nil
    find(:xpath, "//td[contains(., '#{hash[:first_name]}')]/..//td[contains(., '#{hash[:email]}')]").should_not be_nil
  end
end

And /^I delete user "([^"]*)"$/ do |email|
  link = find(:xpath, "//td[contains(., '#{email}')]/..//a[contains(., 'Delete')]")
  link.click
end


And /^I cannot delete user "([^"]*)"$/ do |email|
  expect { find(:xpath, "//td[contains(., '#{email}')]/..//a[contains(., 'Delete')]") }.to raise_error
end
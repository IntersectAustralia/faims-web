Then /^I should get the following security outcomes$/ do |table|
  table.hashes.each do |hash|
    page_to_visit = hash[:page]
    outcome       = hash[:outcome]
    message       = hash[:message]
    visit path_to(page_to_visit)
    if outcome == "error"
      page.should have_content(message)
      current_path = URI.parse(current_url).path
      current_path.should == path_to("the home page")
    else
      current_path = URI.parse(current_url).path
      current_path.should == path_to(page_to_visit)
    end

  end
end

Given /^I have the usual roles and permissions$/ do
  
  super_role = "superuser"
  # TODO: adjust roles and permissions here
  Role.create!(:name => super_role)
  Role.create!(:name => "Researcher")

  create_permission("User", "read", [super_role])
  create_permission("User", "update_role", [super_role])
  create_permission("User", "activate_deactivate", [super_role])
  create_permission("User", "admin", [super_role])
  create_permission("User", "reject", [super_role])
  create_permission("User", "approve", [super_role])

end


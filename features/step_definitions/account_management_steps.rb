Given /^I have access requests$/ do |table|
  table.hashes.each do |hash|
    FactoryGirl.create(:user, hash.merge(:status => 'U'))
  end
end

Given /^I have users$/ do |table|
  table.hashes.each do |hash|
    FactoryGirl.create(:user, hash.merge(:status => 'A'))
  end
end

Given /^I have roles$/ do |table|
  table.hashes.each do |hash|
    FactoryGirl.create(:role, hash)
  end
end

And /^I have role "([^"]*)"$/ do |name|
  FactoryGirl.create(:role, :name => name)
end


Given /^I have permissions$/ do |table|
  table.hashes.each do |hash|
    create_permission_from_hash(hash)
  end
end

def create_permission_from_hash(hash)
  roles = hash[:roles].split(",")
  create_permission(hash[:entity], hash[:action], roles)
#  create_permission(hash[:entity], hash[:action], hash[:roles])
end

def create_permission(entity, action, roles)
  permission = Permission.new(:entity => entity, :action => action)
  permission.save!
  roles.each do |role_name|
    role = Role.where(:name => role_name).first
    role.permissions << permission
    role.save!
  end
end

Given /^"([^"]*)" has role "([^"]*)"$/ do |email, role|
  user = User.where(:email => email).first 
  role = Role.where(:name => role).first
  user.role = role
  user.save!(:validate => false)
end

When /^I follow "Approve" for "([^"]*)"$/ do |email|
  user = User.where(:email => email).first
  click_link("approve_#{user.id}")
end

When /^I follow "Reject" for "([^"]*)"$/ do |email|
  user = User.where(:email => email).first
  click_link("reject_#{user.id}")
end

When /^I follow "Reject as Spam" for "([^"]*)"$/ do |email|
  user = User.where(:email => email).first
  click_link("reject_as_spam_#{user.id}")
end

When /^I follow "View Details" for "([^"]*)"$/ do |email|
  user = User.where(:email => email).first
  click_link("view_#{user.id}")
end

When /^I follow "Edit role" for "([^"]*)"$/ do |email|
  user = User.where(:email => email).first
  click_link("edit_role_#{user.id}")
end

Given /^"([^"]*)" is deactivated$/ do |email|
  user = User.where(:email => email).first
  user.deactivate
end

Given /^"([^"]*)" is pending approval$/ do |email|
  user = User.where(:email => email).first
  user.status = "U"
  user.save!
end

Given /^"([^"]*)" is rejected as spam$/ do |email|
  user = User.where(:email => email).first
  user.reject_access_request
end

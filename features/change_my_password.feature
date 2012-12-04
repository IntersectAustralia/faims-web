Feature: Change my password
  In order to keep my account secure
  As a user
  I want to change my password

  Background:
    Given I have a user "georgina@intersect.org.au"
    And I am logged in as "georgina@intersect.org.au"

  Scenario: Change password
    Given I am on the home page
    When I follow "Change My Password"
    And I fill in "New password" with "Pass.123"
    And I fill in "Confirm new password" with "Pass.123"
    And I fill in "Current password" with "Pas$w0rd"
    And I press "Update"
    Then I should see "Your password has been updated."
    And I should see link "Logout"
    And I should be able to log in with "georgina@intersect.org.au" and "Pass.123"

  Scenario: Change password not allowed if current password is empty
    Given I am on the home page
    When I follow "Change My Password"
    And I fill in "New password" with "Pass.123"
    And I fill in "Confirm new password" with "Pass.123"
    And I press "Update"
    Then I should see "Current password can't be blank"
    And I should see "Change Password"
    And I should be able to log in with "georgina@intersect.org.au" and "Pas$w0rd"

  Scenario: Change password not allowed if current password is incorrect
    Given I am on the home page
    When I follow "Change My Password"
    And I fill in "New password" with "Pass.123"
    And I fill in "Confirm new password" with "Pass.123"
    And I fill in "Current password" with "asdf"
    And I press "Update"
    Then I should see "Current password is invalid"
    And I should be able to log in with "georgina@intersect.org.au" and "Pas$w0rd"

  Scenario: Change password not allowed if confirmation doesn't match new password
    Given I am on the home page
    When I follow "Change My Password"
    And I fill in "New password" with "Pass.123"
    And I fill in "Confirm new password" with "Pass.1233"
    And I fill in "Current password" with "Pas$w0rd"
    And I press "Update"
    Then I should see "Password doesn't match confirmation"
    And I should be able to log in with "georgina@intersect.org.au" and "Pas$w0rd"

  Scenario: Change password not allowed if new password blank
    Given I am on the home page
    When I follow "Change My Password"
    And I fill in "Current password" with "Pas$w0rd"
    And I press "Update"
    Then I should see "Password can't be blank"
    And I should be able to log in with "georgina@intersect.org.au" and "Pas$w0rd"

  Scenario: Change password not allowed if new password doesn't meet password rules
    Given I am on the home page
    When I follow "Change My Password"
    And I fill in "New password" with "Pass.abc"
    And I fill in "Confirm new password" with "Pass.abc"
    And I fill in "Current password" with "Pas$w0rd"
    And I press "Update"
    Then I should see "Password must be between 6 and 20 characters long and contain at least one uppercase letter, one lowercase letter, one digit and one symbol"
    And I should be able to log in with "georgina@intersect.org.au" and "Pas$w0rd"


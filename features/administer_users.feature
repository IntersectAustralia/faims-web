Feature: Administer users
  In order to allow users to access the system
  As an administrator
  I want to administer users

  Background:
    Given I am the admin
      | first_name | last_name | email                     |
      | Georgina   | Edwards   | georgina@intersect.org.au |
    Given I have users
      | first_name | last_name | email                  |
      | User1      | Last1     | user1@intersect.org.au |
    And I am logged in as "georgina@intersect.org.au"

  Scenario: View a list of users
    When I am on the list users page
    Then I should see "users" table with
      | First name | Last name | Email                     | Role      |
      | Georgina   | Edwards   | georgina@intersect.org.au | superuser |
      | User1      | Last1     | user1@intersect.org.au    | user      |

  Scenario: View user details
    And I am on the list users page
    When I follow "View Details" for "georgina@intersect.org.au"
    Then I should see row "Email" with value "georgina@intersect.org.au"
    And I should see row "First name" with value "Georgina"
    And I should see row "Last name" with value "Edwards"
    And I should see row "Role" with value "superuser"

  Scenario: Go back from user details
    Given I am on the list users page
    When I follow "View Details" for "georgina@intersect.org.au"
    And I follow "Back"
    Then I should be on the list users page

  Scenario: Editing own role has alert
    Given I am on the list users page
    When I follow "View Details" for "georgina@intersect.org.au"
    And I follow "Edit Role"
    Then I should see "You are changing the role of the user you are logged in as."

  Scenario: Edit users information
    And I am on the list users page
    When I follow "View Details" for "user1@intersect.org.au"
    And I follow "Edit Details"
    And I fill in "First Name" with "Fred"
    And I fill in "Last Name" with "Bloggs"
    And I press "Update"
    Then I should see "Account details have been successfully updated."
    And I should be on the list users page
    Then I should see "users" table with
      | First name | Last name | Email                     | Role      |
      | Georgina   | Edwards   | georgina@intersect.org.au | superuser |
      | Fred       | Bloggs    | user1@intersect.org.au    | user      |

  Scenario: Edit users information Validation error
    And I am on the list users page
    When I follow "View Details" for "user1@intersect.org.au"
    And I follow "Edit Details"
    And I fill in "First Name" with ""
    And I fill in "Last Name" with "Bloggs"
    And I press "Update"
    Then I should see "First name can't be blank"

  Scenario: Change password
    And I am on the list users page
    When I follow "View Details" for "user1@intersect.org.au"
    And I follow "Change Password"
    And I fill in "New password" with "Pass.123"
    And I fill in "Confirm new password" with "Pass.123"
    And I press "Update"
    Then I should see "Password has been updated."
    And I should see link "Logout"
    And I should be able to log in with "user1@intersect.org.au" and "Pass.123"

  Scenario: Change password not allowed if confirmation doesn't match new password
    And I am on the list users page
    When I follow "View Details" for "user1@intersect.org.au"
    And I follow "Change Password"
    And I fill in "New password" with "Pass.123"
    And I fill in "Confirm new password" with "Pass.1233"
    And I press "Update"
    Then I should see "Password doesn't match confirmation"
    And I should be able to log in with "user1@intersect.org.au" and "Pas$w0rd"

  Scenario: Change password not allowed if new password blank
    And I am on the list users page
    When I follow "View Details" for "user1@intersect.org.au"
    And I follow "Change Password"
    And I press "Update"
    Then I should see "Password can't be blank"
    And I should be able to log in with "user1@intersect.org.au" and "Pas$w0rd"

  Scenario: Change password not allowed if new password doesn't meet password rules
    And I am on the list users page
    When I follow "View Details" for "user1@intersect.org.au"
    And I follow "Change Password"
    And I fill in "New password" with "Pass.abc"
    And I fill in "Confirm new password" with "Pass.abc"
    And I press "Update"
    Then I should see "Password must be between 6 and 20 characters long and contain at least one uppercase letter, one lowercase letter, one digit and one symbol"
    And I should be able to log in with "user1@intersect.org.au" and "Pas$w0rd"

  Scenario: Only admin users can edit details or change passwords
    And I should be able to log in with "user1@intersect.org.au" and "Pas$w0rd"
    And I am on the list users page
    When I follow "View Details" for "georgina@intersect.org.au"
    Then I should not see link "Edit Details"
    Then I should not see link "Change Password"

  Scenario: User cannot edit their own details or change passwords via viewing details
    And I am on the list users page
    When I follow "View Details" for "georgina@intersect.org.au"
    Then I should not see link "Edit Details"
    Then I should not see link "Change Password"

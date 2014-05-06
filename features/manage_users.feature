Feature: Manage users
  In order to allow users to access the system
  As an administrator
  I want to manage users

  Background:
    Given I am the admin
      | first_name | last_name | email                       |
      | Georgina   | Edwards   | faimsadmin@intersect.org.au |
    Given I have users
      | first_name | last_name | email                  |
      | User1      | Last1     | user1@intersect.org.au |
      | User2      | Last2     | user2@intersect.org.au |
    And I am logged in as "faimsadmin@intersect.org.au"
    And I follow "Show Users"

  Scenario: View users list
    Then I should see "users" table with
      | First name | Last name | Email                       | Role      |
      | Georgina   | Edwards   | faimsadmin@intersect.org.au | superuser |
      | User1      | Last1     | user1@intersect.org.au      | user      |
      | User2      | Last2     | user2@intersect.org.au      | user      |

  Scenario: Add new user
    When I follow "Show Users"
    And I click on "Add User"
    And I fill in "First Name" with "User3"
    And I fill in "Last Name" with "Last3"
    And I fill in "Email" with "user3@intersect.org.au"
    And I fill in "Password" with "Pass.123"
    And I fill in "Password Confirmation" with "Pass.123"
    And I press "Submit"
    Then I should see "users" table with
      | First name | Last name | Email                       | Role      |
      | Georgina   | Edwards   | faimsadmin@intersect.org.au | superuser |
      | User1      | Last1     | user1@intersect.org.au      | user      |
      | User2      | Last2     | user2@intersect.org.au      | user      |
      | User3      | Last3     | user3@intersect.org.au      | user      |

  Scenario: Cannot add user if not admin
    Given I logout
    And I am logged in as "user1@intersect.org.au"
    And I am on the add user page
    Then I should see "You are not authorized to access this page."

  Scenario Outline: Cannot add user due to validation errors
    When I follow "Show Users"
    And I click on "Add User"
    And I fill in "<field>" with "<value>"
    And I press "Submit"
    Then I should see "<field>" with error "<error>"
  Examples:
    | field      | value                  | error                  |
    | First Name |                        | can't be blank         |
    | Last Name  |                        | can't be blank         |
    | Email      |                        | can't be blank         |
    | Email      | user1@intersect.org.au | has already been taken |
    | Email      | user1                  | is invalid             |
    | Password   |                        | can't be blank         |

  Scenario Outline: Cannot add user due to password errors
    When I follow "Show Users"
    And I click on "Add User"
    And I fill in "<field1>" with "<value1>"
    And I fill in "<field2>" with "<value2>"
    And I press "Submit"
    Then I should see "<field1>" with error "<error>"
  Examples:
    | field1   | field2                | value1   | value2   | error                                                                                                                              |
    | Password | Password Confirmation | dd       |          | doesn't match confirmation                                                                                                         |
    | Password | Password Confirmation | dd       | dd       | is too short (minimum is 6 characters)                                                                                             |
    | Password | Password Confirmation | dddddddd | dddddddd | must be between 6 and 20 characters long and contain at least one uppercase letter, one lowercase letter, one digit and one symbol |

  Scenario: View user details
    When I follow "View Details" for "faimsadmin@intersect.org.au"
    Then I should see row "Email" with value "faimsadmin@intersect.org.au"
    And I should see row "First name" with value "Georgina"
    And I should see row "Last name" with value "Edwards"
    And I should see row "Role" with value "superuser"
    When I follow "Back"
    Then I should be on the list users page

  Scenario: Edit users details
    When I follow "View Details" for "user1@intersect.org.au"
    And I follow "Edit Details"
    And I fill in "First Name" with "Fred"
    And I fill in "Last Name" with "Bloggs"
    When I press "Update"
    Then I should see "Account details have been successfully updated."
    And I should be on the list users page
    And I should see "users" table with
      | First name | Last name | Email                       | Role      |
      | Georgina   | Edwards   | faimsadmin@intersect.org.au | superuser |
      | Fred       | Bloggs    | user1@intersect.org.au      | user      |
      | User2      | Last2     | user2@intersect.org.au      | user      |

  Scenario: Cannot add user if not admin
    Given I logout
    And I am logged in as "user1@intersect.org.au"
    And I am on the edit details page for user2@intersect.org.au
    Then I should see "You are not authorized to access this page."

  Scenario Outline: Cannot edit users details due to validation errors
    When I follow "View Details" for "user1@intersect.org.au"
    When I follow "Edit My Details"
    And I fill in "<field>" with "<value>"
    And I press "Update"
    Then I should see "<error>"
  Examples:
    | field      | value | error                     |
    | First Name |       | First name can't be blank |
    | Last Name  |       | Last name can't be blank  |

  Scenario: Change users role
    When I follow "View Details" for "user1@intersect.org.au"
    And I follow "Edit Role"
    And I select "superuser" from "Role"
    And I press "Save"
    And I follow "Back"
    Then I should be on the list users page
    And I should see "users" table with
      | First name | Last name | Email                       | Role      |
      | Georgina   | Edwards   | faimsadmin@intersect.org.au | superuser |
      | User1      | Last1     | user1@intersect.org.au      | superuser |
      | User2      | Last2     | user2@intersect.org.au      | user      |

  Scenario: Cannot change users role if not admin
    Given I logout
    And I am logged in as "user1@intersect.org.au"
    And I am on the edit role page for user2@intersect.org.au
    Then I should see "You are not authorized to access this page."

  Scenario: Show warning if editing own role
    When I follow "View Details" for "faimsadmin@intersect.org.au"
    And I follow "Edit Role"
    Then I should see "You are changing the role of the user you are logged in as."

  Scenario: Change users password
    When I follow "View Details" for "user1@intersect.org.au"
    And I follow "Change Password"
    And I fill in "New password" with "Pass.123"
    And I fill in "Confirm new password" with "Pass.123"
    And I press "Update"
    Then I should see "Password has been updated."
    And I should see link "Logout"
    And I should be able to log in with "user1@intersect.org.au" and "Pass.123"

  Scenario: Cannot change users password if not admin
    Given I logout
    And I am logged in as "user1@intersect.org.au"
    And I am on the change password page for user2@intersect.org.au
    Then I should see "You are not authorized to access this page."

  Scenario: Change users password not allowed if confirmation doesn't match new password
    When I follow "View Details" for "user1@intersect.org.au"
    And I follow "Change Password"
    And I fill in "New password" with "Pass.123"
    And I fill in "Confirm new password" with "Pass.1233"
    And I press "Update"
    Then I should see "Password doesn't match confirmation"
    And I should be able to log in with "user1@intersect.org.au" and "Pas$w0rd"

  Scenario: Change users password not allowed if new password blank
    Given I am on the list users page
    When I follow "View Details" for "user1@intersect.org.au"
    And I follow "Change Password"
    And I press "Update"
    Then I should see "Password can't be blank"
    And I should be able to log in with "user1@intersect.org.au" and "Pas$w0rd"

  Scenario: Change users password not allowed if new password doesn't meet password rules
    When I follow "View Details" for "user1@intersect.org.au"
    And I follow "Change Password"
    And I fill in "New password" with "Pass.abc"
    And I fill in "Confirm new password" with "Pass.abc"
    And I press "Update"
    Then I should see "Password must be between 6 and 20 characters long and contain at least one uppercase letter, one lowercase letter, one digit and one symbol"
    And I should be able to log in with "user1@intersect.org.au" and "Pas$w0rd"

  @javascript
  Scenario: Delete user
    And I follow "Show Users"
    And I delete user "user2@intersect.org.au"
    And I confirm
    Then I should see "users" table with
      | First name | Last name | Email                       | Role      |
      | Georgina   | Edwards   | faimsadmin@intersect.org.au | superuser |
      | User1      | Last1     | user1@intersect.org.au      | user      |

  Scenario: Cannot delete user if not admin
    Given I logout
    And I am logged in as "user1@intersect.org.au"
    And I follow "Show Users"
    And I cannot delete user "user2@intersect.org.au"

  Scenario: Cannot delete logged in user
    Given I follow "Show Users"
    And I cannot delete user "faimsadmin@intersect.org.au"
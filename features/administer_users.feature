Feature: Administer users
  In order to allow users to access the system
  As an administrator
  I want to administer users

  Background:
    Given I am the admin
      | first_name | last_name | email                     |
      | Georgina   | Edwards   | georgina@intersect.org.au |
    And I am logged in as "georgina@intersect.org.au"

  Scenario: View a list of users
    When I am on the list users page
    Then I should see "users" table with
      | First name | Last name | Email                     | Role      |
      | Georgina   | Edwards   | georgina@intersect.org.au | superuser |

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

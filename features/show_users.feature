Feature: Show users
  As a normal user
  I want to see other users

  Background:
    Given I have users
      | first_name | last_name | email                  |
      | User1      | Last1     | user1@intersect.org.au |
      | User2      | Last2     | user2@intersect.org.au |
    And I am logged in as "user1@intersect.org.au"
    And I follow "Show Users"

  Scenario: View users list
    Then I should see "users" table with
      | First name | Last name | Email                     | Role      |
      | User1      | Last1     | user1@intersect.org.au    | user      |
      | User2      | Last2     | user2@intersect.org.au    | user      |

  Scenario: View user details
    When I follow "View Details" for "user1@intersect.org.au"
    Then I should see row "Email" with value "user1@intersect.org.au"
    And I should see row "First name" with value "User1"
    And I should see row "Last name" with value "Last1"
    And I should see row "Role" with value "user"
    When I follow "Back"
    Then I should be on the list users page
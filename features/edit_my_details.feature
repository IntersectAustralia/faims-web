Feature: Edit my details
  In order to keep my details up to date
  As a user
  I want to edit my details

  Background:
    Given I have a user "georgina@intersect.org.au"
    And I am logged in as "georgina@intersect.org.au"

  Scenario: Edit my details
    Given I am on the home page
    When I follow "Edit My Details"
    And I fill in "First Name" with "Fred"
    And I fill in "Last Name" with "Bloggs"
    And I press "Update"
    Then I should see "Your account details have been successfully updated."
    And I should be on the home page
    And I follow "Edit My Details"
    And the "First Name" field should contain "Fred"
    And the "Last Name" field should contain "Bloggs"

  Scenario Outline: Cannot edit details due to validation errors
    Given I am on the home page
    When I follow "Edit My Details"
    And I fill in "<field>" with "<value>"
    And I press "Update"
    Then I should see "<error>"
  Examples:
    | field      | value | error                     |
    | First Name |       | First name can't be blank |
    | Last Name  |       | Last name can't be blank  |

  Scenario: Cancel editing my details
    Given I am on the home page
    When I follow "Edit My Details"
    And I follow "Cancel"
    Then I should be on the user details page for georgina@intersect.org.au

  Scenario: Cannot edit details for other users
    Given I have a user "other@intersect.org.au"
    And I am on the edit details page for other@intersect.org.au
    Then I should see "You are not authorized to access this page."

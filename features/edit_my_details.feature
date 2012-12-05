Feature: Edit my details
  In order to keep my details up to date
  As a user
  I want to edit my details
  
  Background:
    Given I have a user "georgina@intersect.org.au"
    And I am logged in as "georgina@intersect.org.au"

  Scenario: Edit my information
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

  Scenario: Validation error
    Given I am on the home page
    When I follow "Edit My Details"
    And I fill in "First Name" with ""
    And I fill in "Last Name" with "Bloggs"
    And I press "Update"
    Then I should see "First name can't be blank"

  Scenario: Cancel editing my information
    Given I am on the home page
    When I follow "Edit My Details"
    And I follow "Cancel"
    Then I should be on the user details page for georgina@intersect.org.au

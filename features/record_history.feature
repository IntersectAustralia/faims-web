Feature: View and Revert record history
  In order view and revert history
  As a user
  I want to view and revert history

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am on the login page
    And I am logged in as "faimsadmin@intersect.org.au"
    And I should see "Logged in successfully."
    And I have a projects dir

  @not-jenkins
  @javascript
  Scenario: Resolve entity conflicts
    Given I am on the home page
    And I have project "Project 1"
    And I have database "faims-322.sqlite3" for "Project 1"
    And I click on "Show Projects"
    And I click on "Project 1"
    And I click on "List Archaeological Entity Records"
    And I follow link "Filter"
    Then I should see "Small 1" with "conflict"
    And I click on "Small 1"
    Then I should see "This Archaeological Entity record contains conflicting data. Please click 'Show History' to resolve the conflicts."
    And I click on "Show History"
    Then I history should have conflicts
    And I follow link "Revert and Resolve Conflicts"
    Then I history should not have conflicts

  @not-jenkins
  @javascript
  Scenario: Resolve relationship conflicts
    Given I am on the home page
    And I have project "Project 1"
    And I have database "faims-322.sqlite3" for "Project 1"
    And I click on "Show Projects"
    And I click on "Project 1"
    And I click on "List Relationship Records"
    And I follow link "Filter"
    Then I should see "AboveBelow 1" with "conflict"
    And I click on "AboveBelow 1"
    Then I should see "This Relationship record contains conflicting data. Please click 'Show History' to resolve the conflicts."
    And I click on "Show History"
    Then I history should have conflicts
    And I follow link "Revert and Resolve Conflicts"
    Then I history should not have conflicts


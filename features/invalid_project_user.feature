Feature: Invalid project user
  In order to prevent non project users from editing project records
  As a user
  I want to disable non project users from editing project records

  Background:
    Given I have role "user"
    And I have a user "user1@intersect.org.au" with role "user"
    And I am on the login page
    And I am logged in as "user1@intersect.org.au"
    And I should see "Logged in successfully."
    And I have a projects dir

  @javascript
  Scenario: Non project users cannot update entities
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    And I update field "name" of type "freetext" with values "test"
    And I click on update for attribute with field "name"
    Then I should see dialog "Only project users can edit the database. Please get a project user to add you to the project."
    And I confirm

  @javascript
  Scenario: Non project users cannot update relationships
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    And I follow "List Relationship Records"
    And I press "Filter"
    And I follow "AboveBelow 1"
    And I update field "name" of type "freetext" with values "test"
    And I click on update for attribute with field "name"
    Then I should see dialog "Only project users can edit the database. Please get a project user to add you to the project."
    And I confirm

  @javascript
  Scenario: Non project users cannot merge entities
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    And I select records
      | name    |
      | Small 2 |
      | Small 3 |
    And I click on "Compare"
    And I select the "first" record to merge to
    And I select merge fields
      | field | column |
      | name  | right  |
    And I click on "Merge"
    Then I should see dialog "Only project users can edit the database. Please get a project user to add you to the project."
    And I confirm

  @javascript
  Scenario: Non project users cannot merge relationships
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    And I follow "List Relationship Records"
    And I press "Filter"
    And I select records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
    And I click on "Compare"
    And I select the "first" record to merge to
    And I select merge fields
      | field | column |
      | name  | right  |
    And I click on "Merge"
    And I wait for popup to close
    Then I should see dialog "Only project users can edit the database. Please get a project user to add you to the project."
    And I confirm

  #TODO check all database changes are restricted e.g. deleting, reverting, adding or removing relationships etc
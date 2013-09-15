Feature: Invalid project user
  In order to prevent non project users from editing project records
  As a user
  I want to disable non project users from editing project records

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I have a projects dir

  @javascript
  Scenario: Project user can edit entity records
    Given I have role "user"
    And I have a user "user1@intersect.org.au" with role "user"
    And I am on the login page
    And I am logged in as "user1@intersect.org.au"
    And I should see "Logged in successfully."
    And I have project "Project 1"
    And I have database "faims-425.sqlite3" for "Project 1"
    And I follow "Show Projects"
    And I follow "Project 1"
    And I add "user1@intersect.org.au" to "Project 1"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    And I follow "Small 1"
    And I update field "name" of type "freetext" with values "test"
    And I click on update for attribute with field "name"
    Then I should see field "name" of type "freetext" with values "test"

  @javascript
  Scenario: Non project user cannot edit entity records
    Given I have role "user"
    And I have a user "user1@intersect.org.au" with role "user"
    And I am on the login page
    And I am logged in as "user1@intersect.org.au"
    And I should see "Logged in successfully."
    And I have project "Project 1"
    And I have database "faims-425.sqlite3" for "Project 1"
    And I follow "Show Projects"
    And I follow "Project 1"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    And I follow "Small 1"
    And I update field "name" of type "freetext" with values "test"
    And I click on update for attribute with field "name"
    Then I should see dialog "Only project users can edit the database. Please get a project user to add you to the project."
    And I confirm

  @javascript
  Scenario: Project user can edit relationship records
    Given I have role "user"
    And I have a user "user1@intersect.org.au" with role "user"
    And I am on the login page
    And I am logged in as "user1@intersect.org.au"
    And I should see "Logged in successfully."
    And I have project "Project 1"
    And I have database "faims-425.sqlite3" for "Project 1"
    And I follow "Show Projects"
    And I follow "Project 1"
    And I add "user1@intersect.org.au" to "Project 1"
    And I follow "List Relationship Records"
    And I press "Filter"
    And I follow "AboveBelow 1"
    And I update field "name" of type "freetext" with values "test"
    And I click on update for attribute with field "name"
    Then I should see field "name" of type "freetext" with values "test"

  @javascript
  Scenario: Non project user cannot edit relationship records
    Given I have role "user"
    And I have a user "user1@intersect.org.au" with role "user"
    And I am on the login page
    And I am logged in as "user1@intersect.org.au"
    And I should see "Logged in successfully."
    And I have project "Project 1"
    And I have database "faims-425.sqlite3" for "Project 1"
    And I follow "Show Projects"
    And I follow "Project 1"
    And I follow "List Relationship Records"
    And I press "Filter"
    And I follow "AboveBelow 1"
    And I update field "name" of type "freetext" with values "test"
    And I click on update for attribute with field "name"
    Then I should see dialog "Only project users can edit the database. Please get a project user to add you to the project."
    And I confirm

  #TODO check all database changes are restricted e.g. merging, deleting, reverting, adding or removing relationships etc
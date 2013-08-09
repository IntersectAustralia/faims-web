Feature: Invalid project user
  In order to prevent non project users from editing project records
  As a user
  I want to disable non project users from editing project records

  Background:
    And I have role "superuser"
    And I have a user "georgina@intersect.org.au" with role "superuser"
    And I have a projects dir

  Scenario: Project user can edit entity records
    Given I have role "user"
    And I have a user "user1@intersect.org.au" with role "user"
    And I am on the login page
    And I am logged in as "user1@intersect.org.au"
    And I should see "Logged in successfully."
    And I have project "Project 1"
    And I have database "faims-425.sqlite3" for "Project 1"
    And I click on "Show Projects"
    And I click on "Project 1"
    And I add "user1@intersect.org.au" to "Project 1"
    And I click on "List Archaeological Entity Records"
    And I follow link "Filter"
    And I click on "Small 1"
    And I update attribute "name" with "Test"
    Then I see attribute "name" with "Test"

  Scenario: Non project user cannot edit entity records
    Given I have role "user"
    And I have a user "user1@intersect.org.au" with role "user"
    And I am on the login page
    And I am logged in as "user1@intersect.org.au"
    And I should see "Logged in successfully."
    And I have project "Project 1"
    And I have database "faims-425.sqlite3" for "Project 1"
    And I click on "Show Projects"
    And I click on "Project 1"
    And I click on "List Archaeological Entity Records"
    And I follow link "Filter"
    And I click on "Small 1"
    And I update attribute "name" with "Test"
    Then I should see "Only project users can edit the database. Please get a project user to add you to the project."

  Scenario: Project user can edit relationship records
    Given I have role "user"
    And I have a user "user1@intersect.org.au" with role "user"
    And I am on the login page
    And I am logged in as "user1@intersect.org.au"
    And I should see "Logged in successfully."
    And I have project "Project 1"
    And I have database "faims-425.sqlite3" for "Project 1"
    And I click on "Show Projects"
    And I click on "Project 1"
    And I add "user1@intersect.org.au" to "Project 1"
    And I click on "List Relationship Records"
    And I follow link "Filter"
    And I click on "AboveBelow 1"
    And I update attribute "name" with "Test"
    Then I see attribute "name" with "Test"

  Scenario: Non project user cannot edit relationship records
    Given I have role "user"
    And I have a user "user1@intersect.org.au" with role "user"
    And I am on the login page
    And I am logged in as "user1@intersect.org.au"
    And I should see "Logged in successfully."
    And I have project "Project 1"
    And I have database "faims-425.sqlite3" for "Project 1"
    And I click on "Show Projects"
    And I click on "Project 1"
    And I click on "List Relationship Records"
    And I follow link "Filter"
    And I click on "AboveBelow 1"
    And I update attribute "name" with "Test"
    Then I should see "Only project users can edit the database. Please get a project user to add you to the project."

  #TODO check all database changes are restricted e.g. merging, deleting, reverting, adding or removing relationships etc
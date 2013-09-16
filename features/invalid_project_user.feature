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
    Then I should see dialog "Only project users can edit the database. Please get a project user to add you to the project"
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
    Then I should see dialog "Only project users can edit the database. Please get a project user to add you to the project"
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
    Then I should see dialog "Only project users can edit the database. Please get a project user to add you to the project"
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
    Then I should see dialog "Only project users can edit the database. Please get a project user to add you to the project"
    And I confirm

  @javascript
  Scenario: Non project users cannot delete entities
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    Then I follow "Small 3"
    And I click on "Delete"
    And I confirm
    Then I should see "Only project users can edit the database. Please get a project user to add you to the project"
    And I follow "Back"
    Then I should see records
      | name    |
      | Small 3 |

  @javascript
  Scenario: Non project users cannot restore entities
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    Then I click on "Show Deleted"
    Then I follow "Small 1"
    Then I click on "Restore"
    Then I should see "Only project users can edit the database. Please get a project user to add you to the project"
    And I follow "Back"
    Then I click on "Hide Deleted"
    And I should not see records
      | name    |
      | Small 1 |

  @javascript
  Scenario: Non project users cannot delete relationships
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "Search Relationship Records"
    And I enter "" and submit the form
    Then I follow "AboveBelow 2"
    And I click on "Delete"
    And I confirm
    Then I should see "Only project users can edit the database. Please get a project user to add you to the project"
    And I follow "Back"
    Then I should see records
      | name         |
      | AboveBelow 2 |

  @javascript
  Scenario: Non project users cannot restore relationships
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "Search Relationship Records"
    And I enter "" and submit the form
    Then I click on "Show Deleted"
    Then I follow "AboveBelow 4"
    Then I click on "Restore"
    Then I should see "Only project users can edit the database. Please get a project user to add you to the project"
    Then I follow "Back"
    Then I click on "Hide Deleted"
    And I should not see records
      | name         |
      | AboveBelow 4 |

  @not-jenkins
  @javascript
  Scenario: Non project users cannot revert entities
    Given I am on the home page
    And I have project "Project 1"
    And I have database "faims-322.sqlite3" for "Project 1"
    And I click on "Show Projects"
    And I follow "Project 1"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    Then I should see "Small 1" with "conflict"
    And I follow "Small 1"
    Then I should see "This Archaeological Entity record contains conflicting data. Please click 'Show History' to resolve the conflicts."
    And I follow "Show History"
    Then I history should have conflicts
    And I click on "Revert and Resolve Conflicts"
    Then I should see "Only project users can edit the database. Please get a project user to add you to the project"
    Then I history should have conflicts

  @not-jenkins
  @javascript
  Scenario: Non project users cannot revert relationships
    Given I am on the home page
    And I have project "Project 1"
    And I have database "faims-322.sqlite3" for "Project 1"
    And I follow "Show Projects"
    And I follow "Project 1"
    And I follow "List Relationship Records"
    And I press "Filter"
    Then I should see "AboveBelow 1" with "conflict"
    And I follow "AboveBelow 1"
    Then I should see "This Relationship record contains conflicting data. Please click 'Show History' to resolve the conflicts."
    And I follow "Show History"
    Then I history should have conflicts
    And I click on "Revert and Resolve Conflicts"
    Then I should see "Only project users can edit the database. Please get a project user to add you to the project"
    Then I history should have conflicts

  @javascript
  Scenario: Non project users cannot remove relationship association from entities
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "List Archaeological Entity Records"
    And I press "Filter"
    Then I follow "Small 2"
    And I follow "Show Relationship Association"
    And I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
    Then I delete the first record
    And I confirm
    Then I should see "Only project users can edit the database. Please get a project user to add you to the project"
    Then I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |

  @javascript
  Scenario: Non project users cannot add relationship association to entities
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "List Archaeological Entity Records"
    And I press "Filter"
    Then I follow "Small 2"
    And I follow "Show Relationship Association"
    And I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
    And I press "Add Member"
    And I click on "Search"
    And I select the first record
    And I press "Add Member"
    Then I should see "Only project users can edit the database. Please get a project user to add you to the project"
    Then I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
    And I should not see records
      | name         |
      | AboveBelow 3 |

  @javascript
  Scenario: Non project users cannot remove entity members from relationships
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "List Relationship Records"
    And I press "Filter"
    Then I follow "AboveBelow 1"
    And I follow "Show Relationship Member"
    And I should see records
      | name    |
      | Small 2 |
      | Small 4 |
    Then I delete the first record
    And I confirm
    Then I should see "Only project users can edit the database. Please get a project user to add you to the project"
    Then I should see records
      | name    |
      | Small 2 |
      | Small 4 |

  @javascript
  Scenario: Non project users cannot remove entity members from relationships
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "List Relationship Records"
    And I press "Filter"
    Then I follow "AboveBelow 1"
    And I follow "Show Relationship Member"
    And I should see records
      | name    |
      | Small 2 |
      | Small 4 |
    And I press "Add Member"
    And I click on "Search"
    And I select the first record
    And I press "Add Member"
    Then I should see "Only project users can edit the database. Please get a project user to add you to the project"
    Then I should see records
      | name    |
      | Small 2 |
      | Small 4 |
    And I should not see records
      | name    |
      | Small 3 |
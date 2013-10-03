Feature: Invalid project module user
  In order to prevent non project module users from editing project module records
  As a user
  I want to disable non project module users from editing project module records

  Background:
    Given I have role "user"
    And I have a user "user1@intersect.org.au" with role "user"
    And I am on the login page
    And I am logged in as "user1@intersect.org.au"
    And I should see "Logged in successfully."
    And I have a project modules dir

  @javascript
  Scenario: Non project module users cannot update entities
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Sync_Example.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
    And I follow "Sync Example"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    And I update field "name" of type "freetext" with values "test"
    And I click on update for attribute with field "name"
    Then I should see dialog "Only module users can edit the database. Please get a module user to add you to the module"
    And I confirm

  @javascript
  Scenario: Non project module users cannot update relationships
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Sync_Example.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
    And I follow "Sync Example"
    And I follow "List Relationship Records"
    And I press "Filter"
    And I follow "AboveBelow 1"
    And I update field "name" of type "freetext" with values "test"
    And I click on update for attribute with field "name"
    Then I should see dialog "Only module users can edit the database. Please get a module user to add you to the module"
    And I confirm

  @javascript
  Scenario: Non project module users cannot merge entities
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Sync_Example.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
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
    Then I should see dialog "Only module users can edit the database. Please get a module user to add you to the module"
    And I confirm

  @javascript
  Scenario: Non project module users cannot merge relationships
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Sync_Example.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
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
    Then I should see dialog "Only module users can edit the database. Please get a module user to add you to the module"
    And I confirm

  @javascript
  Scenario: Non project module users cannot delete entities
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Sync_Example.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
    And I follow "Sync Example"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    Then I follow "Small 3"
    And I click on "Delete"
    And I confirm
    Then I should see "Only module users can edit the database. Please get a module user to add you to the module"
    And I follow "Back"
    Then I should see records
      | name    |
      | Small 3 |

  @javascript
  Scenario: Non project module users cannot restore entities
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Sync_Example.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
    And I follow "Sync Example"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    Then I click on "Show Deleted"
    Then I follow "Small 1"
    Then I click on "Restore"
    Then I should see "Only module users can edit the database. Please get a module user to add you to the module"
    And I follow "Back"
    Then I click on "Hide Deleted"
    And I should not see records
      | name    |
      | Small 1 |

  @javascript
  Scenario: Non project module users cannot delete relationships
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Sync_Example.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
    And I follow "Sync Example"
    Then I follow "Search Relationship Records"
    And I enter "" and submit the form
    Then I follow "AboveBelow 2"
    And I click on "Delete"
    And I confirm
    Then I should see "Only module users can edit the database. Please get a module user to add you to the module"
    And I follow "Back"
    Then I should see records
      | name         |
      | AboveBelow 2 |

  @javascript
  Scenario: Non project module users cannot restore relationships
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Sync_Example.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
    And I follow "Sync Example"
    Then I follow "Search Relationship Records"
    And I enter "" and submit the form
    Then I click on "Show Deleted"
    Then I follow "AboveBelow 4"
    Then I click on "Restore"
    Then I should see "Only module users can edit the database. Please get a module user to add you to the module"
    Then I follow "Back"
    Then I click on "Hide Deleted"
    And I should not see records
      | name         |
      | AboveBelow 4 |

  @not-jenkins
  @javascript
  Scenario: Non project module users cannot revert entities
    Given I am on the home page
    And I have project module "Module 1"
    And I have database "faims-322.sqlite3" for "Module 1"
    And I click on "Show Modules"
    And I follow "Module 1"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    Then I should see "Small 1" with "conflict"
    And I follow "Small 1"
    Then I should see "This Archaeological Entity record contains conflicting data. Please click 'Show History' to resolve the conflicts."
    And I follow "Show History"
    Then I history should have conflicts
    And I click on "Revert and Resolve Conflicts"
    Then I should see "Only module users can edit the database. Please get a module user to add you to the module"
    Then I history should have conflicts

  @not-jenkins
  @javascript
  Scenario: Non project module users cannot revert relationships
    Given I am on the home page
    And I have project module "Module 1"
    And I have database "faims-322.sqlite3" for "Module 1"
    And I follow "Show Modules"
    And I follow "Module 1"
    And I follow "List Relationship Records"
    And I press "Filter"
    Then I should see "AboveBelow 1" with "conflict"
    And I follow "AboveBelow 1"
    Then I should see "This Relationship record contains conflicting data. Please click 'Show History' to resolve the conflicts."
    And I follow "Show History"
    Then I history should have conflicts
    And I click on "Revert and Resolve Conflicts"
    Then I should see "Only module users can edit the database. Please get a module user to add you to the module"
    Then I history should have conflicts

  @javascript
  Scenario: Non project module users cannot remove relationship association from entities
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Sync_Example.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
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
    Then I should see "Only module users can edit the database. Please get a module user to add you to the module"
    Then I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |

  @javascript
  Scenario: Non project module users cannot add relationship association to entities
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Sync_Example.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
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
    Then I should see "Only module users can edit the database. Please get a module user to add you to the module"
    Then I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
    And I should not see records
      | name         |
      | AboveBelow 3 |

  @javascript
  Scenario: Non project module users cannot remove entity members from relationships
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Sync_Example.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
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
    Then I should see "Only module users can edit the database. Please get a module user to add you to the module"
    Then I should see records
      | name    |
      | Small 2 |
      | Small 4 |

  @javascript
  Scenario: Non project module users cannot remove entity members from relationships
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Sync_Example.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
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
    Then I should see "Only module users can edit the database. Please get a module user to add you to the module"
    Then I should see records
      | name    |
      | Small 2 |
      | Small 4 |
    And I should not see records
      | name    |
      | Small 3 |
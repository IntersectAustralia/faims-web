Feature: Manage entity relationships
  In order manage entity relationships
  As a user
  I want to list, view and edit entity relationships

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I have a user "other@intersect.org.au"
    And I am on the login page
    And I am logged in as "faimsadmin@intersect.org.au"
    And I should see "Logged in successfully."
    And I have a project modules dir

  Scenario: See entities relations for entity
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
    Then I follow "Small 2"
    Then I follow "small Below AboveBelow: Small 3"
    Then I follow "Back"
    And I should see related arch entities
      | name                            |
      | small Below AboveBelow: Small 3 |
      | small Below AboveBelow: Small 4 |

  Scenario: Show relationship associations for entity
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

  @javascript
  Scenario: Remove relationship association from entity
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
    Then I should see "Removed Archaeological Entity from Relationship"
    Then I should see records
      | name         |
      | AboveBelow 2 |
    And I should not see records
      | name         |
      | AboveBelow 1 |

  @javascript
  Scenario: Cannot remove relationship association from entity if database is locked
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
    And database is locked for "Sync Example"
    And I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
    Then I delete the first record
    And I confirm
    And I wait for page
    Then I should see "Could not process request as database is currently locked"
    Then I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |

  @javascript
  Scenario: Cannot remove relationship association from entity if not member of module
    Given I logout
    And I am logged in as "other@intersect.org.au"
    And I am on the home page
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
  Scenario: Add relationship association to entity
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
    Then I should see "Added Archaeological Entity as member of Relationship"
    Then I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
      | AboveBelow 3 |

  @javascript
  Scenario: Cannot add relationship association to entity if database is locked
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
    And database is locked for "Sync Example"
    And I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
    And I press "Add Member"
    And I click on "Search"
    And I select the first record
    And I press "Add Member"
    Then I should see "Could not process request as database is currently locked"
    Then I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
    And I should not see records
      | name         |
      | AboveBelow 3 |

  @javascript
  Scenario: Cannot add relationship association to entity if not member of module
    Given I logout
    And I am logged in as "other@intersect.org.au"
    And I am on the home page
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

  Scenario: Show entity membership for relationship
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

  @javascript
  Scenario: Remove entity from relationship
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
    Then I should see "Removed Archaeological Entity from Relationship"
    Then I should see records
      | name    |
      | Small 4 |
    And I should not see records
      | name    |
      | Small 2 |

  @javascript
  Scenario: Cannot remove entity from relationship if database is locked
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
    And database is locked for "Sync Example"
    And I should see records
      | name    |
      | Small 2 |
      | Small 4 |
    Then I delete the first record
    And I confirm
    And I wait for page
    Then I should see "Could not process request as database is currently locked"
    Then I should see records
      | name    |
      | Small 2 |
      | Small 4 |

  @javascript
  Scenario:Cannot remove entity from relationship if not member of module
    Given I logout
    And I am logged in as "other@intersect.org.au"
    And I am on the home page
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
  Scenario: Add entity to relationship
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
    Then I should see "Added Archaeological Entity as member of Relationship"
    Then I should see records
      | name    |
      | Small 2 |
      | Small 3 |
      | Small 4 |

  @javascript
  Scenario: Cannot add entity to relationship if database is locked
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
    And database is locked for "Sync Example"
    And I should see records
      | name    |
      | Small 2 |
      | Small 4 |
    And I press "Add Member"
    And I click on "Search"
    And I select the first record
    And I press "Add Member"
    Then I should see "Could not process request as database is currently locked"
    Then I should see records
      | name    |
      | Small 2 |
      | Small 4 |
    And I should not see records
      | name    |
      | Small 3 |

  @javascript
  Scenario: Cannot add entity to relationship if not member of module
    Given I logout
    And I am logged in as "other@intersect.org.au"
    And I am on the home page
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
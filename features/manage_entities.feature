Feature: Manage entities
  In order manage entities
  As a user
  I want to list, view and edit entities

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au"
    And I have a project modules dir

  @javascript
  Scenario: Update entity
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    And I update fields with values
      | field    | type      | values                 |
      | location | vocab     | Location A; Location C |
      | name     | freetext  | test3                  |
      | name     | certainty |                        |
      | value    | measure   | 10.0                   |
      | value    | certainty | 0.5                    |
    And I refresh page
    And I should see fields with values
      | field    | type      | values                 |
      | location | vocab     | Location A; Location C |
      | name     | freetext  | test3                  |
      | name     | certainty |                        |
      | value    | measure   | 10.0                   |
      | value    | certainty | 0.5                    |

  @javascript
  Scenario: Cannot update entity if not member of module
    Given I logout
    And I have a user "other@intersect.org.au" with role "superuser"
    And I am logged in as "other@intersect.org.au"
    And I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    And I update field "name" of type "freetext" with values "test"
    And I click on update for attribute with field "name"
    Then I should see dialog "You are not a member of the module you are editing. Please ask a member to add you to the module before continuing."
    And I confirm

  @javascript
  Scenario: Update entity with hierarchical vocabulary
    Given I have project module "Hierarchical Vocabulary"
    And I am on the project modules page
    And I follow "Hierarchical Vocabulary"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    And I follow "Small 1"
    And I update fields with values
      | field | type  | values                                       |
      | type  | vocab | Type A > Color A1 > Shape A1S1 > Size A1S1R3 |
    And I refresh page
    And I should see fields with values
      | field | type  | values                                       |
      | type  | vocab | Type A > Color A1 > Shape A1S1 > Size A1S1R3 |

  @javascript
  Scenario: Update entity attribute causes validation error
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "Edit Module"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I press "Update"
    Then I should see "Updated module"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    And I update fields with values
      | field | type     | values |
      | name  | freetext |        |
    And I should see fields with errors
      | field | error                |
      | name  | Field value is blank |
      | name  | Field value not text |

  @javascript
  Scenario: Cannot update entity attribute if database is locked
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    And database is locked for "Sync Example"
    And I update fields with values
      | field    | type  | values                 |
      | location | vocab | Location A; Location C |
    And I wait for popup to close
    Then I should see dialog "Could not process request as project is currently locked."
    And I confirm

  # TODO Scenario: Update entity attribute with multiple values causes validation error

  Scenario: View entity with attachments
    Given I have project module "Sync Test"
    And I am on the project modules page
    And I click on "Sync Test"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    And I select the first record
    Then I should see attached files
      | name                                   |
      | Screenshot_2013-04-09-10-32-04.png     |
      | Screenshot_2013-04-09-10-32-04 (1).png |

  Scenario: View entity with attachments which aren't synced
    Given I have project module "Sync Test"
    And I am on the project modules page
    And I click on "Sync Test"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    And I select the first record
    Then I should see attached files
      | name                                   |
      | Screenshot_2013-04-09-10-32-04.png     |
      | Screenshot_2013-04-09-10-32-04 (1).png |
    Then I remove all files for "Sync Test"
    Then I should see non attached files
      | name                                   |
      | Screenshot_2013-04-09-10-32-04.png     |
      | Screenshot_2013-04-09-10-32-04 (1).png |

  Scenario: View entity list
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    Then I should see records
      | name    |
      | Small 2 |
      | Small 3 |
      | Small 4 |

  @javascript
  Scenario: View entity list including deleted entities
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    And I click on "Show Deleted"
    Then I should see records
      | name    |
      | Small 1 |
      | Small 2 |
      | Small 3 |
      | Small 4 |

  @javascript
  Scenario: Delete entity
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    Then I follow "Small 3"
    And I click on "Delete"
    And I confirm
    Then I should see "Deleted Archaeological Entity"
    Then I should not see records
      | name    |
      | Small 1 |
      | Small 3 |

  @javascript
  Scenario: Cannot delete entity if database locked
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    Then I follow "Small 3"
    And database is locked for "Sync Example"
    And I click on "Delete"
    And I confirm
    And I wait for page
    Then I should see "Could not process request as project is currently locked."
    And I follow "Back"
    Then I should see records
      | name    |
      | Small 3 |

  @javascript
  Scenario: Cannot delete entity if not member of module
    Given I logout
    And I have a user "other@intersect.org.au" with role "superuser"
    And I am logged in as "other@intersect.org.au"
    And I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    Then I follow "Small 3"
    And I click on "Delete"
    And I confirm
    Then I should see "You are not a member of the module you are editing. Please ask a member to add you to the module before continuing."
    And I follow "Back"
    Then I should see records
      | name    |
      | Small 3 |

  @javascript
  Scenario: Restore entity
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    Then I follow "Small 3"
    Then I click on "Delete"
    And I confirm
    Then I click on "Show Deleted"
    Then I follow "Small 3"
    Then I click on "Restore"
    And I should see "Restored Archaeological Entity"
    Then I follow "Back"
    Then I click on "Hide Deleted"
    And I should not see records
      | name    |
      | Small 1 |
    But I should see records
      | name    |
      | Small 3 |

  @javascript
  Scenario: Cannot restore entity if database is locked
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    Then I follow "Small 3"
    Then I click on "Delete"
    And I confirm
    Then I click on "Show Deleted"
    Then I follow "Small 3"
    And database is locked for "Sync Example"
    Then I click on "Restore"
    And I wait for page
    And I should see "Could not process request as project is currently locked."
    And I follow "Back"
    Then I click on "Hide Deleted"
    And I should not see records
      | name    |
      | Small 1 |
      | Small 3 |

  @javascript
  Scenario: Cannot restore entity if not member of module
    Given I logout
    And I have a user "other@intersect.org.au" with role "superuser"
    And I am logged in as "other@intersect.org.au"
    And I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    Then I click on "Show Deleted"
    Then I follow "Small 1"
    Then I click on "Restore"
    Then I should see "You are not a member of the module you are editing. Please ask a member to add you to the module before continuing."
    And I follow "Back"
    Then I click on "Hide Deleted"
    And I should not see records
      | name    |
      | Small 1 |
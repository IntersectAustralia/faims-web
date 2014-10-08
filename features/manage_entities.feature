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
  Scenario: Update entity with autosaving
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    And I update fields with values
      | field    | type               | values                 |
      | location | Constrained Data   | Location A; Location C |
      | name     | Annotation         | test3                  |
      | name     | Certainty          |                        |
      | value    | Unconstrained Data | 10.0                   |
      | value    | Certainty          | 0.5                    |
    Then I should see "Successfully updated entity"
    And I refresh page
    And I should see fields with values
      | field    | type               | values                 |
      | location | Constrained Data   | Location A; Location C |
      | name     | Annotation         | test3                  |
      | name     | Certainty          |                        |
      | value    | Unconstrained Data | 10.0                   |
      | value    | Certainty          | 0.5                    |

  @javascript
  Scenario: Cannot update entity if not member of module
    Given I logout
    And I have a user "other@intersect.org.au" with role "superuser"
    And I am logged in as "other@intersect.org.au"
    And I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    And I update field "filename" of type "Annotation" with values "test"
    And I update field "filename" of type "Certainty" with values "1.0"
    Then I should see dialog "You are not a member of the module you are editing. Please ask a member to add you to the module before continuing."
    And I confirm

  @javascript
  Scenario: Update entity with hierarchical vocabulary
    Given I have project module "Hierarchical Vocabulary"
    And I am on the project modules page
    And I follow "Hierarchical Vocabulary"
    And I follow "List Entity Records"
    And I press "Filter"
    And I follow "Small 1"
    And I update fields with values
      | field | type             | values                                       |
      | type  | Constrained Data | Type A > Color A1 > Shape A1S1 > Size A1S1R3 |
    And I refresh page
    And I wait for page to load up data
    Then I should see fields with values
      | field | type             | values                                       |
      | type  | Constrained Data | Type A > Color A1 > Shape A1S1 > Size A1S1R3 |

  @javascript
  Scenario: Update entity attribute causes validation error and then ignore errors removes errors
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "Edit Module"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I press "Update"
    Then I should see "Updated module"
    And I follow "List Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    And I update fields with values
      | field    | type       | values |
      | filename | Annotation |        |
      | filename | Certainty  | 1.0    |
    Then I should see fields with errors
      | field | error                |
      | name  | Field value is blank |
      | name  | Field value not text |
      | name  | Error in evaluator |
    And I ignore errors for "name"
    Then I should not see "Error in evaluator"

  @javascript
  Scenario: Cannot update entity attribute if database is locked
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    And database is locked for "Sync Example"
    And I update fields with values
      | field    | type             | values                 |
      | location | Constrained Data | Location A; Location C |
      | location | Certainty        | 1.0                    |
    And I wait for popup to close
    Then I should see dialog "Could not process request as project is currently locked."
    And I confirm

  # TODO Scenario: Update entity attribute with multiple values causes validation error

  @javascript
  Scenario: Update entity with uploaded attachments
    Given I have project module "Large Entity List"
    And I am on the project modules page
    And I click on "Large Entity List"
    Then I follow "Search Entity Records"
    And I enter "" and submit the form
    And I select the first record
    And I click upload for field "file"
    And I pick file "ui_logic.bsh" for "attr_file_attribute_file"
    And I press "Upload"
    And I wait for autosaving
    And I refresh page
    Then I should see attached files
      | name         |
      | ui_logic.bsh |
    And I remove attribute values for field "file"
    And I wait for autosaving
    Then I should see non attached files
      | name         |
      | ui_logic.bsh |

  @javascript
  Scenario: Update entity with multiple uploaded attachments and pictures
    Given I have project module "Large Entity List"
    And I am on the project modules page
    And I click on "Large Entity List"
    Then I follow "Search Entity Records"
    And I enter "" and submit the form
    And I select the first record
    And I click upload for field "file"
    And I pick file "ui_logic.bsh" for "attr_file_attribute_file"
    And I press "Upload"
    And I click upload for field "file"
    And I pick file "empty.tar.gz" for "attr_file_attribute_file"
    And I press "Upload"
    And I click upload for field "picture"
    And I pick file "tree.jpg" for "attr_file_attribute_file"
    And I press "Upload"
    And I wait for autosaving
    And I refresh page
    And I wait for autosaving
    Then I should see attached files
      | name              |
      | ui_logic.bsh      |
      | empty.tar.gz      |
    And I should see "tree.original.jpg"

  Scenario: View entity with attachments
    Given I have project module "Sync Test"
    And I am on the project modules page
    And I click on "Sync Test"
    Then I follow "Search Entity Records"
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
    Then I follow "Search Entity Records"
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

  Scenario: View entity with thumbnails
    Given I have project module "Thumbnail"
    And I am on the project modules page
    And I click on "Thumbnail"
    Then I follow "Search Entity Records"
    And I enter "" and submit the form
    And I select the first record
    Then I should see thumbnail files
      | name                             |
      | image-1410832623415.original.jpg |
      | video-1410832643560.original.mp4 |

  Scenario: View entity without thumbnails if they have not synced yet
    Given I have project module "Thumbnail"
    And I am on the project modules page
    And I click on "Thumbnail"
    Then I follow "Search Entity Records"
    And I enter "" and submit the form
    And I select the first record
    Then I should see thumbnail files
      | name                             |
      | image-1410832623415.original.jpg |
      | video-1410832643560.original.mp4 |
    Then I remove all thumbnail files for "Thumbnail"
    And I refresh page
    Then I should see attached files
      | name                             |
      | image-1410832623415.original.jpg |
      | video-1410832643560.original.mp4 |

  Scenario: View entity list
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    Then I follow "Search Entity Records"
    And I enter "" and submit the form
    Then I should see records
      | name    |
      | Small 2 |
      | Small 3 |
      | Small 4 |

  @javascript
  Scenario: View entity list with pagination
    Given I have project module "Large Entity List"
    And I am on the project modules page
    And I follow "Large Entity List"
    And I follow "List Entity Records"
    And I press "Filter"
    Then I should see records
      | name     |
      | Small 1  |
      | Small 50 |
    And I should not see records
      | name     |
      | Small 51 |
    And I select "100" from "per_page"
    Then I should see records
      | name      |
      | Small 1   |
      | Small 100 |
    And I should not see records
      | name      |
      | Small 101 |
    And I select "all" from "per_page"
    Then I should see records
      | name      |
      | Small 1   |
      | Small 100 |
      | Small 101 |

  @javascript
  Scenario: View entity list including deleted entities
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    Then I follow "Search Entity Records"
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
    Then I follow "Search Entity Records"
    And I enter "" and submit the form
    Then I follow "Small 3"
    And I click on "Delete"
    And I confirm
    Then I should see "Deleted Entity"
    Then I should not see records
      | name    |
      | Small 1 |
      | Small 3 |

  @javascript
  Scenario: Batch delete entity
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    Then I follow "Search Entity Records"
    And I enter "" and submit the form
    And I select records
      | name    |
      | Small 2 |
      | Small 3 |
    And I follow "Delete Selected"
    And I confirm
    Then I should see "Deleted Entities"
    Then I should not see records
      | name    |
      | Small 2 |
      | Small 3 |


  @javascript
  Scenario: Can't batch delete entities if none selected
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "Search Entity Records"
    And I enter "" and submit the form
    And I follow "Delete Selected"
    Then I should see dialog "Please select a record to delete"
    And I confirm

  @javascript
  Scenario: Batch restore entity
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    Then I follow "Search Entity Records"
    And I enter "" and submit the form
    And I select records
      | name    |
      | Small 2 |
      | Small 3 |
    And I follow "Delete Selected"
    And I confirm
    Then I should see "Deleted Entities"
    And I should not see records
      | name    |
      | Small 2 |
      | Small 3 |
    And I follow "Show Deleted"
    And I select records
      | name    |
      | Small 2 |
      | Small 3 |
    And I follow "Restore Selected"
    And I confirm
    Then I should see "Restored Entities"
    And I follow "Hide Deleted"
    Then I should see records
      | name    |
      | Small 2 |
      | Small 3 |

  @javascript
  Scenario: Can't batch restore entities if none selected
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "Search Entity Records"
    And I enter "" and submit the form
    And I follow "Show Deleted"
    And I follow "Restore Selected"
    Then I should see dialog "Please select a record to restore"
    And I confirm

  @javascript
  Scenario: Cannot delete entity if database locked
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    Then I follow "Search Entity Records"
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
    Then I follow "Search Entity Records"
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
    Then I follow "Search Entity Records"
    And I enter "" and submit the form
    Then I follow "Small 3"
    Then I click on "Delete"
    And I confirm
    Then I click on "Show Deleted"
    Then I follow "Small 3"
    Then I click on "Restore"
    And I should see "Restored Entity"
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
    Then I follow "Search Entity Records"
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
    Then I follow "Search Entity Records"
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
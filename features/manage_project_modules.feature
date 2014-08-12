Feature: Manage project modules
  In order manage project modules
  As a user
  I want to list, create and edit project modules

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am on the login page
    And I am logged in as "faimsadmin@intersect.org.au"
    And I should see "Logged in successfully."
    And I have a project modules dir

  Scenario: List project modules
    Given I am on the home page
    And I have project modules
      | name      |
      | Module 1 |
      | Module 2 |
      | Module 3 |
    And I follow "Show Modules"
    Then I should see project modules
      | name      |
      | Module 1 |
      | Module 2 |
      | Module 3 |

  Scenario: Create a new project module
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I have project module files for module "Module 1"

  Scenario: Optional validation schema
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I have project module files for module "Module 1"

  Scenario: Set srid on project module creation
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I fill in "Module SRID" with "EPSG:4326 - WGS 84"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I have project module files for module "Module 1"
    And I should have setting "srid" for "Module 1" as "4326"

  Scenario Outline: Cannot create project module due to errors
    Given I am on the home page
    And I have project module "Module 1"
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "<field>" with "<value>"
    And I press "Submit"
    Then I should see "<field>" with error "<error>"
  Examples:
    | field       | value     | error          |
    | Name        |           | can't be blank |
    | Name        | Module * | is invalid     |
    | Data Schema |           | can't be blank |
    | UI Schema   |           | can't be blank |
    | UI Logic    |           | can't be blank |

  Scenario Outline: Cannot create project module due to errors
    Given I am on the home page
    And I have project module "Module 1"
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Module Name" with "Module 2"
    And I pick file "<value>" for "<field>"
    And I press "Submit"
    Then I should see "<field>" with error "<error>"
  Examples:
    | field             | value                      | error                           |
    | Data Schema       |                            | can't be blank                  |
    | Data Schema       | garbage                    | must be xml file                |
    | Data Schema       | data_schema_error1.xml     | invalid xml at line             |
    | UI Schema         |                            | can't be blank                  |
    | UI Schema         | garbage                    | must be xml file                |
    | UI Schema         | ui_schema_error1.xml       | invalid xml at line             |
    | Validation Schema | garbage                    | must be xml file                |
    | Validation Schema | data_schema_error1.xml     | invalid xml at line             |
    | UI Logic          |                            | can't be blank                  |
    | Arch16n           | faims_Module_2.properties | invalid properties file at line |

  Scenario: Upload Module
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "module.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
    And I have project module files for module "Simple Project"

  Scenario: Upload Module if project module already exists should fail
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "module.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I follow "Upload Module"
    And I pick file "module.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "This module already exists in the system"

  Scenario: Upload Module with wrong checksum should fail
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "module_corrupted1.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Wrong hash sum for the module"

  Scenario: Upload Module with corrupted file should fail
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "module_corrupted2.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module failed to upload"

  Scenario: Upload Module with wrong file should fail
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "module.tar" for "Module File"
    And I press "Upload"
    Then I should see "Module failed to upload"

  Scenario Outline: Edit static data
    Given I am on the home page
    And I have project module "Module 1"
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Module"
    And I fill in "<field>" with "<value>"
    And I press "Update"
    And I should have setting "<setting>" for "Module 1" as "<setting_value>"
  Examples:
    | field        | value              | setting | setting_value |
    | Module SRID | EPSG:4326 - WGS 84 | srid    | 4326          |

  Scenario Outline: Edit static data fails with errors
    Given I am on the home page
    And I have project module "Module 1"
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Module"
    And I fill in "<field>" with "<value>"
    And I press "Update"
    Then I should see "<field>" with error "<error>"
  Examples:
    | field        | value     | error          |
    | Module Name |           | can't be blank |
    | Module Name | Module * | is invalid     |

  Scenario: Edit project module but not upload new file
    Given I am on the home page
    And I have project module "Module 1"
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Module"
    And I press "Update"
    Then I should see "Updated module"

  Scenario: Cannot edit project module if project module is locked
    Given I am on the home page
    And I have project module "Module 1"
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Module"
    And settings is locked for "Module 1"
    And I press "Update"
    Then I should see "Could not process request as module is currently locked"

  Scenario: Edit project module and upload correct file
    Given I am on the home page
    And I have project module "Module 1"
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Module"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Update"
    Then I should see "Updated module"

  Scenario: Edit project module and upload correct file so project module has correct file
    Given I am on the home page
    And I have project module "Module 1"
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Module"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Update"
    Then I should see "Updated module"
    And Module "Module 1" should have the same file "faims.properties"

  Scenario Outline: Edit project module and upload incorrect file
    Given I am on the home page
    And I have project module "Module 2"
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I click on "Module 2"
    Then I follow "Edit Module"
    And I pick file "<value>" for "<field>"
    And I press "Update"
    Then I should see "<field>" with error "<error>"
  Examples:
    | field             | value                      | error                           |
    | UI Schema         | garbage                    | must be xml file                |
    | UI Schema         | ui_schema_error1.xml       | invalid xml at line             |
    | Validation Schema | garbage                    | must be xml file                |
    | Validation Schema | data_schema_error1.xml     | invalid xml at line             |
    | Arch16n           | faims_Module_2.properties | invalid properties file at line |

  Scenario: Download package
    Given I have project module "Module 1"
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Module 1"
    And I automatically archive project module package "Module 1"
    And I automatically download project module package "Module 1"
    Then I should download project module package file for "Module 1"

  @javascript
  Scenario: Cannot download package if project module is locked
    Given I have project module "Module 1"
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Module 1"
    And database is locked for "Module 1"
    And I follow "Download Module"
    Then I should see dialog "Could not process request as module is currently locked"
    And I confirm

  Scenario: See attached files for arch ent
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Sync_Test.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
    And I click on "Sync Test"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    And I select the first record
    Then I should see attached files
      | name                                   |
      | Screenshot_2013-04-09-10-32-04.png     |
      | Screenshot_2013-04-09-10-32-04 (1).png |

  Scenario: See attached files for arch ent if some files don't exist
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Sync_Test.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
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


#  @javascript
#  Scenario: Download attached file for arch ent
#    Given I am on the home page
#    And I follow "Show Modules"
#    Then I should be on the project modules page
#    And I wait
#    And I follow "Upload Module"
#    And I pick file "Sync_Test.tar.bz2" for "Module File"
#    And I press "Upload"
#    Then I should see "Module has been successfully uploaded"
#    And I should be on the project modules page
#    And I click on "Sync Test"
#    Then I follow "Search Archaeological Entity Records"
#    And I enter "" and submit the form
#    And I select the first record
#    Then I click file with name "Screenshot_2013-04-09-10-32-04(1).png"
#    And I should download attached file with name "Screenshot_2013-04-09-10-32-04(1).png"

  Scenario: See attached files for relationship
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Sync_Test.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
    And I click on "Sync Test"
    Then I follow "Search Relationship Records"
    And I enter "" and submit the form
    And I select the first record
    Then I should see attached files
      | name                                   |
      | Screenshot_2013-04-29-16-38-51.png     |
      | Screenshot_2013-04-29-16-38-51 (1).png |
    Then I remove all files for "Sync Test"

  Scenario: See attached files for relationship if some files don't exist
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Sync_Test.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
    And I click on "Sync Test"
    Then I follow "Search Relationship Records"
    And I enter "" and submit the form
    And I select the first record
    Then I should see attached files
      | name                                   |
      | Screenshot_2013-04-29-16-38-51.png     |
      | Screenshot_2013-04-29-16-38-51 (1).png |
    Then I remove all files for "Sync Test"
    Then I should see non attached files
      | name                                   |
      | Screenshot_2013-04-29-16-38-51.png     |
      | Screenshot_2013-04-29-16-38-51 (1).png |

#  @javascript
#  Scenario: Download attached file for relationship
#    Given I am on the home page
#    And I follow "Show Modules"
#    Then I should be on the project modules page
#    And I wait
#    And I follow "Upload Module"
#    And I pick file "Sync_Test.tar.bz2" for "Module File"
#    And I press "Upload"
#    Then I should see "Module has been successfully uploaded"
#    And I should be on the project modules page
#    And I click on "Sync Test"
#    Then I follow "Search Relationship Records"
#    And I enter "" and submit the form
#    And I select the first record
#    Then I click file with name "Screenshot_2013-04-29-16-38-51(1).png"
#    And I should download attached file with name "Screenshot_2013-04-29-16-38-51(1).png"

  @javascript
  Scenario: View Vocabularies
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I should see vocabularies
      | name  | description | pictureURL |
      | Green |             |            |
      | Pink  |             |            |
      | Blue  |             |            |

  @javascript
  Scenario: Update Vocabulary
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    And I modify vocabulary "Green" with "Red"
    Then I click on "Update"
    And I should see "Successfully updated vocabulary"
    And I should see vocabularies
      | name | description | pictureURL |
      | Red  |             |            |
      | Pink |             |            |
      | Blue |             |            |

  @javascript
  Scenario: Insert Vocabulary
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I click on "Insert" for the attribute
    And I add "Red" to the vocabulary list
    Then I add "New color" as description to the vocabulary list
    And  I add "New picture url" as picture url to the vocabulary list
    Then I click on "Update"
    And I should see "Successfully updated vocabulary"
    And I should see vocabularies
      | name  | description | pictureURL      |
      | Green |             |                 |
      | Red   | New color   | New picture url |
      | Pink  |             |                 |
      | Blue  |             |                 |

  @javascript
  Scenario: Add Child Vocabulary
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I click add child for vocabulary "Green"
    And I add "Circle" as child for "Green"
    Then I add "A Circle" as child description for "Green"
    And  I add "Circle URL" as child picture url for "Green"
    Then I click insert for vocabulary "Green"
    And I add "Square" as child for "Green"
    Then I add "A Square" as child description for "Green"
    And  I add "Square URL" as child picture url for "Green"
    Then I click on "Update"
    And I should see "Successfully updated vocabulary"
    And I should see child vocabularies for "Green"
      | name   | description | pictureURL |
      | Square | A Square    | Square URL |
      | Circle | A Circle    | Circle URL |

  @javascript
  Scenario: Add Child To Child Vocabulary
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I click add child for vocabulary "Green"
    And I add "Circle" as child for "Green"
    Then I add "A Circle" as child description for "Green"
    And  I add "Circle URL" as child picture url for "Green"
    Then I click on "Update"
    And I should see "Successfully updated vocabulary"
    And I should see child vocabularies for "Green"
      | name   | description | pictureURL |
      | Circle | A Circle    | Circle URL |
    Then I click add child for vocabulary "Circle"
    And I add "Square" as child for "Circle"
    Then I add "A Square" as child description for "Circle"
    And  I add "Square URL" as child picture url for "Circle"
    Then I click on "Update"
    And I should see "Successfully updated vocabulary"
    And I should see child vocabularies for "Circle"
      | name   | description | pictureURL |
      | Square | A Square    | Square URL |

  @javascript
  Scenario: Cannot update vocabulary if contains empty vocabulary name
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I click on "Insert" for the attribute
    Then I add "New color" as description to the vocabulary list
    And  I add "New picture url" as picture url to the vocabulary list
    Then I click on "Update"
    And I should see "Please correct the errors in this form. Vocabulary name cannot be empty"
    And I should see vocabularies
      | name | description | pictureURL       |
      |      | New color   | New picture url  |
      | Pink |             |                  |
      | Blue |             |                  |

  @javascript
  Scenario: Cannot update vocabulary if contains empty child vocabulary name
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I click add child for vocabulary "Green"
    And I add "Circle" as child for "Green"
    Then I add "A Circle" as child description for "Green"
    And  I add "Circle URL" as child picture url for "Green"
    Then I click insert for vocabulary "Green"
    And I add "" as child for "Green"
    Then I add "A Square" as child description for "Green"
    And  I add "Square URL" as child picture url for "Green"
    Then I click on "Update"
    And I should see "Please correct the errors in this form. Vocabulary name cannot be empty"
    And I should see child vocabularies for "Green"
      | name   | description | pictureURL |
      |        | A Square    | Square URL |
      | Circle | A Circle    | Circle URL |

  @javascript
  Scenario: Cannot update vocabulary if db is locked
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Vocabulary"
    And database is locked for "Module 1"
    And I select "Soil Texture" for the attribute
    And I modify vocabulary "Green" with "Red"
    Then I click on "Update"
    And I should see "Could not process request as database is currently locked"
    And I should see vocabularies
      | name | description | pictureURL |
      | Red  |             |            |
      | Pink |             |            |
      | Blue |             |            |

  @javascript
  Scenario: Cannot update vocabulary if db is locked
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Vocabulary"
    And database is locked for "Module 1"
    And I select "Soil Texture" for the attribute
    Then I click add child for vocabulary "Green"
    And I add "Circle" as child for "Green"
    Then I add "A Circle" as child description for "Green"
    And  I add "Circle URL" as child picture url for "Green"
    Then I click insert for vocabulary "Green"
    And I add "Square" as child for "Green"
    Then I add "A Square" as child description for "Green"
    And  I add "Square URL" as child picture url for "Green"
    Then I click on "Update"
    And I should see "Could not process request as database is currently locked"
    And I should see child vocabularies for "Green"
      | name   | description | pictureURL |
      | Square | A Square    | Square URL |
      | Circle | A Circle    | Circle URL |

  @javascript
  Scenario: Cannot update child vocabulary if db is locked
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Vocabulary"
    And database is locked for "Module 1"
    And I select "Soil Texture" for the attribute
    Then I click on "Insert" for the attribute
    And I add "Red" to the vocabulary list
    Then I add "New color" as description to the vocabulary list
    And  I add "New picture url" as picture url to the vocabulary list
    Then I click on "Update"
    And I should see "Could not process request as database is currently locked"
    And I should see vocabularies
      | name  | description | pictureURL      |
      | Green |             |                 |
      | Red   | New color   | New picture url |
      | Pink  |             |                 |
      | Blue  |             |                 |

  @javascript
  Scenario: Seeing users to be added for project module
    Given I have users
      | first_name | last_name | email                  |
      | User1      | Last1     | user1@intersect.org.au |
      | User2      | Last2     | user2@intersect.org.au |
    And I have project module "Module 1"
    Then I follow "Show Modules"
    And I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Users"
    And I should have user for selection
      | name        |
      | User1 Last1 |
      | User2 Last2 |

  @javascript
  Scenario: Adding users to the project module
    Given I have users
      | first_name | last_name | email                  |
      | User1      | Last1     | user1@intersect.org.au |
      | User2      | Last2     | user2@intersect.org.au |
    And I have project module "Module 1"
    And I add "faimsadmin@intersect.org.au" to "Module 1"
    Then I follow "Show Modules"
    And I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit User"
    And I select "User1 Last1" from the user list
    Then I click on "Add"
    And I should see "Successfully updated user"
    And I should have user for project module
      | first_name | last_name |
      | Fred       | Bloggs    |
      | User1      | Last1     |

  @javascript
  Scenario: Cannot add user to project module if database is locked
    Given I have users
      | first_name | last_name | email                  |
      | User1      | Last1     | user1@intersect.org.au |
      | User2      | Last2     | user2@intersect.org.au |
    And I have project module "Module 1"
    And I add "faimsadmin@intersect.org.au" to "Module 1"
    Then I follow "Show Modules"
    And I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit User"
    And database is locked for "Module 1"
    And I select "User1 Last1" from the user list
    Then I click on "Add"
    And I should see "Could not process request as database is currently locked"
    And I should have user for project module
      | first_name | last_name |
      | Fred       | Bloggs    |
    And I should not have user for project module
      | first_name | last_name |
      | User1      | Last1     |

  Scenario: Show arch entity list not include the deleted value
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
    Then I should see records
      | name    |
      | Small 2 |
      | Small 3 |
      | Small 4 |

  @javascript
  Scenario: Show arch entity list include the deleted value
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
    And I click on "Show Deleted"
    Then I should see records
      | name    |
      | Small 1 |
      | Small 2 |
      | Small 3 |
      | Small 4 |

  @javascript
  Scenario: Delete arch entity
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
    Then I should see "Deleted Archaeological Entity"
    Then I should not see records
      | name    |
      | Small 1 |
      | Small 3 |

  @javascript
  Scenario: Cannot delete arch entity if database locked
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
    And database is locked for "Sync Example"
    And I click on "Delete"
    And I confirm
    And I wait for page
    Then I should see "Could not process request as database is currently locked"
    And I follow "Back"
    Then I should see records
      | name    |
      | Small 3 |

  @javascript
  Scenario: Restore arch entity
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
  Scenario: Cannot restore arch entity if database is locked
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
    Then I click on "Delete"
    And I confirm
    Then I click on "Show Deleted"
    Then I follow "Small 3"
    And database is locked for "Sync Example"
    Then I click on "Restore"
    And I wait for page
    And I should see "Could not process request as database is currently locked"
    And I follow "Back"
    Then I click on "Hide Deleted"
    And I should not see records
      | name    |
      | Small 1 |
      | Small 3 |

  Scenario: Show relationship list not include the deleted value
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
    Then I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
      | AboveBelow 3 |

  @javascript
  Scenario: Show relationship list include the deleted value
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
    And I click on "Show Deleted"
    Then I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
      | AboveBelow 3 |
      | AboveBelow 4 |

  @javascript
  Scenario: Delete relationship
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
    Then I should see "Deleted Relationship"
    Then I should not see records
      | name         |
      | AboveBelow 2 |
      | AboveBelow 4 |

  @javascript
  Scenario: Cannot delete relationship if database is locked
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
    And database is locked for "Sync Example"
    And I click on "Delete"
    And I confirm
    And I wait for page
    Then I should see "Could not process request as database is currently locked"
    And I follow "Back"
    Then I should see records
      | name         |
      | AboveBelow 2 |

  @javascript
  Scenario: Restore relationship
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
    Then I click on "Delete"
    And I confirm
    Then I click on "Show Deleted"
    Then I follow "AboveBelow 2"
    Then I click on "Restore"
    And I should see "Restored Relationship"
    Then I follow "Back"
    Then I click on "Hide Deleted"
    And I should not see records
      | name         |
      | AboveBelow 4 |
    But I should see records
      | name         |
      | AboveBelow 2 |

  @javascript
  Scenario: Cannot restore relationship if database is locked
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
    Then I click on "Delete"
    And I confirm
    Then I click on "Show Deleted"
    Then I follow "AboveBelow 2"
    And database is locked for "Sync Example"
    Then I click on "Restore"
    And I wait for page
    And I should see "Could not process request as database is currently locked"
    Then I follow "Back"
    Then I click on "Hide Deleted"
    And I should not see records
      | name         |
      | AboveBelow 2 |
      | AboveBelow 4 |

  Scenario: See related arch entities
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

  @javascript
  Scenario: Update arch entity attribute
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
  Scenario: Update arch entity with hierarchical vocabulary
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Hierarchical_Vocabulary.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
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
  Scenario: Update arch entity attribute causes validation error
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Sync_Example.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
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
  Scenario: Cannot update arch entity attribute if database is locked
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
    And database is locked for "Sync Example"
    And I update fields with values
      | field    | type  | values                 |
      | location | vocab | Location A; Location C |
    And I wait for popup to close
    Then I should see dialog "Could not process request as database is currently locked"
    And I confirm

  Scenario: Update arch entity attribute with multiple values causes validation error
# TODO

  @javascript
  Scenario: Update relationship attribute
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
    And I update fields with values
      | field    | type      | values                 |
      | location | vocab     | Location A; Location C |
      | name     | freetext  | rel2                   |
      | name     | certainty |                        |
    And I refresh page
    And I should see fields with values
      | field    | type      | values                 |
      | location | vocab     | Location A; Location C |
      | name     | freetext  | rel2                   |
      | name     | certainty |                        |

  @javascript
  Scenario: Update relationship with hierarchical vocabulary
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Hierarchical_Vocabulary.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
    And I follow "Hierarchical Vocabulary"
    And I follow "List Relationship Records"
    And I press "Filter"
    And I follow "AboveBelow 2"
    And I update fields with values
      | field | type  | values                                       |
      | type  | vocab | Type A > Color A1 > Shape A1S1 > Size A1S1R3 |
    And I refresh page
    And I should see fields with values
      | field | type  | values                                       |
      | type  | vocab | Type A > Color A1 > Shape A1S1 > Size A1S1R3 |

  @javascript
  Scenario: Update relationship attribute causes validation error
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "Sync_Example.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
    And I follow "Sync Example"
    And I follow "Edit Module"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I press "Update"
    Then I should see "Updated module"
    And I follow "List Relationship Records"
    And I press "Filter"
    And I follow "AboveBelow 1"
    And I update fields with values
      | field | type     | values |
      | name  | freetext |        |
    And I should see fields with errors
      | field | error                |
      | name  | Field value is blank |
      | name  | Field value not text |

  @javascript
  Scenario: Cannot update relationship attribute if database is locked
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
    And database is locked for "Sync Example"
    And I update fields with values
      | field    | type  | values                 |
      | location | vocab | Location A; Location C |
    And I wait for popup to close
    Then I should see dialog "Could not process request as database is currently locked"
    And I confirm

  Scenario: Update relationship attribute with multiple values causes validation error
# TODO

  Scenario: Show relationship association for arch ent
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
  Scenario: Remove relationship association from arch ent
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
  Scenario: Cannot remove relationship association from arch ent if database is locked
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
  Scenario: Add relationship association to arch ent
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
  Scenario: Cannot add relationship association to arch ent if database is locked
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

  Scenario: Show arch ent member for relationship
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
  Scenario: Remove arch ent member from relationship
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
  Scenario: Cannot remove arch ent member from relationship if database is locked
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
  Scenario: Add arch ent member to relationship
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
  Scenario: Cannot add arch ent member to relationship
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
  Scenario: Merge arch ents (first)
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
    Then I should see "Merged Archaeological Entities"
    And I should see records
      | name    |
      | Small 2 |
      | Small 4 |
    And I should not see records
      | name    |
      | Small 3 |
    And I follow "Small 2"
    And I should see fields with values
      | field  | type     | values  |
      | entity | freetext | Small 2 |
      | name   | freetext | test3   |

  @javascript
  Scenario: Merge arch ents (second)
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
    And I select the "second" record to merge to
    And I select merge fields
      | field | column |
      | name  | left   |
    And I click on "Merge"
    Then I should see "Merged Archaeological Entities"
    And I should see records
      | name    |
      | Small 3 |
      | Small 4 |
    And I should not see records
      | name    |
      | Small 2 |
    And I follow "Small 3"
    And I should see fields with values
      | field  | type     | values  |
      | entity | freetext | Small 3 |
      | name   | freetext | test2   |

  @javascript
  Scenario: Can only compare 2 arch ents
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
    And I click on "Compare"
    Then I should see dialog "Please select two records to compare"
    And I confirm
    And I select records
      | name    |
      | Small 2 |
      | Small 3 |
      | Small 4 |
    Then I click on "Compare"
    Then I should see dialog "Can only compare two records at a time"
    And I confirm

  @javascript
  Scenario: Cannot merge arch ents if database is locked
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
    And database is locked for "Sync Example"
    And I select the "first" record to merge to
    And I select merge fields
      | field | column |
      | name  | right  |
    And I click on "Merge"
    And I wait for popup to close
    Then I should see dialog "Could not process request as database is currently locked"
    And I confirm

  Scenario: Cannot compare arch ents of different types
# TODO

  @javascript
  Scenario: Merge rels (first)
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
    Then I should see "Merged Relationship"
    And I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 3 |
    And I should not see records
      | name         |
      | AboveBelow 2 |
    And I follow "AboveBelow 1"
    And I should see fields with values
      | field        | type     | values       |
      | relationship | freetext | AboveBelow 1 |
      | name         | freetext | rel2         |

  @javascript
  Scenario: Merge rels (second)
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
    And I select the "second" record to merge to
    And I select merge fields
      | field | column |
      | name  | left   |
    And I click on "Merge"
    Then I should see "Merged Relationship"
    And I should see records
      | name         |
      | AboveBelow 2 |
      | AboveBelow 3 |
    And I should not see records
      | name         |
      | AboveBelow 1 |
    And I follow "AboveBelow 2"
    And I should see fields with values
      | field        | type     | values       |
      | relationship | freetext | AboveBelow 2 |
      | name         | freetext | rel1         |

  @javascript
  Scenario: Can only compare 2 rels
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
    And I click on "Compare"
    Then I should see dialog "Please select two records to compare"
    And I confirm
    And I select records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
      | AboveBelow 3 |
    Then I click on "Compare"
    Then I should see dialog "Can only compare two records at a time"
    And I confirm

  @javascript
  Scenario: Cannot merge rels if database is locked
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
    And database is locked for "Sync Example"
    And I select the "first" record to merge to
    And I select merge fields
      | field | column |
      | name  | right  |
    And I click on "Merge"
    And I wait for popup to close
    Then I should see dialog "Could not process request as database is currently locked"
    And I confirm

  Scenario: Cannot compare rels of different types
# TODO

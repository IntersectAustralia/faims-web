Feature: Manage project modules
  In order manage project modules
  As a user
  I want to list, create and edit project modules

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au"
    And I have a project modules dir

  Scenario: View project modules list
    Given I am on the home page
    And I have project modules
      | name     |
      | Module 1 |
      | Module 2 |
      | Module 3 |
    And I follow "Show Modules"
    Then I should see project modules
      | name     |
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
    And I pick file "faims.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I can find project module files for "Module 1"

  Scenario: Create a new project module without validation schema
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I can find project module files for "Module 1"

  Scenario: Create a new project module and set SRID
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
    And I pick file "faims.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I can find project module files for "Module 1"
    And I should have setting "srid" for "Module 1" as "4326"

  Scenario Outline: Cannot create project module due to field validation errors
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
    | field       | value    | error          |
    | Name        |          | can't be blank |
    | Name        | Module * | is invalid     |
    | Data Schema |          | can't be blank |
    | UI Schema   |          | can't be blank |
    | UI Logic    |          | can't be blank |

  Scenario Outline: Cannot create project module due to file validation errors
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
    | field             | value                     | error                           |
    | Data Schema       |                           | can't be blank                  |
    | Data Schema       | garbage                   | must be xml file                |
    | Data Schema       | data_schema_error1.xml    | invalid xml at line             |
    | UI Schema         |                           | can't be blank                  |
    | UI Schema         | garbage                   | must be xml file                |
    | UI Schema         | ui_schema_error1.xml      | invalid xml at line             |
    | Validation Schema | garbage                   | must be xml file                |
    | Validation Schema | data_schema_error1.xml    | invalid xml at line             |
    | UI Logic          |                           | can't be blank                  |
    | Arch16n           | faims_Module_2.properties | invalid properties file at line |

  Scenario Outline: Edit module static data
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
    | field       | value              | setting | setting_value |
    | Module SRID | EPSG:4326 - WGS 84 | srid    | 4326          |

  Scenario Outline: Edit static data fails due to validation errors
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
    | field       | value    | error          |
    | Module Name |          | can't be blank |
    | Module Name | Module * | is invalid     |

  Scenario: Edit project module with no new files
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
    And settings is locked for "Module 1"
    Then I follow "Edit Module"
    And I press "Update"
    Then I should see "Could not process request as project is currently locked."

  Scenario: Edit project module with new files
    Given I am on the home page
    And I have project module "Module 1"
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Module"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims.properties" for "Arch16n"
    And I press "Update"
    Then I should see "Updated module"
    And Module "Module 1" should have the same file "ui_schema.xml"
    And Module "Module 1" should have the same file "validation_schema.xml"
    And Module "Module 1" should have the same file "ui_logic.bsh"
    And Module "Module 1" should have the same file "faims.properties"

  Scenario: Edit project module with new file
    Given I am on the home page
    And I have project module "Module 1"
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Module"
    And I pick file "faims.properties" for "Arch16n"
    And I press "Update"
    Then I should see "Updated module"
    And Module "Module 1" should have the same file "faims.properties"

  Scenario Outline: Cannot edit project module due to file validation errors
    Given I am on the home page
    And I have project module "Module 1"
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I click on "Module 1"
    Then I follow "Edit Module"
    And I pick file "<value>" for "<field>"
    And I press "Update"
    Then I should see "<field>" with error "<error>"
  Examples:
    | field             | value                     | error                           |
    | UI Schema         | garbage                   | must be xml file                |
    | UI Schema         | ui_schema_error1.xml      | invalid xml at line             |
    | Validation Schema | garbage                   | must be xml file                |
    | Validation Schema | data_schema_error1.xml    | invalid xml at line             |
    | Arch16n           | faims_Module_2.properties | invalid properties file at line |

#  Scenario: Download package
#    Given I have project module "Module 1"
#    And I follow "Show Modules"
#    Then I should be on the project modules page
#    And I follow "Module 1"
#    And I automatically archive project module package "Module 1"
#    And I automatically download project module package "Module 1"
#    Then I should download project module package file for "Module 1"
#
#  @javascript
#  Scenario: Cannot download package if project module is locked
#    Given I have project module "Module 1"
#    And I follow "Show Modules"
#    Then I should be on the project modules page
#    And I follow "Module 1"
#    And database is locked for "Module 1"
#    And I follow "Download Module"
#    Then I should see dialog "Could not process request as project is currently locked."
#    And I confirm
#
#  Scenario: Upload Module
#    Given I am on the home page
#    And I follow "Show Modules"
#    Then I should be on the project modules page
#    And I follow "Upload Module"
#    And I pick file "module.tar.bz2" for "Module File"
#    And I press "Upload"
#    Then I should see "Module has been successfully uploaded"
#    And I should be on the project modules page
#    And I can find project module files for "Simple Project"
#
#  Scenario: Upload Module fails if module already exists
#    Given I am on the home page
#    And I follow "Show Modules"
#    Then I should be on the project modules page
#    And I follow "Upload Module"
#    And I pick file "module.tar.bz2" for "Module File"
#    And I press "Upload"
#    Then I should see "Module has been successfully uploaded"
#    And I follow "Upload Module"
#    And I pick file "module.tar.bz2" for "Module File"
#    And I press "Upload"
#    Then I should see "This module already exists in the system"
#
#  Scenario: Upload Module fails if checksum is wrong
#    Given I am on the home page
#    And I follow "Show Modules"
#    Then I should be on the project modules page
#    And I follow "Upload Module"
#    And I pick file "module_corrupted1.tar.bz2" for "Module File"
#    And I press "Upload"
#    Then I should see "Wrong hash sum for the module"
#
#  Scenario: Upload Module fails if file is corrupted
#    Given I am on the home page
#    And I follow "Show Modules"
#    Then I should be on the project modules page
#    And I follow "Upload Module"
#    And I pick file "module_corrupted2.tar.bz2" for "Module File"
#    And I press "Upload"
#    Then I should see "Module failed to upload"
#
#  Scenario: Upload Module fails if file is not a module
#    Given I am on the home page
#    And I follow "Show Modules"
#    Then I should be on the project modules page
#    And I follow "Upload Module"
#    And I pick file "module.tar" for "Module File"
#    And I press "Upload"
#    Then I should see "Module failed to upload"
Feature: Manage projects
  In order manage projects
  As a user
  I want to list, create and edit projects

  Background:
    And I have role "superuser"
    And I have a user "georgina@intersect.org.au" with role "superuser"
    And I am on the login page
    And I am logged in as "georgina@intersect.org.au"
    And I should see "Logged in successfully."
    And I have a projects dir

  Scenario: List projects
    Given I am on the home page
    And I have projects
      | name      |
      | Project 1 |
      | Project 2 |
      | Project 3 |
    And I follow "Show Projects"
    Then I should see projects
      | name      |
      | Project 1 |
      | Project 2 |
      | Project 3 |

  @javascript
  Scenario: Create a new project
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Create Project"
    Then I should be on the new projects page
    And I fill in "Name" with "Project 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Project_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New project created."
    And I should be on the projects page
    And I have project files for "Project 1"

  Scenario Outline: Cannot create project due to errors
    Given I am on the home page
    And I have project "Project 1"
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Create Project"
    Then I should be on the new projects page
    And I fill in "<field>" with "<value>"
    And I press "Submit"
    Then I should see "<field>" with error "<error>"
  Examples:
    | field       | value     | error          |
    | Name        |           | can't be blank |
    | Name        | Project * | is invalid     |
    | Data Schema |           | can't be blank |
    | UI Schema   |           | can't be blank |
    | UI Logic    |           | can't be blank |

  @javascript
  Scenario Outline: Cannot create project due to errors
    Given I am on the home page
    And I have project "Project 1"
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Create Project"
    Then I should be on the new projects page
    And I wait
    And I fill in "Project Name" with "Project 2"
    And I pick file "<value>" for "<field>"
    And I press "Submit"
    Then I should see "<field>" with error "<error>"
  Examples:
    | field       | value                      | error                   |
    | Data Schema |                            | can't be blank          |
    | Data Schema | garbage                    | must be xml file        |
    | Data Schema | data_schema_error1.xml     | invalid xml             |
    | UI Schema   |                            | can't be blank          |
    | UI Schema   | garbage                    | must be xml file        |
    | UI Schema   | ui_schema_error1.xml       | invalid xml             |
    | UI Logic    |                            | can't be blank          |
    | Arch16n     | faims_error.properties     | invalid file name       |
    | Arch16n     | faims_Project_2.properties | invalid properties file |

  @javascript
  Scenario: Upload Project
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "project.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I have project files for "Project 1"

  Scenario Outline: Edit static data
    Given I am on the home page
    And I have project "Project 1"
    And I follow "Show Projects"
    Then I should be on the projects page
    And I click on "Project 1"
    Then I follow "Edit Project Setting"
    And I fill in "<field>" with "<value>"
    And I press "Update"
    Then I should see "<field>" with error "<error>"
  Examples:
    | field        | value     | error          |
    | Project Name |           | can't be blank |
    | Project Name | Project * | is invalid     |

  Scenario: Pull a list of projects
    Given I have projects
      | name      |
      | Project 1 |
      | Project 2 |
      | Project 3 |
    And I am on the android projects page
    Then I should see json for projects

  Scenario: Download package
    Given I have project "Project 1"
    And I follow "Show Projects"
    Then I should be on the projects page
    And I click on "Project 1"
    And I follow "Download Project"
    Then I automatically archive project package "Project 1"
    Then I automatically download project package "Project 1"
    Then I should download project package file for "Project 1"

  Scenario: See archive info for project
    Given I have project "Project 1"
    And I am on the android archive page for Project 1
    Then I should see json for "Project 1" archived file

  Scenario: See archive info for project after syncing
    Given I have project "Project 1"
    And I have synced 20 times for "Project 1"
    And I am on the android archive page for Project 1
    Then I should see json for "Project 1" archived file with version 20

  Scenario: Cannot see archive info if project doesn't exist
    Given I have project "Project 1"
    And I am on the android archive page for Project 2
    Then I should see bad request page

  Scenario: Can download project
    Given I have project "Project 1"
    And I am on the android download link for Project 1
    Then I should download file for "Project 1"

  Scenario: Cannot download project if project doesn't exist
    Given I have project "Project 1"
    And I am on the android download link for Project 2
    Then I should see bad request page

  Scenario: Can upload project database
    Given I have project "Project 1"
    And I upload database "db" to Project 1 succeeds
    Then I should have stored "db" into Project 1

  Scenario: Cannot upload project database because of corruption
    Given I have project "Project 1"
    And I upload corrupted database "db" to Project 1 fails

  Scenario: See archive info for database
    Given I have project "Project 1"
    And I am on the android archive db page for Project 1
    Then I should see json for "Project 1" archived db file

  Scenario: See archive info for database after syncing
    Given I have project "Project 1"
    And I have synced 20 times for "Project 1"
    And I am on the android archive db page for Project 1
    Then I should see json for "Project 1" archived db file with version 20

  Scenario: Cannot see archive info for database if project doesn't exist
    Given I have project "Project 1"
    And I am on the android archive db page for Project 2
    Then I should see bad request page

  Scenario: Can download project database
    Given I have project "Project 1"
    And I am on the android download db link for Project 1
    Then I should download db file for "Project 1"

  Scenario: Cannot download project database if project doesn't exist
    Given I have project "Project 1"
    And I am on the android download db link for Project 2
    Then I should see bad request page

  Scenario Outline: See archive info for database with version
    Given I have project "Project 1"
    And I have synced 20 times for "Project 1"
    And I am on the android archive db page for "Project 1" with request version <version>
    Then I should see json for "Project 1" archived version <version> db file with version 20
  Examples:
    | version |
    | 1       |
    | 10      |
    | 20      |

  Scenario Outline: Cannot see archive info for database with invalid version
    Given I have project "Project 1"
    And I have synced 20 times for "Project 1"
    And I am on the android archive db page for "Project 1" with request version <version>
    Then I should see json for "Project 1" archived db file with version 20
  Examples:
    | version |
    | 0       |
    | -1      |
    | 21      |

  Scenario: Cannot see archive info for database with version if project doesn't exist
    Given I have project "Project 1"
    And I have synced 20 times for "Project 1"
    And I am on the android archive db page for Project 2 with request version 10
    Then I should see bad request page

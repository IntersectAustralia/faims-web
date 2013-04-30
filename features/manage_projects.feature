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
    And I wait
    And I follow "Upload Project"
    And I pick file "project.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I have project files for "Simple Project"

  @javascript
  Scenario: Upload Project if project already exists should fail
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I wait
    And I follow "Upload Project"
    And I pick file "project.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I follow "Upload Project"
    And I pick file "project.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "This project already exists in the system"

  @javascript
  Scenario: Upload Project with wrong checksum should fail
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I wait
    And I follow "Upload Project"
    And I pick file "project_corrupted1.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Wrong hash sum for the project"

  @javascript
  Scenario: Upload Project with corrupted file should fail
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I wait
    And I follow "Upload Project"
    And I pick file "project_corrupted2.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Uploaded project file is corrupted"

  @javascript
  Scenario: Upload Project with wrong file should fail
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I wait
    And I follow "Upload Project"
    And I pick file "project.tar" for "Project File"
    And I press "Upload"
    Then I should see "Unsupported format of file, please upload the correct file"

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

  @javascript
  Scenario: See attached files for arch ent
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I wait
    And I follow "Upload Project"
    And I pick file "Sync_Test.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I click on "Sync Test"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    And I select the first record
    Then I should see attached files
      | name                                  |
      | Screenshot_2013-04-09-10-32-04.png    |
      | Screenshot_2013-04-09-10-32-04(1).png |

#  @javascript
#  Scenario: Download attached file for arch ent
#    Given I am on the home page
#    And I follow "Show Projects"
#    Then I should be on the projects page
#    And I wait
#    And I follow "Upload Project"
#    And I pick file "Sync_Test.tar.bz2" for "Project File"
#    And I press "Upload"
#    Then I should see "Project has been successfully uploaded"
#    And I should be on the projects page
#    And I click on "Sync Test"
#    Then I follow "Search Archaeological Entity Records"
#    And I enter "" and submit the form
#    And I select the first record
#    Then I click file with name "Screenshot_2013-04-09-10-32-04(1).png"
#    And I should download attached file with name "Screenshot_2013-04-09-10-32-04(1).png"

  @javascript
  Scenario: See attached files for relationship
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I wait
    And I follow "Upload Project"
    And I pick file "Sync_Test.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I click on "Sync Test"
    Then I follow "Search Relationship Records"
    And I enter "" and submit the form
    And I select the first record
    Then I should see attached files
      | name                                  |
      | Screenshot_2013-04-29-16-38-51.png    |
      | Screenshot_2013-04-29-16-38-51(1).png |

#  @javascript
#  Scenario: Download attached file for relationship
#    Given I am on the home page
#    And I follow "Show Projects"
#    Then I should be on the projects page
#    And I wait
#    And I follow "Upload Project"
#    And I pick file "Sync_Test.tar.bz2" for "Project File"
#    And I press "Upload"
#    Then I should see "Project has been successfully uploaded"
#    And I should be on the projects page
#    And I click on "Sync Test"
#    Then I follow "Search Relationship Records"
#    And I enter "" and submit the form
#    And I select the first record
#    Then I click file with name "Screenshot_2013-04-29-16-38-51(1).png"
#    And I should download attached file with name "Screenshot_2013-04-29-16-38-51(1).png"
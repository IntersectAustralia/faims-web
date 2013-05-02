Feature: Project file manager
  In order manage project files
  As a user
  I want to upload, list and delete project files

  Background:
    And I have role "superuser"
    And I have a user "georgina@intersect.org.au" with role "superuser"
    And I am on the login page
    And I am logged in as "georgina@intersect.org.au"
    And I should see "Logged in successfully."
    And I have a projects dir

  Scenario: Add project files
    Given I have project "Project 1"
    And I am on upload data files page for Project 1

  Scenario: Add project directories
    Given I have project "Project 1"
    And I am on upload data files page for Project 1

  Scenario: Add project files within directories
    Given I have project "Project 1"
    And I am on upload data files page for Project 1

  Scenario: Delete project files
    Given I have project "Project 1"
    And I am on upload data files page for Project 1

  Scenario: Delete project directories
    Given I have project "Project 1"
    And I am on upload data files page for Project 1

  Scenario: Cannot add project file if project doesn't exist
    Given I have project "Project 1"
    And I am on upload data files page for Project 1

  Scenario: Cannot add project file if file doesn't exist
    Given I have project "Project 1"
    And I am on upload data files page for Project 1

  Scenario: Cannot add project file if file already exists
    Given I have project "Project 1"
    And I am on upload data files page for Project 1

  Scenario: Cannot add directory if project doesn't exist
    Given I have project "Project 1"
    And I am on upload data files page for Project 1

  Scenario: Cannot add directory if directory not specified
    Given I have project "Project 1"
    And I am on upload data files page for Project 1

  Scenario Outline: Cannot add directory if directory is not valid
    Given I have project "Project 1"
    And I am on upload data files page for Project 1
  Examples:
    | directories |

  Scenario: Cannot add file within directory if directory doesn't exist
    Given I have project "Project 1"
    And I am on upload data files page for Project 1

  Scenario: Cannot add file within directory if directory already exists
    Given I have project "Project 1"
    And I am on upload data files page for Project 1

  Scenario: Cannot delete file if project doesn't exist
    Given I have project "Project 1"
    And I am on upload data files page for Project 1

  Scenario: Cannot delete file if file doesn't exist
    Given I have project "Project 1"
    And I am on upload data files page for Project 1

  Scenario: Cannot delete dir if project doesn't exist
    Given I have project "Project 1"
    And I am on upload data files page for Project 1

  Scenario: Cannot delete dir if dir doesn't exist
    Given I have project "Project 1"
    And I am on upload data files page for Project 1

  Scenario: Cannot delete dir if dir files in directory
    Given I have project "Project 1"
    And I am on upload data files page for Project 1

  Scenario: Cannot delete root directory
    Given I have project "Project 1"
    And I am on upload data files page for Project 1




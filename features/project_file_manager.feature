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
    Given I am on the home page

  Scenario: Add project directories
    Given I am on the home page

  Scenario: Add project files within directories
    Given I am on the home page

  Scenario: Delete project files
    Given I am on the home page

  Scenario: Delete project directories
    Given I am on the home page

  Scenario: Cannot add project file if project doesn't exist
    Given I am on the home page

  Scenario: Cannot add project file if file doesn't exist
    Given I am on the home page

  Scenario: Cannot add directory if project doesn't exist
    Given I am on the home page

  Scenario: Cannot add directory if directory not specified
    Given I am on the home page

  Scenario Outline: Cannot add directory if directory is not valid
    Given I am on the home page
  Examples:
    | directories |

  Scenario: Cannot add file within directory if directory doesn't exist
    Given I am on the home page

  Scenario: Cannot delete file if project doesn't exist
    Given I am on the home page

  Scenario: Cannot delete file if file doesn't exist
    Given I am on the home page

  Scenario: Cannot delete dir if project doesn't exist
    Given I am on the home page

  Scenario: Cannot delete dir if dir doesn't exist
    Given I am on the home page




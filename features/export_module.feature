Feature: Export project module
  In order to export modules I need to be able to export and view the results

  Background:
    Given I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au"
    And I have a project modules dir
    And I have a project exporters dir
    And I have users
      | first_name | last_name | email                  |
      | User1      | Last1     | user1@intersect.org.au |

  @javascript
  Scenario: Export module with interface
    Given I am on the the upload project exporters page
    And I upload exporter "exporter_with_interface.tar.gz"
    And I have project modules
      | name     |
      | Module 1 |
    And I am on the project modules page
    And I follow "Module 1"
    And I follow "Export Module"
    Then I should be on the export module page for Module 1
    And I select "Interface Test" from "select_exporter"
    Then I should see "Name"
    And I should see "Hello"
    And I fill in "Name" with "Steve"
    And I check "Hello"
    And I press "Export" within the exporter interface 
    And I process delayed jobs
    Then I should be on the export module results page for Module 1
    And I should see "Output"
    And I should see "Name is Steve"
    And I should see "Text is Hello"
    And I should see "State is ACT"
    And I follow "Download file"
    Then I should download the export result containing "This is a test download with some amazing content"

  @javascript
  Scenario: Export module with no interface
    Given I am on the the upload project exporters page
    And I upload exporter "exporter.tar.gz"
    And I have project modules
      | name     |
      | Module 1 |
    And I am on the project modules page
    And I follow "Module 1"
    And I follow "Export Module"
    And I select "Exporter 1" from "select_exporter"
    And I should see "No interface to display for this exporter"
    And I press "Export" within the exporter interface 
    And I process delayed jobs
    Then I should see "Nothing to display"

  @javascript
  Scenario: Run failing exporter
    Given I am on the the upload project exporters page
    And I upload exporter "failing_exporter.tar.gz"
    And I have project modules
      | name     |
      | Module 1 |
    And I am on the project modules page
    And I follow "Module 1"
    And I follow "Export Module"
    And I select "Failing Exporter" from "select_exporter"
    And I press "Export" within the exporter interface 
    And I process delayed jobs
    Then I should see "Failed to export module"
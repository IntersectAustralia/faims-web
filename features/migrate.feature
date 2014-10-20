Feature: Search entities
  In order to view search entities
  As a user
  I want to search by user, type and query

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au"
    And I have a project modules dir

  Scenario: I download module with latest version
    Given I have project module "Module 1"
    And I am on the home page
    Then I should be on the project modules page
    And I follow "Module 1"
    And I follow "Download Module"
    And I automatically download project module package "Module 1"
    Then I should download project module package file for "Module 1"
    Then downloaded project module should have latest version for "Module 1"

  Scenario: I upload module with latest version should not migrate
    Given I am on the home page
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "module.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully uploaded"
    And I should be on the project modules page
    And I can find project module files for "Simple Project"

  Scenario: I upload module with older version it should migrate
    Given I am on the home page
    Then I should be on the project modules page
    And I follow "Upload Module"
    And I pick file "GraveStone1.tar.bz2" for "Module File"
    And I press "Upload"
    Then I should see "Module has been successfully upgraded from Faims 1.3 to Faims 2.0"
    And I should be on the project modules page
    And I can find project module files for "GraveStone1"

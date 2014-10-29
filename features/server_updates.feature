Feature: Server updates
  In order to check and update the server
  As a user
  I want to manually check for updates and update the server

  Background:
    Given I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au"
    And I have a project modules dir
    And I reset faims updater

  Scenario: I automatically see updates available
    Given I add remote deployment file with version "2.0" and tag "blah"
    And I add local deployment file with version "2.0" and tag "blah"
    And I add has server updates file
    And I am on the project modules page
    Then I should see "Updates Available!"

  Scenario: I can check for server updates returns no updates available
    Given I add remote deployment file with version "2.0" and tag "blah"
    And I add local deployment file with version "2.0" and tag "blah"
    And I am on the project modules page
    And I follow "Check for Updates"
    Then I should see "Everything is up to date"
    And I should not see button "Update Server"

  Scenario: I can check for server updates returns new updates available
    Given I add remote deployment file with version "2.1" and tag "blah"
    And I add local deployment file with version "2.0" and tag "blah"
    And I am on the project modules page
    And I follow "Check for Updates"
    Then I should see button "Update Server"

  Scenario: I cannot check for server updates if there is no internet connection
    Given I fake no internet connection
    And I am on the project modules page
    And I follow "Check for Updates"
    Then I should see "Could not find internet connection to check for updates"
    And I should not see button "Update Server"

  @javascript
  Scenario: I can archive and download modules that have changes
    Given I add remote deployment file with version "2.1" and tag "blah"
    And I add local deployment file with version "2.0" and tag "blah"
    And I have project module "Search"
    And I make changes to "Search"
    And I am on the project modules page
    And I follow "Check for Updates"
    Then I should see button "Update Server"
    And I should see button "Archive" for "Search" module
    And I follow "Archive"
    And I process delayed jobs
    And I wait 5 seconds
    And I should see button "Download" for "Search" module

  Scenario: I can download modules that have no changes
    Given I add remote deployment file with version "2.1" and tag "blah"
    And I add local deployment file with version "2.0" and tag "blah"
    And I have project module "Search"
    And I am on the project modules page
    And I follow "Check for Updates"
    Then I should see button "Update Server"
    And I should see button "Download" for "Search" module
    And I follow "Download"
    Then I should download project module package file for "Search"

  @javascript
  Scenario: I can update server returns server updated
    Given I add remote deployment file with version "2.1" and tag "blah"
    And I add local deployment file with version "2.0" and tag "blah"
    And I fake server update success
    And I am on the project modules page
    And I follow "Check for Updates"
    Then I should see button "Update Server"
    And I press "Update Server"
    And I process delayed jobs
    And I wait 5 seconds
    Then I should see dialog "The server has been successfully updated. The server will now reboot in 60 seconds please press ok to continue."
    And I cancel

  @javascript
  Scenario: I can update server returns server update failure
    Given I add remote deployment file with version "2.1" and tag "blah"
    And I add local deployment file with version "2.0" and tag "blah"
    And I fake server update failure
    And I am on the project modules page
    And I follow "Check for Updates"
    Then I should see button "Update Server"
    And I press "Update Server"
    And I process delayed jobs
    And I wait 5 seconds
    Then I should see dialog "The server failed to update properly. Please contact a system administrator to resolve this problem."
    And I cancel

  @javascript
  Scenario: I can update server returns server update exception
    Given I add remote deployment file with version "2.1" and tag "blah"
    And I add local deployment file with version "2.0" and tag "blah"
    And I fake server update exception
    And I am on the project modules page
    And I follow "Check for Updates"
    Then I should see button "Update Server"
    And I press "Update Server"
    And I process delayed jobs with error
    And I wait 5 seconds
    Then I should see dialog "Encountered an unexpected error trying to check for updates. Please contact a system administrator to resolve this problem."
    And I cancel
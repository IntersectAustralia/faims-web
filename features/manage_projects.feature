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

  Scenario: Create a new project
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Create Project"
    Then I should be on the new projects page
    And I fill in "Name" with "Project 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I press "Upload" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I press "Submit"
    And I press "Upload" for "UI Schema"
    Then I should see "New project created."
    Then I should be on the projects page

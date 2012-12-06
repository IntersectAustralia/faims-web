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
      | name |
      | Project 1|
      | Project 2|
      | Project 3|
    And I follow "Show Projects"
    Then I should see projects
      | name |
      | Project 1|
      | Project 2|
      | Project 3|

  @javascript
  Scenario: Create a new project
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Create Project"
    Then I should be on the new projects page
    And I fill in "Name" with "Project 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I press "Upload" for "Data Schema"
    And I should not see errors for upload "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I press "Upload" for "UI Schema"
    And I should not see errors for upload "UI Schema"
    And I press "Submit"
    Then I should see "New project created."
    Then I should be on the projects page

  @javascript
  Scenario Outline: Cannot create project due to errors
    Given I am on the home page
    And I have project "Project 1"
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Create Project"
    Then I should be on the new projects page
    And I fill in "<field>" with "<value>"
    And I press "Submit"
    Then I should see "<field>" with error "<error>" for "<upload>"
  Examples:
    | field       | value     | error                  | upload |
    | Name        |           | can't be blank         | false  |
    | Name        | Project 1 | has already been taken | false  |
    | Data Schema |           | can't be blank         | true   |
    | UI Schema   |           | can't be blank         | true   |

  @javascript
  Scenario Outline: Cannot upload schema due to errors
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Create Project"
    Then I should be on the new projects page
    And I pick file "<file>" for "<field>"
    And I press "Upload" for "<field>"
    Then I should see "<field>" with error "<error>" for "<upload>"
  Examples:
    | field       | file                  | error            | upload |
    | Data Schema |                       | can't be blank   | true   |
    | UI Schema   |                       | can't be blank   | true   |
    | Data Schema | garbage               | must be xml file | true   |
    | UI Schema   | garbage               | must be xml file | true   |
    | Data Schema | data_schema_error.xml | invalid xml      | true   |
    | UI Schema   | ui_schema_error.xml   | invalid xml      | true   |
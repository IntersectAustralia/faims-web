Feature: Merge entities
  In order merge entities
  As a user
  I want to compare and merge entities

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au"
    And I have a project modules dir

  @javascript
  Scenario: Merge entities (first)
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    And I select records
      | name    |
      | Small 2 |
      | Small 3 |
    And I click on "Compare"
    And I select the "first" record to merge to
    And I select merge fields
      | field | column |
      | name  | right  |
    And I click on "Merge"
    Then I should see "Merged Archaeological Entities"
    And I should see records
      | name    |
      | Small 2 |
      | Small 4 |
    And I should not see records
      | name    |
      | Small 3 |
    And I follow "Small 2"
    And I should see fields with values
      | field  | type       | values  |
      | entity | Annotation | Small 2 |
      | name   | Annotation | test3   |

  @javascript
  Scenario: Merge entities (second)
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    And I select records
      | name    |
      | Small 2 |
      | Small 3 |
    And I click on "Compare"
    And I select the "second" record to merge to
    And I select merge fields
      | field | column |
      | name  | left   |
    And I wait
    And I click on "Merge"
    Then I should see "Merged Archaeological Entities"
    And I should see records
      | name    |
      | Small 3 |
      | Small 4 |
    And I should not see records
      | name    |
      | Small 2 |
    And I follow "Small 3"
    And I wait
    And I should see fields with values
      | field  | type       | values  |
      | entity | Annotation | Small 3 |
      | name   | Annotation | test2   |

  @javascript
  Scenario: Can only compare 2 entities
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    And I click on "Compare"
    Then I should see dialog "Please select two records to compare"
    And I confirm
    And I select records
      | name    |
      | Small 2 |
      | Small 3 |
      | Small 4 |
    Then I click on "Compare"
    Then I should see dialog "Can only compare two records at a time"
    And I confirm

  @javascript
  Scenario: Cannot merge entities if database is locked
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    And I select records
      | name    |
      | Small 2 |
      | Small 3 |
    And I click on "Compare"
    And database is locked for "Sync Example"
    And I select the "first" record to merge to
    And I select merge fields
      | field | column |
      | name  | right  |
    And I click on "Merge"
    And I wait for popup to close
    Then I should see dialog "Could not process request as project is currently locked."
    And I confirm

  @javascript
  Scenario: Cannot merge entities if not member of module
    Given I logout
    And I have a user "other@intersect.org.au" with role "superuser"
    And I am logged in as "other@intersect.org.au"
    And I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    And I select records
      | name    |
      | Small 2 |
      | Small 3 |
    And I click on "Compare"
    And I select the "first" record to merge to
    And I select merge fields
      | field | column |
      | name  | right  |
    And I click on "Merge"
    Then I should see dialog "You are not a member of the module you are editing. Please ask a member to add you to the module before continuing."
    And I confirm

  # TODO Scenario: Cannot compare arch entities of different types
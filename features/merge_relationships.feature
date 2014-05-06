Feature: Merge relationships
  In order merge relationships
  As a user
  I want to compare and merge relationships

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au"
    And I have a project modules dir

  @javascript
  Scenario: Merge relationships (first)
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Relationship Records"
    And I press "Filter"
    And I select records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
    And I click on "Compare"
    And I select the "first" record to merge to
    And I select merge fields
      | field | column |
      | name  | right  |
    And I click on "Merge"
    Then I should see "Merged Relationship"
    And I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 3 |
    And I should not see records
      | name         |
      | AboveBelow 2 |
    And I follow "AboveBelow 1"
    And I should see fields with values
      | field        | type     | values       |
      | relationship | freetext | AboveBelow 1 |
      | name         | freetext | rel2         |

  @javascript
  Scenario: Merge relationships (second)
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Relationship Records"
    And I press "Filter"
    And I select records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
    And I click on "Compare"
    And I select the "second" record to merge to
    And I select merge fields
      | field | column |
      | name  | left   |
    And I click on "Merge"
    Then I should see "Merged Relationship"
    And I should see records
      | name         |
      | AboveBelow 2 |
      | AboveBelow 3 |
    And I should not see records
      | name         |
      | AboveBelow 1 |
    And I follow "AboveBelow 2"
    And I should see fields with values
      | field        | type     | values       |
      | relationship | freetext | AboveBelow 2 |
      | name         | freetext | rel1         |

  @javascript
  Scenario: Can only compare 2 relationships
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Relationship Records"
    And I press "Filter"
    And I click on "Compare"
    Then I should see dialog "Please select two records to compare"
    And I confirm
    And I select records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
      | AboveBelow 3 |
    Then I click on "Compare"
    Then I should see dialog "Can only compare two records at a time"
    And I confirm

  @javascript
  Scenario: Cannot merge relationships if database is locked
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Relationship Records"
    And I press "Filter"
    And I select records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
    And I click on "Compare"
    And database is locked for "Sync Example"
    And I select the "first" record to merge to
    And I select merge fields
      | field | column |
      | name  | right  |
    And I click on "Merge"
    And I wait for popup to close
    Then I should see dialog "Could not process request as database is currently locked"
    And I confirm

  @javascript
  Scenario: Cannot merge relationships if not member of module
    Given I logout
    And I have a user "other@intersect.org.au" with role "superuser"
    And I am logged in as "other@intersect.org.au"
    And I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Relationship Records"
    And I press "Filter"
    And I select records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
    And I click on "Compare"
    And I select the "first" record to merge to
    And I select merge fields
      | field | column |
      | name  | right  |
    And I click on "Merge"
    Then I should see dialog "Only module users can edit the database. Please get a module user to add you to the module"
    And I confirm

  # TODO Scenario: Cannot compare relationships of different types

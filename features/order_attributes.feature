Feature: Order Attributes
  As a user
  I want to be able to see attributes by order

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au"
    And I have a project modules dir

  Scenario: See attributes by order in edit page
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    When I reorder attributes for "Sync Example"
      | name      |
      | name      |
      | entity    |
      | value     |
      | timestamp |
      | location  |
      | filename  |
      | picture   |
      | video     |
      | audio     |
    And I refresh page
    Then I should see attributes in order
      | name      |
      | name      |
      | entity    |
      | value     |
      | timestamp |
      | location  |
      | location  |
      | filename  |
      | picture   |
      | video     |
      | audio     |
    When I reorder attributes for "Sync Example"
      | name      |
      | picture   |
      | video     |
      | timestamp |
      | entity    |
      | value     |
      | location  |
      | name      |
      | filename  |
      | audio     |
    And I refresh page
    Then I should see attributes in order
      | name      |
      | picture   |
      | video     |
      | timestamp |
      | entity    |
      | value     |
      | location  |
      | location  |
      | name      |
      | filename  |
      | audio     |

  @javascript
  Scenario: See attributes by order in comparison page
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Entity Records"
    And I press "Filter"
    When I reorder attributes for "Sync Example"
      | name      |
      | name      |
      | entity    |
      | value     |
      | timestamp |
      | location  |
      | filename  |
      | picture   |
      | video     |
      | audio     |
    And I select records
      | name    |
      | Small 2 |
      | Small 3 |
    And I click on "Compare"
    Then I should see compare attributes in order
      | name      |
      | name      |
      | entity    |
      | value     |
      | timestamp |
      | location  |
      | filename  |
      | picture   |
      | video     |
      | audio     |
    When I reorder attributes for "Sync Example"
      | name      |
      | picture   |
      | video     |
      | timestamp |
      | entity    |
      | value     |
      | location  |
      | name      |
      | filename  |
      | audio     |
    And I click on "Back"
    And I select records
      | name    |
      | Small 2 |
      | Small 3 |
    And I click on "Compare"
    Then I should see compare attributes in order
      | name      |
      | picture   |
      | video     |
      | timestamp |
      | entity    |
      | value     |
      | location  |
      | name      |
      | filename  |
      | audio     |

  Scenario: See attributes by order in history page
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    And I follow "Show History"
    When I reorder attributes for "Sync Example"
      | name      |
      | name      |
      | entity    |
      | value     |
      | timestamp |
      | location  |
      | filename  |
      | picture   |
      | video     |
      | audio     |
    And I refresh page
    Then I should see history attributes in order
      | name      |
      | name      |
      | entity    |
      | value     |
      | timestamp |
      | location  |
      | Geometry  |
    When I reorder attributes for "Sync Example"
      | name      |
      | picture   |
      | video     |
      | timestamp |
      | entity    |
      | value     |
      | location  |
      | name      |
      | filename  |
      | audio     |
    And I refresh page
    Then I should see history attributes in order
      | name      |
      | timestamp |
      | entity    |
      | value     |
      | location  |
      | name      |
      | Geometry  |
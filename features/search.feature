Feature: Search entities
  In order to view search entities
  As a user
  I want to search by user, type and query

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au"
    And I have a project modules dir

  Scenario: Search all entities
    Given I have project module "Search"
    And I am on the project modules page
    And I follow "Search"
    And I follow "Search Entity Records"
    And I press "Search"
    Then I should search table
      | Identifier     | Created at          | Created by  | Last modified at    | Last modified by | Actions |
      | apple 1.0 1.0  | 2014-10-15 22:35:51 | Faims Admin | 2014-10-15 22:35:51 | Faims Admin      |         |
      | orange 1.0 1.0 | 2014-10-15 22:36:44 | John Wick   | 2014-10-15 22:36:44 | John Wick        |         |
      | Hugh 1.0 1.0   | 2014-10-15 22:37:03 | Any Body    | 2014-10-15 22:37:03 | Any Body         |         |
      | echo 1.0 1.0   | 2014-10-15 22:37:20 | Faims Admin | 2014-10-15 22:37:20 | Faims Admin      |         |

  Scenario: Search entities by type
    Given I have project module "Search"
    And I am on the project modules page
    And I follow "Search"
    And I follow "Search Entity Records"
    And I select search type "Filter type by small"
    And I press "Search"
    Then I should search table
      | Identifier     | Created at          | Created by  | Last modified at    | Last modified by | Actions |
      | apple 1.0 1.0  | 2014-10-15 22:35:51 | Faims Admin | 2014-10-15 22:35:51 | Faims Admin      |         |
      | Hugh 1.0 1.0   | 2014-10-15 22:37:03 | Any Body    | 2014-10-15 22:37:03 | Any Body         |         |

  Scenario: Search entities by user
    Given I have project module "Search"
    And I am on the project modules page
    And I follow "Search"
    And I follow "Search Entity Records"
    And I select search user "Created at/Last modified by John Wick"
    And I press "Search"
    Then I should search table
      | Identifier     | Created at          | Created by  | Last modified at    | Last modified by | Actions |
      | orange 1.0 1.0 | 2014-10-15 22:36:44 | John Wick   | 2014-10-15 22:36:44 | John Wick        |         |

  Scenario: Search entities by query
    Given I have project module "Search"
    And I am on the project modules page
    And I follow "Search"
    And I follow "Search Entity Records"
    And I enter search query "apple"
    And I press "Search"
    Then I should search table
      | Identifier     | Created at          | Created by  | Last modified at    | Last modified by | Actions |
      | apple 1.0 1.0  | 2014-10-15 22:35:51 | Faims Admin | 2014-10-15 22:35:51 | Faims Admin      |         |

  Scenario: Search entities by type, user and query
    Given I have project module "Search"
    And I am on the project modules page
    And I follow "Search"
    And I follow "Search Entity Records"
    And I select search type "Filter type by small"
    And I select search user "Created at/Last modified by Faims Admin"
    And I enter search query "apple"
    And I press "Search"
    Then I should search table
      | Identifier     | Created at          | Created by  | Last modified at    | Last modified by | Actions |
      | apple 1.0 1.0  | 2014-10-15 22:35:51 | Faims Admin | 2014-10-15 22:35:51 | Faims Admin      |         |


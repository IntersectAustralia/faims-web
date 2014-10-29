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
      | Identifier | Created at          | Created by  | Last modified at    | Last modified by |
      | Small 1    | 2014-10-22 04:41:00 | Faims Admin | 2014-10-22 04:41:00 | Faims Admin      |
      | Small 2    | 2014-10-22 04:41:09 | Faims Admin | 2014-10-22 04:41:09 | Faims Admin      |
      | Small 3    | 2014-10-22 04:41:17 | Faims Admin | 2014-10-22 04:41:17 | Faims Admin      |
      | Small 4    | 2014-10-22 04:44:37 | User1 Last1 | 2014-10-22 04:44:37 | User1 Last1      |
      | Small 5    | 2014-10-22 04:44:47 | User2 Last2 | 2014-10-22 04:44:47 | User2 Last2      |

  Scenario: Search entities by type
    Given I have project module "Search"
    And I am on the project modules page
    And I follow "Search"
    And I follow "Search Entity Records"
    And I select search type "Filter type by small"
    And I press "Search"
    Then I should search table
      | Identifier | Created at          | Created by  | Last modified at    | Last modified by |
      | Small 1    | 2014-10-22 04:41:00 | Faims Admin | 2014-10-22 04:41:00 | Faims Admin      |
      | Small 2    | 2014-10-22 04:41:09 | Faims Admin | 2014-10-22 04:41:09 | Faims Admin      |
      | Small 3    | 2014-10-22 04:41:17 | Faims Admin | 2014-10-22 04:41:17 | Faims Admin      |
      | Small 4    | 2014-10-22 04:44:37 | User1 Last1 | 2014-10-22 04:44:37 | User1 Last1      |
      | Small 5    | 2014-10-22 04:44:47 | User2 Last2 | 2014-10-22 04:44:47 | User2 Last2      |

  Scenario: Search entities by user
    Given I have project module "Search"
    And I am on the project modules page
    And I follow "Search"
    And I follow "Search Entity Records"
    And I select search user "Created/Last modified by Faims Admin"
    And I press "Search"
    Then I should search table
      | Identifier | Created at          | Created by  | Last modified at    | Last modified by |
      | Small 1    | 2014-10-22 04:41:00 | Faims Admin | 2014-10-22 04:41:00 | Faims Admin      |
      | Small 2    | 2014-10-22 04:41:09 | Faims Admin | 2014-10-22 04:41:09 | Faims Admin      |
      | Small 3    | 2014-10-22 04:41:17 | Faims Admin | 2014-10-22 04:41:17 | Faims Admin      |

  Scenario: Search entities by query
    Given I have project module "Search"
    And I am on the project modules page
    And I follow "Search"
    And I follow "Search Entity Records"
    And I enter search query "Small 1"
    And I press "Search"
    Then I should search table
      | Identifier | Created at          | Created by  | Last modified at    | Last modified by |
      | Small 1    | 2014-10-22 04:41:00 | Faims Admin | 2014-10-22 04:41:00 | Faims Admin      |

  Scenario: Search entities by type, user and query
    Given I have project module "Search"
    And I am on the project modules page
    And I follow "Search"
    And I follow "Search Entity Records"
    And I select search type "Filter type by small"
    And I select search user "Created/Last modified by Faims Admin"
    And I enter search query "Small 1"
    And I press "Search"
    Then I should search table
      | Identifier | Created at          | Created by  | Last modified at    | Last modified by |
      | Small 1    | 2014-10-22 04:41:00 | Faims Admin | 2014-10-22 04:41:00 | Faims Admin      |


Feature: Format entities
  In order to view formatted entity attributes
  As a user
  I want to supply format strings and view entity attributes in lists and other views as formatted

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au"
    And I have a project modules dir

  Scenario: View entity in list page with no format string and default append character string
    Given I have project module "Formatter"
    And I update format string for module "Formatter" attribute "name" with ""
    And I update format string for module "Formatter" attribute "description" with ""
    And I update format string for module "Formatter" attribute "location" with ""
    And I am on the project modules page
    And I follow "Formatter"
    And I follow "Search Entity Records"
    And I press "Search"
    Then I should see records
      | name                                                                            |
      | john, 1.0 engineer, 1.0 Location B, 1.0 \| Location C, 1.0                      |
      | jack, 1.0 programmer, 1.0 Location B, 1.0 \| Location C, 1.0 \| Location D, 1.0 |

  Scenario: View entity in list page with no format string and custom append character string
    Given I have project module "Formatter"
    And I update format string for module "Formatter" attribute "name" with ""
    And I update format string for module "Formatter" attribute "description" with ""
    And I update format string for module "Formatter" attribute "location" with ""
    And I update append character string for module "Formatter" attribute "location" with " & "
    And I am on the project modules page
    And I follow "Formatter"
    And I follow "Search Entity Records"
    And I press "Search"
    Then I should see records
      | name                                                                          |
      | john, 1.0 engineer, 1.0 Location B, 1.0 & Location C, 1.0                     |
      | jack, 1.0 programmer, 1.0 Location B, 1.0 & Location C, 1.0 & Location D, 1.0 |

  Scenario: View entity in list page with custom format string and default append character string
    Given I have project module "Formatter"
    And I update format string for module "Formatter" attribute "name" with "$2 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update format string for module "Formatter" attribute "description" with "$2 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update format string for module "Formatter" attribute "location" with "$1 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I am on the project modules page
    And I follow "Formatter"
    And I follow "Search Entity Records"
    And I press "Search"
    Then I should see records
      | name                                                                       |
      | john 1.0 engineer 1.0 Location B 1.0 \| Location C 1.0                     |
      | jack 1.0 programmer 1.0 Location B 1.0 \| Location C 1.0 \| Location D 1.0 |

  Scenario: View entity in list page with custom format string and custom append character string
    Given I have project module "Formatter"
    And I update format string for module "Formatter" attribute "name" with "$2 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update format string for module "Formatter" attribute "description" with "$2 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update format string for module "Formatter" attribute "location" with "$1 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update append character string for module "Formatter" attribute "location" with " & "
    And I am on the project modules page
    And I follow "Formatter"
    And I follow "Search Entity Records"
    And I press "Search"
    Then I should see records
      | name                                                                     |
      | john 1.0 engineer 1.0 Location B 1.0 & Location C 1.0                    |
      | jack 1.0 programmer 1.0 Location B 1.0 & Location C 1.0 & Location D 1.0 |

  @javascript
  Scenario: View entity in compare page with no format string and default append character string
    Given I have project module "Formatter"
    And I update format string for module "Formatter" attribute "name" with ""
    And I update format string for module "Formatter" attribute "description" with ""
    And I update format string for module "Formatter" attribute "location" with ""
    And I am on the project modules page
    And I follow "Formatter"
    And I follow "Search Entity Records"
    And I press "Search"
    And I select records
      | name                                                                            |
      | john, 1.0 engineer, 1.0 Location B, 1.0 \| Location C, 1.0                      |
      | jack, 1.0 programmer, 1.0 Location B, 1.0 \| Location C, 1.0 \| Location D, 1.0 |
    And I click on "Compare"
    Then I should see compare identifiers with format
      | name                                                                            |
      | john, 1.0 engineer, 1.0 Location B, 1.0 \| Location C, 1.0                      |
      | jack, 1.0 programmer, 1.0 Location B, 1.0 \| Location C, 1.0 \| Location D, 1.0 |
    And I should see compare attributes with format
      | attribute   | name                                                  |
      | name        | john, 1.0                                             |
      | name        | jack, 1.0                                             |
      | description | engineer, 1.0                                         |
      | description | programmer, 1.0                                       |
      | location    | Location B, 1.0 \| Location C, 1.0                    |
      | location    | Location B, 1.0 \| Location C, 1.0 \| Location D, 1.0 |

  @javascript
  Scenario: View entity in compare page with no format string and custom append character string
    Given I have project module "Formatter"
    And I update format string for module "Formatter" attribute "name" with ""
    And I update format string for module "Formatter" attribute "description" with ""
    And I update format string for module "Formatter" attribute "location" with ""
    And I update append character string for module "Formatter" attribute "location" with " & "
    And I am on the project modules page
    And I follow "Formatter"
    And I follow "Search Entity Records"
    And I press "Search"
    And I select records
      | name                                                                          |
      | john, 1.0 engineer, 1.0 Location B, 1.0 & Location C, 1.0                     |
      | jack, 1.0 programmer, 1.0 Location B, 1.0 & Location C, 1.0 & Location D, 1.0 |
    And I click on "Compare"
    Then I should see compare identifiers with format
      | name                                                                          |
      | john, 1.0 engineer, 1.0 Location B, 1.0 & Location C, 1.0                     |
      | jack, 1.0 programmer, 1.0 Location B, 1.0 & Location C, 1.0 & Location D, 1.0 |
    And I should see compare attributes with format
      | attribute   | name                                                |
      | name        | john, 1.0                                           |
      | name        | jack, 1.0                                           |
      | description | engineer, 1.0                                       |
      | description | programmer, 1.0                                     |
      | location    | Location B, 1.0 & Location C, 1.0                   |
      | location    | Location B, 1.0 & Location C, 1.0 & Location D, 1.0 |

  @javascript
  Scenario: View entity in compare page with custom format string and default append character string
    Given I have project module "Formatter"
    And I update format string for module "Formatter" attribute "name" with "$2 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update format string for module "Formatter" attribute "description" with "$2 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update format string for module "Formatter" attribute "location" with "$1 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I am on the project modules page
    And I follow "Formatter"
    And I follow "Search Entity Records"
    And I press "Search"
    And I select records
      | name                                                                       |
      | john 1.0 engineer 1.0 Location B 1.0 \| Location C 1.0                     |
      | jack 1.0 programmer 1.0 Location B 1.0 \| Location C 1.0 \| Location D 1.0 |
    And I click on "Compare"
    Then I should see compare identifiers with format
      | name                                                                       |
      | john 1.0 engineer 1.0 Location B 1.0 \| Location C 1.0                     |
      | jack 1.0 programmer 1.0 Location B 1.0 \| Location C 1.0 \| Location D 1.0 |
    And I should see compare attributes with format
      | attribute   | name                                               |
      | name        | john 1.0                                           |
      | name        | jack 1.0                                           |
      | description | engineer 1.0                                       |
      | description | programmer 1.0                                     |
      | location    | Location B 1.0 \| Location C 1.0                   |
      | location    | Location B 1.0 \| Location C 1.0 \| Location D 1.0 |

  @javascript
  Scenario: View entity in compare page with custom format string and custom append character string
    Given I have project module "Formatter"
    And I update format string for module "Formatter" attribute "name" with "$2 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update format string for module "Formatter" attribute "description" with "$2 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update format string for module "Formatter" attribute "location" with "$1 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update append character string for module "Formatter" attribute "location" with " & "
    And I am on the project modules page
    And I follow "Formatter"
    And I follow "Search Entity Records"
    And I press "Search"
    And I select records
      | name                                                                     |
      | john 1.0 engineer 1.0 Location B 1.0 & Location C 1.0                    |
      | jack 1.0 programmer 1.0 Location B 1.0 & Location C 1.0 & Location D 1.0 |
    And I click on "Compare"
    Then I should see compare identifiers with format
      | name                                                                     |
      | john 1.0 engineer 1.0 Location B 1.0 & Location C 1.0                    |
      | jack 1.0 programmer 1.0 Location B 1.0 & Location C 1.0 & Location D 1.0 |
    And I should see compare attributes with format
      | attribute   | name                                             |
      | name        | john 1.0                                         |
      | name        | jack 1.0                                         |
      | description | engineer 1.0                                     |
      | description | programmer 1.0                                   |
      | location    | Location B 1.0 & Location C 1.0                  |
      | location    | Location B 1.0 & Location C 1.0 & Location D 1.0 |

  Scenario: I should see related entities with no format string and default append character string
    Given I have project module "Formatter"
    And I update format string for module "Formatter" attribute "name" with ""
    And I update format string for module "Formatter" attribute "description" with ""
    And I update format string for module "Formatter" attribute "location" with ""
    And I am on the project modules page
    And I follow "Formatter"
    And I follow "Search Entity Records"
    And I press "Search"
    And I follow "john, 1.0 engineer, 1.0 Location B, 1.0 | Location C, 1.0"
    Then I should see related arch entities
      | name                                                                                                         |
      | small works with AboveBelow: jack, 1.0 programmer, 1.0 Location B, 1.0 \| Location C, 1.0 \| Location D, 1.0 |
    And I follow "small works with AboveBelow: jack, 1.0 programmer, 1.0 Location B, 1.0 | Location C, 1.0 | Location D, 1.0"
    Then I should see related arch entities
      | name                                                                                    |
      | small works with AboveBelow: john, 1.0 engineer, 1.0 Location B, 1.0 \| Location C, 1.0 |

  Scenario: I should see related entities with no format string and custom append character string
    Given I have project module "Formatter"
    And I update format string for module "Formatter" attribute "name" with ""
    And I update format string for module "Formatter" attribute "description" with ""
    And I update format string for module "Formatter" attribute "location" with ""
    And I update append character string for module "Formatter" attribute "location" with " & "
    And I am on the project modules page
    And I follow "Formatter"
    And I follow "Search Entity Records"
    And I press "Search"
    And I follow "john, 1.0 engineer, 1.0 Location B, 1.0 & Location C, 1.0"
    Then I should see related arch entities
      | name                                                                                                       |
      | small works with AboveBelow: jack, 1.0 programmer, 1.0 Location B, 1.0 & Location C, 1.0 & Location D, 1.0 |
    And I follow "small works with AboveBelow: jack, 1.0 programmer, 1.0 Location B, 1.0 & Location C, 1.0 & Location D, 1.0"
    Then I should see related arch entities
      | name                                                                                   |
      | small works with AboveBelow: john, 1.0 engineer, 1.0 Location B, 1.0 & Location C, 1.0 |

  Scenario: I should see related entities with no format string and default append character string
    Given I have project module "Formatter"
    And I update format string for module "Formatter" attribute "name" with "$2 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update format string for module "Formatter" attribute "description" with "$2 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update format string for module "Formatter" attribute "location" with "$1 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I am on the project modules page
    And I follow "Formatter"
    And I follow "Search Entity Records"
    And I press "Search"
    And I follow "john 1.0 engineer 1.0 Location B 1.0 | Location C 1.0"
    Then I should see related arch entities
      | name                                                                                                    |
      | small works with AboveBelow: jack 1.0 programmer 1.0 Location B 1.0 \| Location C 1.0 \| Location D 1.0 |
    And I follow "small works with AboveBelow: jack 1.0 programmer 1.0 Location B 1.0 | Location C 1.0 | Location D 1.0"
    Then I should see related arch entities
      | name                                                                                |
      | small works with AboveBelow: john 1.0 engineer 1.0 Location B 1.0 \| Location C 1.0 |

  Scenario: I should see related entities with no format string and default append character string
    Given I have project module "Formatter"
    And I update format string for module "Formatter" attribute "name" with "$2 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update format string for module "Formatter" attribute "description" with "$2 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update format string for module "Formatter" attribute "location" with "$1 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update append character string for module "Formatter" attribute "location" with " & "
    And I am on the project modules page
    And I follow "Formatter"
    And I follow "Search Entity Records"
    And I press "Search"
    And I follow "john 1.0 engineer 1.0 Location B 1.0 & Location C 1.0"
    Then I should see related arch entities
      | name                                                                                                  |
      | small works with AboveBelow: jack 1.0 programmer 1.0 Location B 1.0 & Location C 1.0 & Location D 1.0 |
    And I follow "small works with AboveBelow: jack 1.0 programmer 1.0 Location B 1.0 & Location C 1.0 & Location D 1.0"
    Then I should see related arch entities
      | name                                                                               |
      | small works with AboveBelow: john 1.0 engineer 1.0 Location B 1.0 & Location C 1.0 |

  @ignore_jenkins
  Scenario: View entity in history page with no format string and default append character string
    Given I have project module "Formatter"
    And I update format string for module "Formatter" attribute "name" with ""
    And I update format string for module "Formatter" attribute "description" with ""
    And I update format string for module "Formatter" attribute "location" with ""
    And I am on the project modules page
    And I follow "Formatter"
    And I follow "Search Entity Records"
    And I press "Search"
    And I follow "john, 1.0 engineer, 1.0 Location B, 1.0 | Location C, 1.0"
    And I follow "Show History"
    Then I should see history attributes with format
      | attribute   | name                               |
      | name        | john, 1.0                          |
      | description | engineer, 1.0                      |
      | location    | Location B, 1.0 \| Location C, 1.0 |

  @ignore_jenkins
  Scenario: View entity in history page with no format string and custom append character string
    Given I have project module "Formatter"
    And I update format string for module "Formatter" attribute "name" with ""
    And I update format string for module "Formatter" attribute "description" with ""
    And I update format string for module "Formatter" attribute "location" with ""
    And I update append character string for module "Formatter" attribute "location" with " & "
    And I am on the project modules page
    And I follow "Formatter"
    And I follow "Search Entity Records"
    And I press "Search"
    And I follow "john, 1.0 engineer, 1.0 Location B, 1.0 & Location C, 1.0"
    And I follow "Show History"
    Then I should see history attributes with format
      | attribute   | name                              |
      | name        | john, 1.0                         |
      | description | engineer, 1.0                     |
      | location    | Location B, 1.0 & Location C, 1.0 |

  @ignore_jenkins
  Scenario: View entity in history page with custom format string and default append character string
    Given I have project module "Formatter"
    And I update format string for module "Formatter" attribute "name" with "$2 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update format string for module "Formatter" attribute "description" with "$2 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update format string for module "Formatter" attribute "location" with "$1 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I am on the project modules page
    And I follow "Formatter"
    And I follow "Search Entity Records"
    And I press "Search"
    And I follow "john 1.0 engineer 1.0 Location B 1.0 | Location C 1.0"
    And I follow "Show History"
    Then I should see history attributes with format
      | attribute   | name                             |
      | name        | john 1.0                         |
      | description | engineer 1.0                     |
      | location    | Location B 1.0 \| Location C 1.0 |

  @ignore_jenkins
  Scenario: View entity in history page with custom format string and custom append character string
    Given I have project module "Formatter"
    And I update format string for module "Formatter" attribute "name" with "$2 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update format string for module "Formatter" attribute "description" with "$2 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update format string for module "Formatter" attribute "location" with "$1 {{if equal($4,'1.0') then $4 else '$4?'}}"
    And I update append character string for module "Formatter" attribute "location" with " & "
    And I am on the project modules page
    And I follow "Formatter"
    And I follow "Search Entity Records"
    And I press "Search"
    And I follow "john 1.0 engineer 1.0 Location B 1.0 & Location C 1.0"
    And I follow "Show History"
    Then I should see history attributes with format
      | attribute   | name                            |
      | name        | john 1.0                        |
      | description | engineer 1.0                    |
      | location    | Location B 1.0 & Location C 1.0 |


Feature: Edit Multivalued Attribute
  In order edit multivalued attributes for entities
  As a user
  I want to add, remove and update values for attributes

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au"
    And I have a project modules dir

  @javascript
  Scenario: I can add values to attributes
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    And I should have values for field
      | field    | Constrained Data | Unconstrained Data | Annotation | Certainty |
      | location | Location D       |                    |            | 1.0       |
      | location | Location B       |                    |            | 1.0       |
      | name     |                  |                    | test2      | 1.0       |
    And I add values to field
      | field    | Constrained Data | Unconstrained Data | Annotation | Certainty | index |
      | location | Location A       |                    | test1      | 0.12      | 0     |
      | location | Location B       |                    | test2      | 0.23      | 1     |
      | name     |                  | something          | test3      | 0.34      | 0     |
    And I refresh page
    And I should have values for field
      | field    | Constrained Data | Unconstrained Data | Annotation | Certainty |
      | location | Location D       |                    |            | 1.0       |
      | location | Location A       |                    | test1      | 0.12      |
      | location | Location B       |                    |            | 1.0       |
      | location | Location B       |                    | test2      | 0.23      |
      | name     |                  |                    | test2      | 1.0       |
      | name     |                  | something          | test3      | 0.34      |

  @javascript
  Scenario: I can remove values from attributes
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    And I should have values for field
      | field    | Constrained Data | Unconstrained Data | Annotation | Certainty |
      | location | Location D       |                    |            | 1.0       |
      | location | Location B       |                    |            | 1.0       |
      | name     |                  |                    | test2      | 1.0       |
    And I add values to field
      | field    | Constrained Data | Unconstrained Data | Annotation | Certainty | index |
      | location | Location A       |                    | test1      | 0.12      | 0     |
      | location | Location B       |                    | test2      | 0.23      | 1     |
      | name     |                  | something          | test3      | 0.34      | 0     |
    And I remove values from field
      | field    | Constrained Data | Unconstrained Data | Annotation | Certainty |
      | location | Location D       |                    |            | 1.0       |
      | location | Location A       |                    | test1      | 0.12      |
      | name     |                  |                    | test2      | 1.0       |
    And I refresh page
    Then I should have values for field
      | field    | Constrained Data | Unconstrained Data | Annotation | Certainty |
      | location | Location B       |                    |            | 1.0       |
      | location | Location B       |                    | test2      | 0.23      |
      | name     |                  | something          | test3      | 0.34      |

  @javascript
  Scenario: I can add and remove values from attributes
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    And I should have values for field
      | field    | Constrained Data | Unconstrained Data | Annotation | Certainty |
      | location | Location D       |                    |            | 1.0       |
      | location | Location B       |                    |            | 1.0       |
      | name     |                  |                    | test2      | 1.0       |
    And I add values to field
      | field    | Constrained Data | Unconstrained Data | Annotation | Certainty | index | update |
      | location | Location A       |                    | test1      | 0.12      | 0     | false  |
      | location | Location B       |                    | test2      | 0.23      | 1     | false  |
      | name     |                  | something          | test3      | 0.34      | 0     | false  |
    And I remove values from field
      | field    | Constrained Data | Unconstrained Data | Annotation | Certainty | update |
      | location | Location D       |                    |            | 1.0       | false  |
      | location | Location B       |                    |            | 1.0       | false  |
      | name     |                  |                    | test2      | 1.0       | false  |
    And I refresh page
    And I wait for page to load up data
    Then I should have values for field
      | field    | Constrained Data | Unconstrained Data | Annotation | Certainty |
      | location | Location A       |                    | test1      | 0.12      |
      | location | Location B       |                    | test2      | 0.23      |
      | name     |                  | something          | test3      | 0.34      |

  @javascript
  Scenario: I can add values to attribute and see validation error
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "Edit Module"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I press "Update"
    Then I should see "Updated module"
    And I follow "List Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    And I add values to field
      | field    | Constrained Data | Unconstrained Data | Annotation | Certainty | index |
      | location |                  |                    |            | 0.12      | 0     |
      | location |                  |                    |            | 0.23      | 0     |
      | name     |                  |                    |            | 0.34      | 0     |
      | name     |                  |                    |            | 0.43      | 0     |
    Then I should have values for field
      | field    | Constrained Data | Unconstrained Data | Annotation | Certainty | error                |
      | location |                  |                    |            | 0.12      | Field value is blank |
      | location |                  |                    |            | 0.23      | Field value is blank |
      | name     |                  |                    |            | 0.34      | Field value is blank |
      | name     |                  |                    |            | 0.43      | Field value is blank |

  @javascript
  Scenario: I delete values from attributes
    Given I have project module "Sync Example"
    And I am on the project modules page
    And I follow "Sync Example"
    And I follow "List Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    And I should have values for field
      | field    | Constrained Data | Unconstrained Data | Annotation | Certainty |
      | location | Location D       |                    |            | 1.0       |
      | location | Location B       |                    |            | 1.0       |
      | name     |                  |                    | test2      | 1.0       |
    And I remove values from field
      | field    | Constrained Data | Unconstrained Data | Annotation | Certainty |
      | location | Location D       |                    |            | 1.0       |
      | location | Location B       |                    |            | 1.0       |
      | name     |                  |                    | test2      | 1.0       |
    And I refresh page
    And I wait for page to load up data
    Then I should have values for field
      | field    | Constrained Data | Unconstrained Data | Annotation | Certainty |
      | location |                  |                    |            |           |
      | name     |                  |                    |            |           |
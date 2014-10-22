Feature: Manage vocabulary
  In order manage vocabulary
  As a user
  I want to list, view and edit vocabulary

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au"
    And I have a project modules dir

  @javascript
  Scenario: View Vocabularies
    Given I have project module "Vocabulary"
    And I am on the project modules page
    And I follow "Vocabulary"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I should see vocabularies
      | name  | description | pictureURL |
      | Green |             |            |
      | Pink  |             |            |
      | Blue  |             |            |

  @javascript
  Scenario: Update Vocabulary
    Given I have project module "Vocabulary"
    And I am on the project modules page
    And I follow "Vocabulary"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    And I modify vocabulary "Green" with "Red"
    Then I click on "Update Vocabulary"
    And I should see "Successfully updated vocabulary"
    And I select "Soil Texture" for the attribute
    And I should see vocabularies
      | name | description | pictureURL |
      | Red  |             |            |
      | Pink |             |            |
      | Blue |             |            |

  @javascript
  Scenario: Insert Vocabulary
    Given I have project module "Vocabulary"
    And I am on the project modules page
    And I follow "Vocabulary"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I click on "Insert" for the attribute
    And I add "Red" to the vocabulary list
    Then I add "New color" as description to the vocabulary list
    And  I add "New picture url" as picture url to the vocabulary list
    Then I click on "Update Vocabulary"
    And I should see "Successfully updated vocabulary"
    And I select "Soil Texture" for the attribute
    And I should see vocabularies
      | name  | description | pictureURL      |
      | Green |             |                 |
      | Red   | New color   | New picture url |
      | Pink  |             |                 |
      | Blue  |             |                 |

  @javascript
  Scenario: Add Child Vocabulary
    Given I have project module "Vocabulary"
    And I am on the project modules page
    And I follow "Vocabulary"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I click add child for vocabulary "Green"
    And I add "Circle" as child for "Green"
    Then I add "A Circle" as child description for "Green"
    And  I add "Circle URL" as child picture url for "Green"
    Then I click insert for vocabulary "Green"
    And I add "Square" as child for "Green"
    Then I add "A Square" as child description for "Green"
    And  I add "Square URL" as child picture url for "Green"
    Then I click on "Update Vocabulary"
    And I should see "Successfully updated vocabulary"
    And I select "Soil Texture" for the attribute
    And I should see child vocabularies for "Green"
      | name   | description | pictureURL |
      | Square | A Square    | Square URL |
      | Circle | A Circle    | Circle URL |

  @javascript
  Scenario: Add Child To Child Vocabulary
    Given I have project module "Vocabulary"
    And I am on the project modules page
    And I follow "Vocabulary"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I click add child for vocabulary "Green"
    And I add "Circle" as child for "Green"
    Then I add "A Circle" as child description for "Green"
    And  I add "Circle URL" as child picture url for "Green"
    Then I click on "Update Vocabulary"
    And I should see "Successfully updated vocabulary"
    And I select "Soil Texture" for the attribute
    And I should see child vocabularies for "Green"
      | name   | description | pictureURL |
      | Circle | A Circle    | Circle URL |
    Then I click add child for vocabulary "Circle"
    And I add "Square" as child for "Circle"
    Then I add "A Square" as child description for "Circle"
    And  I add "Square URL" as child picture url for "Circle"
    Then I click on "Update Vocabulary"
    And I should see "Successfully updated vocabulary"
    And I select "Soil Texture" for the attribute
    And I should see child vocabularies for "Circle"
      | name   | description | pictureURL |
      | Square | A Square    | Square URL |

  @javascript
  Scenario: Cannot update vocabulary if it contains empty vocabulary name
    Given I have project module "Vocabulary"
    And I am on the project modules page
    And I follow "Vocabulary"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I click on "Insert" for the attribute
    Then I add "New color" as description to the vocabulary list
    And  I add "New picture url" as picture url to the vocabulary list
    Then I click on "Update Vocabulary"
    And I should see "Please correct the errors in this form. Vocabulary name cannot be empty"
    And I select "Soil Texture" for the attribute
    And I should see vocabularies
      | name | description | pictureURL      |
      |      | New color   | New picture url |
      | Pink |             |                 |
      | Blue |             |                 |

  @javascript
  Scenario: Cannot update vocabulary if it contains empty child vocabulary name
    Given I have project module "Vocabulary"
    And I am on the project modules page
    And I follow "Vocabulary"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I click add child for vocabulary "Green"
    And I add "Circle" as child for "Green"
    Then I add "A Circle" as child description for "Green"
    And  I add "Circle URL" as child picture url for "Green"
    Then I click insert for vocabulary "Green"
    And I add "" as child for "Green"
    Then I add "A Square" as child description for "Green"
    And  I add "Square URL" as child picture url for "Green"
    Then I click on "Update Vocabulary"
    And I should see "Please correct the errors in this form. Vocabulary name cannot be empty"
    And I select "Soil Texture" for the attribute
    And I should see child vocabularies for "Green"
      | name   | description | pictureURL |
      |        | A Square    | Square URL |
      | Circle | A Circle    | Circle URL |

  @javascript
  Scenario: Cannot update vocabulary if db is locked
    Given I have project module "Vocabulary"
    And I am on the project modules page
    And I follow "Vocabulary"
    And database is locked for "Vocabulary"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    And I modify vocabulary "Green" with "Red"
    Then I click on "Update Vocabulary"
    And I should see "Could not process request as project is currently locked."
    And I select "Soil Texture" for the attribute
    And I should see vocabularies
      | name | description | pictureURL |
      | Red  |             |            |
      | Pink |             |            |
      | Blue |             |            |

  @javascript
  Scenario: Cannot update vocabulary if user is not member of module
    Given I logout
    And I have a user "other@intersect.org.au" with role "superuser"
    And I am logged in as "other@intersect.org.au"
    And I have project module "Vocabulary"
    And I am on the project modules page
    And I follow "Vocabulary"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    And I modify vocabulary "Green" with "Red"
    Then I click on "Update Vocabulary"
    Then I should see "You are not a member of the module you are editing. Please ask a member to add you to the module before continuing."
    And I select "Soil Texture" for the attribute
    And I should see vocabularies
      | name | description | pictureURL |
      | Red  |             |            |
      | Pink |             |            |
      | Blue |             |            |
Feature: Order Attributes
  As a user
  I want to be able to see attributes by order

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au"
    And I have a project modules dir

  @javascript
  Scenario: I can move vocab down
    Given I have project module "Vocabulary"
    And I am on the project modules page
    And I follow "Vocabulary"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I should see vocabularies in order
      | name  |
      | Blue  |
      | Green |
      | Pink  |
    Then I move vocab "Blue" down
    Then I click on "Update"
    And I should see "Successfully updated vocabulary"
    And I select "Soil Texture" for the attribute
    And I should see vocabularies in order
      | name  |
      | Green |
      | Blue  |
      | Pink  |

  @javascript
  Scenario: I can move vocab up
    Given I have project module "Vocabulary"
    And I am on the project modules page
    And I follow "Vocabulary"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I should see vocabularies in order
      | name  |
      | Blue  |
      | Green |
      | Pink  |
    Then I move vocab "Green" up
    Then I click on "Update"
    And I should see "Successfully updated vocabulary"
    And I select "Soil Texture" for the attribute
    And I should see vocabularies in order
      | name  |
      | Green |
      | Blue  |
      | Pink  |

  @javascript
  Scenario: I can move child vocab down
    Given I have project module "Vocabulary"
    And I am on the project modules page
    And I follow "Vocabulary"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    And I add child vocabs for "Green"
      | name  | description | picture_url |
      | One   | One         |             |
      | Two   | Two         |             |
      | Three | Three       |             |
    Then I click on "Update"
    And I should see "Successfully updated vocabulary"
    And I select "Soil Texture" for the attribute
    Then I should see child vocabularies for "Green" in order
      | name  |
      | One   |
      | Two   |
      | Three |
    And I move vocab "One" down
    Then I click on "Update"
    And I should see "Successfully updated vocabulary"
    And I select "Soil Texture" for the attribute
    Then I should see child vocabularies for "Green" in order
      | name  |
      | Two   |
      | One   |
      | Three |

  @javascript
  Scenario: I can move child vocab up
    Given I have project module "Vocabulary"
    And I am on the project modules page
    And I follow "Vocabulary"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    And I add child vocabs for "Green"
      | name  | description | picture_url |
      | One   | One         |             |
      | Two   | Two         |             |
      | Three | Three       |             |
    Then I click on "Update"
    And I should see "Successfully updated vocabulary"
    And I select "Soil Texture" for the attribute
    Then I should see child vocabularies for "Green" in order
      | name  |
      | One   |
      | Two   |
      | Three |
    And I move vocab "Two" up
    Then I click on "Update"
    And I should see "Successfully updated vocabulary"
    And I select "Soil Texture" for the attribute
    Then I should see child vocabularies for "Green" in order
      | name  |
      | Two   |
      | One   |
      | Three |

  @javascript
  Scenario: I cannot move vocab down if last vocab
    Given I have project module "Vocabulary"
    And I am on the project modules page
    And I follow "Vocabulary"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I should see vocabularies in order
      | name  |
      | Blue  |
      | Green |
      | Pink  |
    Then I move vocab "Pink" down
    And I should see vocabularies in order
      | name  |
      | Blue  |
      | Green |
      | Pink  |

  @javascript
  Scenario: I cannot move vocab up if first vocab
    Given I have project module "Vocabulary"
    And I am on the project modules page
    And I follow "Vocabulary"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I should see vocabularies in order
      | name  |
      | Blue  |
      | Green |
      | Pink  |
    Then I move vocab "Blue" up
    And I should see vocabularies in order
      | name  |
      | Blue  |
      | Green |
      | Pink  |

  @javascript
  Scenario: I cannot move child vocab down if last vocab in parent
    Given I have project module "Vocabulary"
    And I am on the project modules page
    And I follow "Vocabulary"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    And I add child vocabs for "Green"
      | name  | description | picture_url |
      | One   | One         |             |
      | Two   | Two         |             |
      | Three | Three       |             |
    Then I click on "Update"
    And I should see "Successfully updated vocabulary"
    And I select "Soil Texture" for the attribute
    Then I should see child vocabularies for "Green" in order
      | name  |
      | One   |
      | Two   |
      | Three |
    And I move vocab "Three" down
    Then I should see child vocabularies for "Green" in order
      | name  |
      | One   |
      | Two   |
      | Three |

  @javascript
  Scenario: I cannot move child vocab up if first vocab in parent
    Given I have project module "Vocabulary"
    And I am on the project modules page
    And I follow "Vocabulary"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    And I add child vocabs for "Green"
      | name  | description | picture_url |
      | One   | One         |             |
      | Two   | Two         |             |
      | Three | Three       |             |
    Then I click on "Update"
    And I should see "Successfully updated vocabulary"
    And I select "Soil Texture" for the attribute
    Then I should see child vocabularies for "Green" in order
      | name  |
      | One   |
      | Two   |
      | Three |
    And I move vocab "One" up
    Then I should see child vocabularies for "Green" in order
      | name  |
      | One   |
      | Two   |
      | Three |
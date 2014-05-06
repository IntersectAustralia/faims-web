Feature: Manage vocabulary
  In order manage vocabulary
  As a user
  I want to list, view and edit vocabulary

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I have a user "other@intersect.org.au"
    And I am on the login page
    And I am logged in as "faimsadmin@intersect.org.au"
    And I should see "Logged in successfully."
    And I have a project modules dir

  @javascript
  Scenario: View Vocabularies
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I should see vocabularies
      | name  | description | pictureURL |
      | Green |             |            |
      | Pink  |             |            |
      | Blue  |             |            |

  @javascript
  Scenario: Update Vocabulary
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    And I modify vocabulary "Green" with "Red"
    Then I click on "Update"
    And I should see "Successfully updated vocabulary"
    And I should see vocabularies
      | name | description | pictureURL |
      | Red  |             |            |
      | Pink |             |            |
      | Blue |             |            |

  @javascript
  Scenario: Insert Vocabulary
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I click on "Insert" for the attribute
    And I add "Red" to the vocabulary list
    Then I add "New color" as description to the vocabulary list
    And  I add "New picture url" as picture url to the vocabulary list
    Then I click on "Update"
    And I should see "Successfully updated vocabulary"
    And I should see vocabularies
      | name  | description | pictureURL      |
      | Green |             |                 |
      | Red   | New color   | New picture url |
      | Pink  |             |                 |
      | Blue  |             |                 |

  @javascript
  Scenario: Add Child Vocabulary
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I follow "Module 1"
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
    Then I click on "Update"
    And I should see "Successfully updated vocabulary"
    And I should see child vocabularies for "Green"
      | name   | description | pictureURL |
      | Square | A Square    | Square URL |
      | Circle | A Circle    | Circle URL |

  @javascript
  Scenario: Add Child To Child Vocabulary
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I click add child for vocabulary "Green"
    And I add "Circle" as child for "Green"
    Then I add "A Circle" as child description for "Green"
    And  I add "Circle URL" as child picture url for "Green"
    Then I click on "Update"
    And I should see "Successfully updated vocabulary"
    And I should see child vocabularies for "Green"
      | name   | description | pictureURL |
      | Circle | A Circle    | Circle URL |
    Then I click add child for vocabulary "Circle"
    And I add "Square" as child for "Circle"
    Then I add "A Square" as child description for "Circle"
    And  I add "Square URL" as child picture url for "Circle"
    Then I click on "Update"
    And I should see "Successfully updated vocabulary"
    And I should see child vocabularies for "Circle"
      | name   | description | pictureURL |
      | Square | A Square    | Square URL |

  @javascript
  Scenario: Cannot update vocabulary if it contains empty vocabulary name
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I click on "Insert" for the attribute
    Then I add "New color" as description to the vocabulary list
    And  I add "New picture url" as picture url to the vocabulary list
    Then I click on "Update"
    And I should see "Please correct the errors in this form. Vocabulary name cannot be empty"
    And I should see vocabularies
      | name | description | pictureURL      |
      |      | New color   | New picture url |
      | Pink |             |                 |
      | Blue |             |                 |

  @javascript
  Scenario: Cannot update vocabulary if it contains empty child vocabulary name
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I follow "Module 1"
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
    Then I click on "Update"
    And I should see "Please correct the errors in this form. Vocabulary name cannot be empty"
    And I should see child vocabularies for "Green"
      | name   | description | pictureURL |
      |        | A Square    | Square URL |
      | Circle | A Circle    | Circle URL |

  @javascript
  Scenario: Cannot update vocabulary if db is locked
    Given I am on the home page
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    And I follow "Module 1"
    Then I follow "Edit Vocabulary"
    And database is locked for "Module 1"
    And I select "Soil Texture" for the attribute
    And I modify vocabulary "Green" with "Red"
    Then I click on "Update"
    And I should see "Could not process request as database is currently locked"
    And I should see vocabularies
      | name | description | pictureURL |
      | Red  |             |            |
      | Pink |             |            |
      | Blue |             |            |

  @javascript
  Scenario: Cannot update vocabulary if user is not member of module
    And I follow "Show Modules"
    Then I should be on the project modules page
    And I follow "Create Module"
    Then I should be on the new project modules page
    And I fill in "Name" with "Module 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Module_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New module created"
    And I should be on the project modules page
    Given I logout
    And I am logged in as "other@intersect.org.au"
    And I am on the home page
    And I follow "Show Modules"
    And I follow "Module 1"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    And I modify vocabulary "Green" with "Red"
    Then I click on "Update"
    Then I should see "Only module users can edit the database. Please get a module user to add you to the module"
    And I should see vocabularies
      | name | description | pictureURL |
      | Red  |             |            |
      | Pink |             |            |
      | Blue |             |            |
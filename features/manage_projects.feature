Feature: Manage projects
  In order manage projects
  As a user
  I want to list, create and edit projects

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am on the login page
    And I am logged in as "faimsadmin@intersect.org.au"
    And I should see "Logged in successfully."
    And I have a projects dir

  Scenario: List projects
    Given I am on the home page
    And I have projects
      | name      |
      | Project 1 |
      | Project 2 |
      | Project 3 |
    And I follow "Show Projects"
    Then I should see projects
      | name      |
      | Project 1 |
      | Project 2 |
      | Project 3 |

  Scenario: Create a new project
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Create Project"
    Then I should be on the new projects page
    And I fill in "Name" with "Project 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Project_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New project created."
    And I should be on the projects page
    And I have project files for "Project 1"

  Scenario: Optional validation schema
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Create Project"
    Then I should be on the new projects page
    And I fill in "Name" with "Project 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Project_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New project created."
    And I should be on the projects page
    And I have project files for "Project 1"

  Scenario: Set srid on project creation
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Create Project"
    Then I should be on the new projects page
    And I fill in "Name" with "Project 1"
    And I fill in "Project SRID" with "EPSG:4326 - WGS 84"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Project_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New project created."
    And I should be on the projects page
    And I have project files for "Project 1"
    And I should have setting "srid" for "Project 1" as "4326"

  Scenario Outline: Cannot create project due to errors
    Given I am on the home page
    And I have project "Project 1"
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Create Project"
    Then I should be on the new projects page
    And I fill in "<field>" with "<value>"
    And I press "Submit"
    Then I should see "<field>" with error "<error>"
  Examples:
    | field       | value     | error          |
    | Name        |           | can't be blank |
    | Name        | Project * | is invalid     |
    | Data Schema |           | can't be blank |
    | UI Schema   |           | can't be blank |
    | UI Logic    |           | can't be blank |

  Scenario Outline: Cannot create project due to errors
    Given I am on the home page
    And I have project "Project 1"
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Create Project"
    Then I should be on the new projects page
    And I fill in "Project Name" with "Project 2"
    And I pick file "<value>" for "<field>"
    And I press "Submit"
    Then I should see "<field>" with error "<error>"
  Examples:
    | field             | value                      | error                           |
    | Data Schema       |                            | can't be blank                  |
    | Data Schema       | garbage                    | must be xml file                |
    | Data Schema       | data_schema_error1.xml     | invalid xml at line             |
    | UI Schema         |                            | can't be blank                  |
    | UI Schema         | garbage                    | must be xml file                |
    | UI Schema         | ui_schema_error1.xml       | invalid xml at line             |
    | Validation Schema | garbage                    | must be xml file                |
    | Validation Schema | data_schema_error1.xml     | invalid xml at line             |
    | UI Logic          |                            | can't be blank                  |
    | Arch16n           | faims_Project_2.properties | invalid properties file at line |

  Scenario: Upload Project
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "project.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I have project files for "Simple Project"

  Scenario: Upload Project if project already exists should fail
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "project.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I follow "Upload Project"
    And I pick file "project.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "This project already exists in the system"

  Scenario: Upload Project with wrong checksum should fail
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "project_corrupted1.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Wrong hash sum for the project"

  Scenario: Upload Project with corrupted file should fail
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "project_corrupted2.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project failed to upload"

  Scenario: Upload Project with wrong file should fail
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "project.tar" for "Project File"
    And I press "Upload"
    Then I should see "Project failed to upload"

  Scenario Outline: Edit static data
    Given I am on the home page
    And I have project "Project 1"
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Project 1"
    Then I follow "Edit Project"
    And I fill in "<field>" with "<value>"
    And I press "Update"
    And I should have setting "<setting>" for "Project 1" as "<setting_value>"
  Examples:
    | field        | value              | setting | setting_value |
    | Project SRID | EPSG:4326 - WGS 84 | srid    | 4326          |

  Scenario Outline: Edit static data fails with errors
    Given I am on the home page
    And I have project "Project 1"
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Project 1"
    Then I follow "Edit Project"
    And I fill in "<field>" with "<value>"
    And I press "Update"
    Then I should see "<field>" with error "<error>"
  Examples:
    | field        | value     | error          |
    | Project Name |           | can't be blank |
    | Project Name | Project * | is invalid     |

  Scenario: Edit project but not upload new file
    Given I am on the home page
    And I have project "Project 1"
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Project 1"
    Then I follow "Edit Project"
    And I press "Update"
    Then I should see "Successfully updated project"

  Scenario: Cannot edit project if project is locked
    Given I am on the home page
    And I have project "Project 1"
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Project 1"
    Then I follow "Edit Project"
    And settings is locked for "Project 1"
    And I press "Update"
    Then I should see "Could not process request as project is currently locked"

  Scenario: Edit project and upload correct file
    Given I am on the home page
    And I have project "Project 1"
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Project 1"
    Then I follow "Edit Project"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Project_1.properties" for "Arch16n"
    And I press "Update"
    Then I should see "Successfully updated project"

  Scenario: Edit project and upload correct file so project has correct file
    Given I am on the home page
    And I have project "Project 1"
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Project 1"
    Then I follow "Edit Project"
    And I pick file "faims_Project_1.properties" for "Arch16n"
    And I press "Update"
    Then I should see "Successfully updated project"
    And Project "Project 1" should have the same file "faims.properties"

  Scenario Outline: Edit project and upload incorrect file
    Given I am on the home page
    And I have project "Project 2"
    And I follow "Show Projects"
    Then I should be on the projects page
    And I click on "Project 2"
    Then I follow "Edit Project"
    And I pick file "<value>" for "<field>"
    And I press "Update"
    Then I should see "<field>" with error "<error>"
  Examples:
    | field             | value                      | error                           |
    | UI Schema         | garbage                    | must be xml file                |
    | UI Schema         | ui_schema_error1.xml       | invalid xml at line             |
    | Validation Schema | garbage                    | must be xml file                |
    | Validation Schema | data_schema_error1.xml     | invalid xml at line             |
    | Arch16n           | faims_Project_2.properties | invalid properties file at line |

  Scenario: Download package
    Given I have project "Project 1"
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Project 1"
    And I automatically archive project package "Project 1"
    And I automatically download project package "Project 1"
    Then I should download project package file for "Project 1"

  @javascript
  Scenario: Cannot download package if project is locked
    Given I have project "Project 1"
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Project 1"
    And database is locked for "Project 1"
    And I follow "Download Project"
    Then I should see dialog "Could not process request as project is currently locked"

  Scenario: See attached files for arch ent
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Test.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I click on "Sync Test"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    And I select the first record
    Then I should see attached files
      | name                                   |
      | Screenshot_2013-04-09-10-32-04.png     |
      | Screenshot_2013-04-09-10-32-04 (1).png |

  Scenario: See attached files for arch ent if some files don't exist
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Test.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I click on "Sync Test"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    And I select the first record
    Then I should see attached files
      | name                                   |
      | Screenshot_2013-04-09-10-32-04.png     |
      | Screenshot_2013-04-09-10-32-04 (1).png |
    Then I remove all files for "Sync Test"
    Then I should see non attached files
      | name                                   |
      | Screenshot_2013-04-09-10-32-04.png     |
      | Screenshot_2013-04-09-10-32-04 (1).png |


#  @javascript
#  Scenario: Download attached file for arch ent
#    Given I am on the home page
#    And I follow "Show Projects"
#    Then I should be on the projects page
#    And I wait
#    And I follow "Upload Project"
#    And I pick file "Sync_Test.tar.bz2" for "Project File"
#    And I press "Upload"
#    Then I should see "Project has been successfully uploaded"
#    And I should be on the projects page
#    And I click on "Sync Test"
#    Then I follow "Search Archaeological Entity Records"
#    And I enter "" and submit the form
#    And I select the first record
#    Then I click file with name "Screenshot_2013-04-09-10-32-04(1).png"
#    And I should download attached file with name "Screenshot_2013-04-09-10-32-04(1).png"

  Scenario: See attached files for relationship
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Test.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I click on "Sync Test"
    Then I follow "Search Relationship Records"
    And I enter "" and submit the form
    And I select the first record
    Then I should see attached files
      | name                                   |
      | Screenshot_2013-04-29-16-38-51.png     |
      | Screenshot_2013-04-29-16-38-51 (1).png |
    Then I remove all files for "Sync Test"

  Scenario: See attached files for relationship if some files don't exist
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Test.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I click on "Sync Test"
    Then I follow "Search Relationship Records"
    And I enter "" and submit the form
    And I select the first record
    Then I should see attached files
      | name                                   |
      | Screenshot_2013-04-29-16-38-51.png     |
      | Screenshot_2013-04-29-16-38-51 (1).png |
    Then I remove all files for "Sync Test"
    Then I should see non attached files
      | name                                   |
      | Screenshot_2013-04-29-16-38-51.png     |
      | Screenshot_2013-04-29-16-38-51 (1).png |

#  @javascript
#  Scenario: Download attached file for relationship
#    Given I am on the home page
#    And I follow "Show Projects"
#    Then I should be on the projects page
#    And I wait
#    And I follow "Upload Project"
#    And I pick file "Sync_Test.tar.bz2" for "Project File"
#    And I press "Upload"
#    Then I should see "Project has been successfully uploaded"
#    And I should be on the projects page
#    And I click on "Sync Test"
#    Then I follow "Search Relationship Records"
#    And I enter "" and submit the form
#    And I select the first record
#    Then I click file with name "Screenshot_2013-04-29-16-38-51(1).png"
#    And I should download attached file with name "Screenshot_2013-04-29-16-38-51(1).png"

  @javascript
  Scenario: View Vocabularies
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Create Project"
    Then I should be on the new projects page
    And I fill in "Name" with "Project 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Project_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New project created."
    And I should be on the projects page
    And I follow "Project 1"
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
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Create Project"
    Then I should be on the new projects page
    And I fill in "Name" with "Project 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Project_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New project created."
    And I should be on the projects page
    And I follow "Project 1"
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
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Create Project"
    Then I should be on the new projects page
    And I fill in "Name" with "Project 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Project_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New project created."
    And I should be on the projects page
    And I follow "Project 1"
    Then I follow "Edit Vocabulary"
    And I select "Soil Texture" for the attribute
    Then I click on "Insert"
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
  Scenario: Cannot update vocabulary if db is locked
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Create Project"
    Then I should be on the new projects page
    And I fill in "Name" with "Project 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Project_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New project created."
    And I should be on the projects page
    And I follow "Project 1"
    Then I follow "Edit Vocabulary"
    And database is locked for "Project 1"
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
  Scenario: Cannot update vocabulary if db is locked
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Create Project"
    Then I should be on the new projects page
    And I fill in "Name" with "Project 1"
    And I pick file "data_schema.xml" for "Data Schema"
    And I pick file "ui_schema.xml" for "UI Schema"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I pick file "ui_logic.bsh" for "UI Logic"
    And I pick file "faims_Project_1.properties" for "Arch16n"
    And I press "Submit"
    Then I should see "New project created."
    And I should be on the projects page
    And I follow "Project 1"
    Then I follow "Edit Vocabulary"
    And database is locked for "Project 1"
    And I select "Soil Texture" for the attribute
    Then I click on "Insert"
    And I add "Red" to the vocabulary list
    Then I add "New color" as description to the vocabulary list
    And  I add "New picture url" as picture url to the vocabulary list
    Then I click on "Update"
    And I should see "Could not process request as database is currently locked"
    And I should see vocabularies
      | name  | description | pictureURL      |
      | Green |             |                 |
      | Red   | New color   | New picture url |
      | Pink  |             |                 |
      | Blue  |             |                 |

  @javascript
  Scenario: Seeing users to be added for project
    Given I have users
      | first_name | last_name | email                  |
      | User1      | Last1     | user1@intersect.org.au |
      | User2      | Last2     | user2@intersect.org.au |
    And I have project "Project 1"
    Then I follow "Show Projects"
    And I should be on the projects page
    And I follow "Project 1"
    Then I follow "Edit Users"
    And I should have user for selection
      | name        |
      | User1 Last1 |
      | User2 Last2 |

  @javascript
  Scenario: Adding users to the project
    Given I have users
      | first_name | last_name | email                  |
      | User1      | Last1     | user1@intersect.org.au |
      | User2      | Last2     | user2@intersect.org.au |
    And I have project "Project 1"
    And I add "faimsadmin@intersect.org.au" to "Project 1"
    Then I follow "Show Projects"
    And I should be on the projects page
    And I follow "Project 1"
    Then I follow "Edit User"
    And I select "User1 Last1" from the user list
    Then I click on "Add"
    And I should see "Successfully updated user"
    And I should have user for project
      | first_name | last_name |
      | Fred       | Bloggs    |
      | User1      | Last1     |

  @javascript
  Scenario: Cannot add user to project if database is locked
    Given I have users
      | first_name | last_name | email                  |
      | User1      | Last1     | user1@intersect.org.au |
      | User2      | Last2     | user2@intersect.org.au |
    And I have project "Project 1"
    And I add "faimsadmin@intersect.org.au" to "Project 1"
    Then I follow "Show Projects"
    And I should be on the projects page
    And I follow "Project 1"
    Then I follow "Edit User"
    And database is locked for "Project 1"
    And I select "User1 Last1" from the user list
    Then I click on "Add"
    And I should see "Could not process request as database is currently locked"
    And I should have user for project
      | first_name | last_name |
      | Fred       | Bloggs    |
    And I should not have user for project
      | first_name | last_name |
      | User1      | Last1     |

  Scenario: Show arch entity list not include the deleted value
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    Then I should see records
      | name    |
      | Small 2 |
      | Small 3 |
      | Small 4 |

  @javascript
  Scenario: Show arch entity list include the deleted value
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    And I click on "Show Deleted"
    Then I should see records
      | name    |
      | Small 1 |
      | Small 2 |
      | Small 3 |
      | Small 4 |

  @javascript
  Scenario: Delete arch entity
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    Then I follow "Small 3"
    And I click on "Delete"
    And I confirm
    Then I should see "Deleted Archaeological Entity"
    Then I should not see records
      | name    |
      | Small 1 |
      | Small 3 |

  @javascript
  Scenario: Cannot delete arch entity if database locked
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    Then I follow "Small 3"
    And database is locked for "Sync Example"
    And I click on "Delete"
    And I confirm
    And I wait for page
    Then I should see "Could not process request as database is currently locked"
    And I follow "Back"
    Then I should see records
      | name    |
      | Small 3 |

  @javascript
  Scenario: Restore arch entity
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    Then I follow "Small 3"
    Then I click on "Delete"
    And I confirm
    Then I click on "Show Deleted"
    Then I follow "Small 3"
    Then I click on "Restore"
    And I should see "Restored Archaeological Entity"
    Then I follow "Back"
    Then I click on "Hide Deleted"
    And I should not see records
      | name    |
      | Small 1 |
    But I should see records
      | name    |
      | Small 3 |

  @javascript
  Scenario: Cannot restore arch entity if database is locked
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    Then I follow "Small 3"
    Then I click on "Delete"
    And I confirm
    Then I click on "Show Deleted"
    Then I follow "Small 3"
    And database is locked for "Sync Example"
    Then I click on "Restore"
    And I wait for page
    And I should see "Could not process request as database is currently locked"
    And I follow "Back"
    Then I click on "Hide Deleted"
    And I should not see records
      | name    |
      | Small 1 |
      | Small 3 |

  Scenario: Show relationship list not include the deleted value
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "Search Relationship Records"
    And I enter "" and submit the form
    Then I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
      | AboveBelow 3 |

  @javascript
  Scenario: Show relationship list include the deleted value
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "Search Relationship Records"
    And I enter "" and submit the form
    And I click on "Show Deleted"
    Then I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
      | AboveBelow 3 |
      | AboveBelow 4 |

  @javascript
  Scenario: Delete relationship
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "Search Relationship Records"
    And I enter "" and submit the form
    Then I follow "AboveBelow 2"
    And I click on "Delete"
    And I confirm
    Then I should see "Deleted Relationship"
    Then I should not see records
      | name         |
      | AboveBelow 2 |
      | AboveBelow 4 |

  @javascript
  Scenario: Cannot delete relationship if database is locked
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "Search Relationship Records"
    And I enter "" and submit the form
    Then I follow "AboveBelow 2"
    And database is locked for "Sync Example"
    And I click on "Delete"
    And I confirm
    And I wait for page
    Then I should see "Could not process request as database is currently locked"
    And I follow "Back"
    Then I should see records
      | name         |
      | AboveBelow 2 |

  @javascript
  Scenario: Restore relationship
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "Search Relationship Records"
    And I enter "" and submit the form
    Then I follow "AboveBelow 2"
    Then I click on "Delete"
    And I confirm
    Then I click on "Show Deleted"
    Then I follow "AboveBelow 2"
    Then I click on "Restore"
    And I should see "Restored Relationship"
    Then I follow "Back"
    Then I click on "Hide Deleted"
    And I should not see records
      | name         |
      | AboveBelow 4 |
    But I should see records
      | name         |
      | AboveBelow 2 |

  @javascript
  Scenario: Cannot restore relationship if database is locked
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "Search Relationship Records"
    And I enter "" and submit the form
    Then I follow "AboveBelow 2"
    Then I click on "Delete"
    And I confirm
    Then I click on "Show Deleted"
    Then I follow "AboveBelow 2"
    And database is locked for "Sync Example"
    Then I click on "Restore"
    And I wait for page
    And I should see "Could not process request as database is currently locked"
    Then I follow "Back"
    Then I click on "Hide Deleted"
    And I should not see records
      | name         |
      | AboveBelow 2 |
      | AboveBelow 4 |

  Scenario: See related arch entities
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "Search Archaeological Entity Records"
    And I enter "" and submit the form
    Then I follow "Small 2"
    Then I follow "small Below AboveBelow: Small 3"
    Then I follow "Back"
    And I should see related arch entities
      | name                            |
      | small Below AboveBelow: Small 3 |
      | small Below AboveBelow: Small 4 |

  @javascript
  Scenario: Update arch entity attribute
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    And I update fields with values
      | field    | type      | values                 |
      | location | vocab     | Location A; Location C |
      | name     | freetext  | test3                  |
      | name     | certainty |                        |
      | value    | measure   | 10.0                   |
      | value    | certainty | 0.5                    |
    And I should see fields with values
      | field    | type      | values                 |
      | location | vocab     | Location A; Location C |
      | name     | freetext  | test3                  |
      | name     | certainty |                        |
      | value    | measure   | 10.0                   |
      | value    | certainty | 0.5                    |

  @javascript
  Scenario: Update arch entity attribute causes validation error
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    And I follow "Edit Project"
    And I pick file "validation_schema.xml" for "Validation Schema"
    And I press "Update"
    Then I should see "Successfully updated project"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    And I update fields with values
      | field | type     | values |
      | name  | freetext |        |
    And I should see fields with errors
      | field | error                |
      | name  | Field value is blank |
      | name  | Field value not text |

  @javascript
  Scenario: Cannot update arch entity attribute if database is locked
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    And I follow "List Archaeological Entity Records"
    And I press "Filter"
    And I follow "Small 2"
    And database is locked for "Sync Example"
    And I update fields with values
      | field    | type  | values                 |
      | location | vocab | Location A; Location C |
    And I wait for popup to close
    Then I should see dialog "Could not process request as database is currently locked"
    And I confirm

  Scenario: Update arch entity attribute with multiple values causes validation error
# TODO

  @javascript
  Scenario: Update rel attribute
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    And I follow "List Relationship Records"
    And I press "Filter"
    And I follow "AboveBelow 1"
    And I update fields with values
      | field    | type      | values                 |
      | location | vocab     | Location A; Location C |
      | name     | freetext  | rel2                   |
      | name     | certainty |                        |
    And I should see fields with values
      | field    | type      | values                 |
      | location | vocab     | Location A; Location C |
      | name     | freetext  | rel2                   |
      | name     | certainty |                        |

  @javascript
  Scenario: Update arch entity attribute causes validation error
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    And I follow "List Relationship Records"
    And I press "Filter"
    And I follow "AboveBelow 1"
    And I update fields with values
      | field | type     | values |
      | name  | freetext |        |
    And I should see fields with errors
      | field | error                |
      | name  | Field value is blank |
      | name  | Field value not text |

  @javascript
  Scenario: Cannot update arch entity attribute if database is locked
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    And I follow "List Relationship Records"
    And I press "Filter"
    And I follow "AboveBelow 1"
    And database is locked for "Sync Example"
    And I update fields with values
      | field    | type  | values                 |
      | location | vocab | Location A; Location C |
    And I wait for popup to close
    Then I should see dialog "Could not process request as database is currently locked"
    And I confirm

  Scenario: Update relationship attribute with multiple values causes validation error
# TODO

  Scenario: Show relationship association for arch ent
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "List Archaeological Entity Records"
    And I press "Filter"
    Then I follow "Small 2"
    And I follow "Show Relationship Association"
    And I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |

  @javascript
  Scenario: Remove relationship association from arch ent
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "List Archaeological Entity Records"
    And I press "Filter"
    Then I follow "Small 2"
    And I follow "Show Relationship Association"
    And I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
    Then I delete the first record
    And I confirm
    Then I should see "Removed Archaeological Entity from Relationship"
    Then I should see records
      | name         |
      | AboveBelow 2 |
    And I should not see records
      | name         |
      | AboveBelow 1 |

  @javascript
  Scenario: Cannot remove relationship association from arch ent if database is locked
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "List Archaeological Entity Records"
    And I press "Filter"
    Then I follow "Small 2"
    And I follow "Show Relationship Association"
    And database is locked for "Sync Example"
    And I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
    Then I delete the first record
    And I confirm
    And I wait for page
    Then I should see "Could not process request as database is currently locked"
    Then I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |

  @javascript
  Scenario: Add relationship association to arch ent
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "List Archaeological Entity Records"
    And I press "Filter"
    Then I follow "Small 2"
    And I follow "Show Relationship Association"
    And I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
    And I press "Add Member"
    And I click on "Search"
    And I select the first record
    And I press "Add Member"
    Then I should see "Added Archaeological Entity as member of Relationship"
    Then I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
      | AboveBelow 3 |

  @javascript
  Scenario: Cannot add relationship association to arch ent if database is locked
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "List Archaeological Entity Records"
    And I press "Filter"
    Then I follow "Small 2"
    And I follow "Show Relationship Association"
    And database is locked for "Sync Example"
    And I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
    And I press "Add Member"
    And I click on "Search"
    And I select the first record
    And I press "Add Member"
    Then I should see "Could not process request as database is currently locked"
    Then I should see records
      | name         |
      | AboveBelow 1 |
      | AboveBelow 2 |
    And I should not see records
      | name         |
      | AboveBelow 3 |

  Scenario: Show arch ent member for relationship
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "List Relationship Records"
    And I press "Filter"
    Then I follow "AboveBelow 1"
    And I follow "Show Relationship Member"
    And I should see records
      | name    |
      | Small 2 |
      | Small 4 |

  @javascript
  Scenario: Remove arch ent member from relationship
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "List Relationship Records"
    And I press "Filter"
    Then I follow "AboveBelow 1"
    And I follow "Show Relationship Member"
    And I should see records
      | name    |
      | Small 2 |
      | Small 4 |
    Then I delete the first record
    And I confirm
    Then I should see "Removed Archaeological Entity from Relationship"
    Then I should see records
      | name    |
      | Small 4 |
    And I should not see records
      | name    |
      | Small 2 |

  @javascript
  Scenario: Cannot remove arch ent member from relationship if database is locked
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "List Relationship Records"
    And I press "Filter"
    Then I follow "AboveBelow 1"
    And I follow "Show Relationship Member"
    And database is locked for "Sync Example"
    And I should see records
      | name    |
      | Small 2 |
      | Small 4 |
    Then I delete the first record
    And I confirm
    And I wait for page
    Then I should see "Could not process request as database is currently locked"
    Then I should see records
      | name    |
      | Small 2 |
      | Small 4 |

  @javascript
  Scenario: Add arch ent member to relationship
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "List Relationship Records"
    And I press "Filter"
    Then I follow "AboveBelow 1"
    And I follow "Show Relationship Member"
    And I should see records
      | name    |
      | Small 2 |
      | Small 4 |
    And I press "Add Member"
    And I click on "Search"
    And I select the first record
    And I press "Add Member"
    Then I should see "Added Archaeological Entity as member of Relationship"
    Then I should see records
      | name    |
      | Small 2 |
      | Small 3 |
      | Small 4 |

  @javascript
  Scenario: Cannot add arch ent member to relationship
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
    And I follow "Sync Example"
    Then I follow "List Relationship Records"
    And I press "Filter"
    Then I follow "AboveBelow 1"
    And I follow "Show Relationship Member"
    And database is locked for "Sync Example"
    And I should see records
      | name    |
      | Small 2 |
      | Small 4 |
    And I press "Add Member"
    And I click on "Search"
    And I select the first record
    And I press "Add Member"
    Then I should see "Could not process request as database is currently locked"
    Then I should see records
      | name    |
      | Small 2 |
      | Small 4 |
    And I should not see records
      | name    |
      | Small 3 |

  @javascript
  Scenario: Merge arch ents (first)
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
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
      | field  | type     | values  |
      | entity | freetext | Small 2 |
      | name   | freetext | test3   |

  @javascript
  Scenario: Merge arch ents (second)
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
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
    And I should see fields with values
      | field  | type     | values  |
      | entity | freetext | Small 3 |
      | name   | freetext | test2   |

  @javascript
  Scenario: Can only compare 2 arch ents
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
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
  Scenario: Cannot compare arch ents if database is locked
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
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
    Then I should see dialog "Could not process request as database is currently locked"
    And I confirm

  Scenario: Cannot compare arch ents of different types
# TODO

  @javascript
  Scenario: Merge rels (first)
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
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
  Scenario: Merge rels (second)
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
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
  Scenario: Can only compare 2 rels
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
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
  Scenario: Cannot merge rels if database is locked
    Given I am on the home page
    And I follow "Show Projects"
    Then I should be on the projects page
    And I follow "Upload Project"
    And I pick file "Sync_Example.tar.bz2" for "Project File"
    And I press "Upload"
    Then I should see "Project has been successfully uploaded"
    And I should be on the projects page
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

  Scenario: Cannot compare rels of different types
# TODO

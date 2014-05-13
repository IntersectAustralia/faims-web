Feature: Android
  In order provide android interactions
  As a user
  I want to have an api for android to access

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I have a project modules dir
    And I perform HTTP authentication

  Scenario: Pull a list of project modules
    Given I have project modules
      | name     |
      | Module 1 |
      | Module 2 |
      | Module 3 |
    And I requested the android project modules page
    Then I should see json for project modules

  Scenario: See info for project module settings
    Given I have project module "Module 1"
    And I requested the android settings info for Module 1
    Then I should see json for "Module 1" settings

  Scenario: See info for project module settings after syncing
    Given I have project module "Module 1"
    And I have synced 20 times for "Module 1"
    And I requested the android settings info for Module 1
    Then I should see json for "Module 1" settings with version 20

  Scenario: Cannot see settings info if project module doesn't exist
    Given I have project module "Module 1"
    And I requested the android settings info for Module 2
    Then I should see bad request page

  Scenario Outline: Can download project module settings
    Given I have project module "Module 1"
    And I requested the android settings download "<file>" link for Module 1
    Then I should download settings "<file>" for "Module 1"
  Examples:
    | file             |
    | ui_schema.xml    |
    | ui_logic.bsh     |
    | faims.properties |
    | module.settings  |

  Scenario Outline: Cannot download project module settings if settings is locked
    Given I have project module "Module 1"
    And settings is locked for "Module 1"
    And I requested the android settings download "<file>" link for Module 1
    Then I should see timeout request page
  Examples:
    | file          |
    | ui_schema.xml |

  Scenario Outline: Cannot download project module settings if file doesn't exist
    Given I have project module "Module 1"
    And I requested the android settings download "<file>" link for Module 2
    Then I should see bad request page
  Examples:
    | file         |
    | blahblahblah |

  Scenario Outline: Cannot download project module settings if module doesn't exist
    Given I have project module "Module 1"
    And I requested the android settings download "<file>" link for Module 2
    Then I should see bad request page
  Examples:
    | file          |
    | ui_schema.xml |

  Scenario: Can upload project module database
    Given I have project module "Module 1"
    And I upload database "db" to Module 1 succeeds
    Then I should have stored "db" into Module 1

  Scenario: Can upload sync database
    Given I have project module "Module 1"
    And I upload sync database "db" to Module 1 succeeds
    Then I should have stored "db" into Module 1

  Scenario: Cannot upload project module database because of corruption
    Given I have project module "Module 1"
    And I upload corrupted database "db" to Module 1 fails

  Scenario: Cannot upload project module if project module doesn't exist
    Given I have project module "Module 1"
    And I upload database "db" to Module 2 fails

  Scenario: See info for database
    Given I have project module "Module 1"
    And I requested the android db info for Module 1
    Then I should see json for "Module 1" db

  Scenario: See info for database after syncing
    Given I have project module "Module 1"
    And I have synced 20 times for "Module 1"
    And I have generate database cache version 0 for "Module 1"
    And I requested the android db info for Module 1
    Then I should see json for "Module 1" db with version 20

  Scenario: Cannot see info for database if generating cache
    Given I have project module "Module 1"
    And I have synced 20 times for "Module 1"
    And I requested the android db info for Module 1
    Then I should see processing request page

  Scenario: Cannot see info for database if project module doesn't exist
    Given I have project module "Module 1"
    And I requested the android db info for Module 2
    Then I should see bad request page

  Scenario: Can download project module database
    Given I have project module "Module 1"
    And I requested the android download db link for Module 1
    Then I should download db file for "Module 1"

  Scenario: Cannot download project module database if project module doesn't exist
    Given I have project module "Module 1"
    And I requested the android download db link for Module 2
    Then I should see bad request page

  Scenario Outline: See info for database with version
    Given I have project module "Module 1"
    And I have synced 20 times for "Module 1"
    And I have generate database cache version <version> for "Module 1"
    And I requested the android db info for Module 1 with request version <version>
    Then I should see json for "Module 1" db from version <version> to version 20
  Examples:
    | version |
    | 0       |
    | 10      |
    | 20      |

  Scenario Outline: Cannot see info for database with invalid version
    Given I have project module "Module 1"
    And I have synced 20 times for "Module 1"
    And I requested the android db info for Module 1 with request version <version>
    Then I should see bad request page
  Examples:
    | version |
    | -1      |
    | 21      |
    | 100     |

  Scenario Outline: Cannot see info for database if module does not exist
    Given I have project module "Module 1"
    And I have synced 20 times for "Module 1"
    And I requested the android db info for Module 2 with request version <version>
    Then I should see bad request page
  Examples:
    | version |
    | 0       |

  Scenario Outline: Can download database with version
    Given I have project module "Module 1"
    And I have synced 20 times for "Module 1"
    And I have generate database cache version <version> for "Module 1"
    And I requested the android download db link for Module 1 with request version <version>
    Then I should download db file for "Module 1" from version <version>
  Examples:
    | version |
    | 0       |
    | 10      |
    | 20      |

  Scenario Outline: Cannot download database with invalid version
    Given I have project module "Module 1"
    And I have synced 20 times for "Module 1"
    And I have generate database cache version <version> for "Module 1"
    And I requested the android download db link for Module 1 with request version <version>
    Then I should see bad request page
  Examples:
    | version |
    | -1      |
    | 21      |
    | 100     |

  Scenario Outline: Cannot download database with version if module does not exist
    Given I have project module "Module 1"
    And I have synced 20 times for "Module 1"
    And I have generate database cache version <version> for "Module 1"
    And I requested the android download db link for Module2 with request version <version>
    Then I should see bad request page
  Examples:
    | version |
    | 0       |

  Scenario Outline: Upload server files
    Given I have project module "Module 1"
    And I upload server file "<file>" to Module 1 succeeds
    Then I should have stored server file "<file>" for Module 1
  Examples:
    | file                        |
    | file1.tar.gz                |
    | file2.sqlite3               |
    | file3.txt                   |
    | dir1/dir2/dir3/file4.tar.gz |

  Scenario Outline: Cannot upload server files is module does not exist
    Given I have project module "Module 1"
    And I upload server file "<file>" to Module 2 fails
  Examples:
    | file                        |
    | file1.tar.gz                |

  Scenario: See app files info for project module
    Given I have project module "Module 1"
    And I have app files for "Module 1"
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |
    And I requested the android app files info for Module 1
    Then I should see json for "Module 1" app files with
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |

  Scenario: Cannot see app files archive info if project module doesn't exist
    Given I have project module "Module 1"
    And I requested the android app files info for Module 2
    Then I should see bad request page

  Scenario: Download app files
    Given I have project module "Module 1"
    And I have app files for "Module 1"
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |
    Then I archive and download app files for "Module 1"

  Scenario: Cannot download app files no new files to download
    Given I have project module "Module 1"
    And I requested the android app files download link for Module 1
    Then I should see bad request page

  Scenario: Cannot download app files if project module doesn't exist
    Given I have project module "Module 1"
    And I requested the android app files download link for Module 2
    Then I should see bad request page

  Scenario: Upload app files
    Given I have project module "Module 1"
    And I upload app files "test_files.tar.gz" to Module 1 succeeds
    Then I should have stored app files "test_files.tar.gz" for Module 1

  Scenario: Cannot upload app files if project module doesn't exist
    Given I have project module "Module 1"
    And I upload app files "test_files.tar.gz" to Module 2 fails

  Scenario: See data files archive info for project module
    Given I have project module "Module 1"
    And I have data files for "Module 1"
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |
    And I requested the android data files archive info for Module 1
    Then I should see json for "Module 1" data files archive

  Scenario: Cannot see data files archive info if project module doesn't exist
    Given I have project module "Module 1"
    And I requested the android data files archive info for Module 2
    Then I should see bad request page

  Scenario: Download data files
    Given I have project module "Module 1"
    And I have data files for "Module 1"
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |
    Then I archive and download data files for "Module 1"

  Scenario: Cannot download data files no new files to download
    Given I have project module "Module 1"
    And I requested the android data files download link for Module 1
    Then I should see bad request page

  Scenario: Cannot download data files if project module doesn't exist
    Given I have project module "Module 1"
    And I requested the android data files download link for Module 2
    Then I should see bad request page

  Scenario: Upload data files
    Given I have project module "Module 1"
    And I upload data files "test_files.tar.gz" to Module 1 succeeds
    Then I should have stored data files "test_files.tar.gz" for Module 1

  Scenario: Cannot upload data files if project module doesn't exist
    Given I have project module "Module 1"
    And I upload app files "test_files.tar.gz" to Module 2 fails

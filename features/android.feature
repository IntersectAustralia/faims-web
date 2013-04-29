Feature: Android
  In order provide android interactions
  As a user
  I want to have an api for android to access

  Background:
    And I have role "superuser"
    And I have a user "georgina@intersect.org.au" with role "superuser"
    And I am on the login page
    And I am logged in as "georgina@intersect.org.au"
    And I should see "Logged in successfully."
    And I have a projects dir

  Scenario: See archive info for project settings
  Given I have project "Project 1"
  And I requested the android archive settings info for Project 1
  Then I should see json for "Project 1" settings

  Scenario: See archive info for project settings after syncing
  Given I have project "Project 1"
  And I have synced 20 times for "Project 1"
  And I requested the android archive settings info for Project 1
  Then I should see json for "Project 1" settings with version 20

  Scenario: Cannot see archive info if project doesn't exist
  Given I have project "Project 1"
  And I requested the android archive info for Project 2
  Then I should see bad request page

  Scenario: Can download project
  Given I have project "Project 1"
  And I am on the android download link for Project 1
  Then I should download file for "Project 1"

  Scenario: Cannot download project if project doesn't exist
  Given I have project "Project 1"
  And I am on the android download link for Project 2
  Then I should see bad request page

  Scenario: Can upload project database
  Given I have project "Project 1"
  And I upload database "db" to Project 1 succeeds
  Then I should have stored "db" into Project 1

  Scenario: Cannot upload project database because of corruption
  Given I have project "Project 1"
  And I upload corrupted database "db" to Project 1 fails

  Scenario: Cannot upload project if project doesn't exist
    Given I have project "Project 1"
    And I upload database "db" to Project 2 fails

  Scenario: See archive info for database
  Given I have project "Project 1"
  And I requested the android archive db info for Project 1
  Then I should see json for "Project 1" db

  Scenario: See archive info for database after syncing
  Given I have project "Project 1"
  And I have synced 20 times for "Project 1"
  And I requested the android archive db info for Project 1
  Then I should see json for "Project 1" db with 20

  Scenario: Cannot see archive info for database if project doesn't exist
  Given I have project "Project 1"
  And I requested the android archive db info for Project 2
  Then I should see bad request page

  Scenario: Can download project database
  Given I have project "Project 1"
  And I am on the android download db link for Project 1
  Then I should download db file for "Project 1"

  Scenario: Cannot download project database if project doesn't exist
  Given I have project "Project 1"
  And I am on the android download db link for Project 2
  Then I should see bad request page

  Scenario Outline: See archive info for database with version
  Given I have project "Project 1"
  And I have synced 20 times for "Project 1"
  And I requested the android archive db info for Project 1 with version <version>
  Then I should see json for "Project 1" version <version> db with version 20
  Examples:
  | version |
  | 1       |
  | 10      |
  | 20      |

  Scenario Outline: Cannot see archive info for database with invalid version
  Given I have project "Project 1"
  And I have synced 20 times for "Project 1"
  And I requested the android archive db info for Project 1 with version <version>
  # this returns the full database
  Then I should see json for "Project 1" db with version 20
  Examples:
  | version |
  | 0       |
  | -1      |
  | 21      |

  Scenario Outline: Can download database with version
    Given I have project "Project 1"
    And I have synced 20 times for "Project 1"
    And I am on the android download db link for Project 1 with request version <version>
    Then I should download db file for "Project 1" from version <version>
  Examples:
    | version |
    | 1       |
    | 10      |
    | 20      |

  Scenario: Can upload sync database
    Given I have project "Project 1"
    And I upload sync database "db" to Project 1 succeeds
    Then I should have stored sync "db" into Project 1

  Scenario: Cannot see archive info for database with version if project doesn't exist
  Given I have project "Project 1"
  And I have synced 20 times for "Project 1"
  And I requested the android archive db info for Project 2 with request version 10
  Then I should see bad request page

  Scenario: Show empty server file list
  Given I have project "Project 1"
  And I am on the android server file list page for Project 1
  Then I should see empty file list

  Scenario: Cannot see server file list if project doesn't exist
  Given I have project "Project 1"
  And I am on the android server file list page for Project 2
  Then I should see bad request page

  Scenario: Show full server file list
  Given I have project "Project 1"
  And I have server only files for "Project 1"
  | file                        |
  | file1.tar.gz                |
  | file2.sqlite3               |
  | file3.txt                   |
  | dir1/dir2/dir3/file4.tar.gz |
  And I am on the android server file list page for Project 1
  Then I should see files
  | file                        |
  | file1.tar.gz                |
  | file2.sqlite3               |
  | file3.txt                   |
  | dir1/dir2/dir3/file4.tar.gz |

  Scenario: Show empty app file list
  Given I have project "Project 1"
  And I am on the android app file list page for Project 1
  Then I should see empty file list

  Scenario: Cannot see app file list if project doesn't exist
  Given I have project "Project 1"
  And I am on the android app file list page for Project 2
  Then I should see bad request page

  Scenario: Show full app file list
  Given I have project "Project 1"
  And I have app files for "Project 1"
  | file                        |
  | file1.tar.gz                |
  | file2.sqlite3               |
  | file3.txt                   |
  | dir1/dir2/dir3/file4.tar.gz |
  And I am on the android app file list page for Project 1
  Then I should see files
  | file                        |
  | file1.tar.gz                |
  | file2.sqlite3               |
  | file3.txt                   |
  | dir1/dir2/dir3/file4.tar.gz |

  Scenario: See server files archive info for project
  Given I have project "Project 1"
  And I have server only files for "Project 1"
  | file                        |
  | file1.tar.gz                |
  | file2.sqlite3               |
  | file3.txt                   |
  | dir1/dir2/dir3/file4.tar.gz |
  And I am on the android server files archive page for Project 1
  Then I should see json for "Project 1" server files archive

  Scenario: See new server files archive info for project
  Given I have project "Project 1"
  And I have server only files for "Project 1"
  | file                        |
  | file1.tar.gz                |
  | file2.sqlite3               |
  | file3.txt                   |
  | dir1/dir2/dir3/file4.tar.gz |
  And I am request the android server files archive page for Project 1 with files
  | file                        |
  | file1.tar.gz                |
  | file2.sqlite3               |
  Then I should see json for "Project 1" server files archive given I already have files
  | file                        |
  | file1.tar.gz                |
  | file2.sqlite3               |

  Scenario: Cannot see server files archive info if project doesn't exist
  Given I have project "Project 1"
  And I am on the android server files archive page for Project 2
  Then I should see bad request page

  Scenario: See app files archive info for project
  Given I have project "Project 1"
  And I have app files for "Project 1"
  | file                        |
  | file1.tar.gz                |
  | file2.sqlite3               |
  | file3.txt                   |
  | dir1/dir2/dir3/file4.tar.gz |
  And I am on the android app files archive page for Project 1
  Then I should see json for "Project 1" app files archive

  Scenario: See new app files archive info for project
  Given I have project "Project 1"
  And I have app files for "Project 1"
  | file                        |
  | file1.tar.gz                |
  | file2.sqlite3               |
  | file3.txt                   |
  | dir1/dir2/dir3/file4.tar.gz |
  And I am request the android app files archive page for Project 1 with files
  | file                        |
  | file1.tar.gz                |
  | file2.sqlite3               |
  Then I should see json for "Project 1" app files archive given I already have files
  | file                        |
  | file1.tar.gz                |
  | file2.sqlite3               |

  Scenario: Cannot see app files archive info if project doesn't exist
  Given I have project "Project 1"
  And I am on the android app files archive page for Project 2
  Then I should see bad request page

  Scenario: Download server files
    Given I have project "Project 1"
    And I have server only files for "Project 1"
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |
    Then I archive and download server files for "Project 1"

  Scenario: Download new server files
    Given I have project "Project 1"
    And I have server only files for "Project 1"
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |
    Then I archive and download server files for "Project 1" given I already have files
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |

  Scenario: Cannot download server files no new files to download
    Given I have project "Project 1"
    And I am on the android server files download link for Project 1
    Then I should see bad request page

  Scenario: Cannot download server files if project doesn't exist
    Given I have project "Project 1"
    And I am on the android server files download link for Project 2
    Then I should see bad request page

  Scenario: Download app files
    Given I have project "Project 1"
    And I have app files for "Project 1"
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |
    Then I archive and download app files for "Project 1"

  Scenario: Download new app files
    Given I have project "Project 1"
    And I have app files for "Project 1"
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |
    Then I archive and download app files for "Project 1" given I already have files
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |

  Scenario: Cannot download app files no new files to download
    Given I have project "Project 1"
    And I am on the android app files download link for Project 1
    Then I should see bad request page

  Scenario: Cannot download app files if project doesn't exist
    Given I have project "Project 1"
    And I am on the android app files download link for Project 2
    Then I should see bad request page

  Scenario: Upload server files
    Given I have project "Project 1"
    And I upload server files "test_files.tar.gz" to Project 1 succeeds
    Then I should have stored server files "test_files.tar.gz" for Project 1

  Scenario: Upload app files
    Given I have project "Project 1"
    And I upload app files "test_files.tar.gz" to Project 1 succeeds
    Then I should have stored app files "test_files.tar.gz" for Project 1

  Scenario: Cannot upload server files if project doesn't exist
    Given I have project "Project 1"
    And I upload server files "test_files.tar.gz" to Project 2 fails

  Scenario: Cannot upload app files if project doesn't exist
    Given I have project "Project 1"
    And I upload app files "test_files.tar.gz" to Project 2 fails

Feature: Android
  In order provide android interactions
  As a user
  I want to have an api for android to access

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I requested the login page
    And I am logged in as "faimsadmin@intersect.org.au"
    And I should see "Logged in successfully."
    And I have a projects dir
    And I perform HTTP authentication

  Scenario: See archive info for project settings
    Given I have project "Project 1"
    And I requested the android archive settings info for Project 1
    Then I should see json for "Project 1" settings

  Scenario: See archive info for project settings after syncing
    Given I have project "Project 1"
    And I have synced 20 times for "Project 1"
    And I requested the android archive settings info for Project 1
    Then I should see json for "Project 1" settings with version 20

  Scenario: Cannot see archive settings info if project doesn't exist
    Given I have project "Project 1"
    And I requested the android archive settings info for Project 2
    Then I should see bad request page

  Scenario: Can download project settings
    Given I have project "Project 1"
    And I requested the android settings download link for Project 1
    Then I should download settings for "Project 1"

  Scenario: Cannot download project settings if project doesn't exist
    Given I have project "Project 1"
    And I requested the android settings download link for Project 2
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
    And I requested the android download db link for Project 1
    Then I should download db file for "Project 1"

  Scenario: Cannot download project database if project doesn't exist
    Given I have project "Project 1"
    And I requested the android download db link for Project 2
    Then I should see bad request page

  Scenario Outline: See archive info for database with version
    Given I have project "Project 1"
    And I have synced 20 times for "Project 1"
    And I requested the android archive db info for Project 1 with request version <version>
    Then I should see json for "Project 1" version <version> db with version 20
  Examples:
    | version |
    | 1       |
    | 10      |
    | 20      |

  Scenario Outline: Cannot see archive info for database with invalid version
    Given I have project "Project 1"
    And I have synced 20 times for "Project 1"
    And I requested the android archive db info for Project 1 with request version <version>
  # this returns the full database
    Then I should see json for "Project 1" database with version 20
  Examples:
    | version |
    | 0       |
    | -1      |
    | 21      |

  Scenario Outline: Can download database with version
    Given I have project "Project 1"
    And I have synced 20 times for "Project 1"
    And I requested the android download db link for Project 1 with request version <version>
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
    And I requested the android server file list for Project 1
    Then I should see empty file list

  Scenario: Cannot see server file list if project doesn't exist
    Given I have project "Project 1"
    And I requested the android server file list for Project 2
    Then I should see bad request page

  Scenario: Show full server file list
    Given I have project "Project 1"
    And I have server only files for "Project 1"
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |
    And I requested the android server file list for Project 1
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
    And I requested the android server files archive info for Project 1
    Then I should see json for "Project 1" server files archive

  Scenario: See new server files archive info for project
    Given I have project "Project 1"
    And I have server only files for "Project 1"
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |
    And I request for the android server files archive info for Project 1 with files
      | file          |
      | file1.tar.gz  |
      | file2.sqlite3 |
    Then I should see json for "Project 1" server files archive given I already have files
      | file          |
      | file1.tar.gz  |
      | file2.sqlite3 |

  Scenario: Cannot see server files archive info if project doesn't exist
    Given I have project "Project 1"
    And I requested the android server files archive info for Project 2
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
      | file          |
      | file1.tar.gz  |
      | file2.sqlite3 |

  Scenario: Cannot download server files no new files to download
    Given I have project "Project 1"
    And I requested the android server files download link for Project 1
    Then I should see bad request page

  Scenario: Cannot download server files if project doesn't exist
    Given I have project "Project 1"
    And I requested the android server files download link for Project 2
    Then I should see bad request page

  Scenario: Upload server files
    Given I have project "Project 1"
    And I upload server files "test_files.tar.gz" to Project 1 succeeds
    Then I should have stored server files "test_files.tar.gz" for Project 1

  Scenario: Cannot upload server files if project doesn't exist
    Given I have project "Project 1"
    And I upload server files "test_files.tar.gz" to Project 2 fails

  Scenario: Show empty app file list
    Given I have project "Project 1"
    And I requested the android app file list for Project 1
    Then I should see empty file list

  Scenario: Cannot see app file list if project doesn't exist
    Given I have project "Project 1"
    And I requested the android app file list for Project 2
    Then I should see bad request page

  Scenario: Show full app file list
    Given I have project "Project 1"
    And I have app files for "Project 1"
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |
    And I requested the android app file list for Project 1
    Then I should see files
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |

  Scenario: See app files archive info for project
    Given I have project "Project 1"
    And I have app files for "Project 1"
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |
    And I requested the android app files archive info for Project 1
    Then I should see json for "Project 1" app files archive

  Scenario: See new app files archive info for project
    Given I have project "Project 1"
    And I have app files for "Project 1"
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |
    And I request for the android app files archive info for Project 1 with files
      | file          |
      | file1.tar.gz  |
      | file2.sqlite3 |
    Then I should see json for "Project 1" app files archive given I already have files
      | file          |
      | file1.tar.gz  |
      | file2.sqlite3 |

  Scenario: Cannot see app files archive info if project doesn't exist
    Given I have project "Project 1"
    And I requested the android app files archive info for Project 2
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
      | file          |
      | file1.tar.gz  |
      | file2.sqlite3 |

  Scenario: Cannot download app files no new files to download
    Given I have project "Project 1"
    And I requested the android app files download link for Project 1
    Then I should see bad request page

  Scenario: Cannot download app files if project doesn't exist
    Given I have project "Project 1"
    And I requested the android app files download link for Project 2
    Then I should see bad request page

  Scenario: Upload app files
    Given I have project "Project 1"
    And I upload app files "test_files.tar.gz" to Project 1 succeeds
    Then I should have stored app files "test_files.tar.gz" for Project 1

  Scenario: Cannot upload app files if project doesn't exist
    Given I have project "Project 1"
    And I upload app files "test_files.tar.gz" to Project 2 fails

  Scenario: Show empty data file list
    Given I have project "Project 1"
    And I requested the android data file list for Project 1
    Then I should see empty file list

  Scenario: Cannot see data file list if project doesn't exist
    Given I have project "Project 1"
    And I requested the android data file list for Project 2
    Then I should see bad request page

  Scenario: Show full data file list
    Given I have project "Project 1"
    And I have data files for "Project 1"
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |
    And I requested the android data file list for Project 1
    Then I should see files
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |

  Scenario: See data files archive info for project
    Given I have project "Project 1"
    And I have data files for "Project 1"
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |
    And I requested the android data files archive info for Project 1
    Then I should see json for "Project 1" data files archive

  Scenario: See new data files archive info for project
    Given I have project "Project 1"
    And I have data files for "Project 1"
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |
    And I request for the android data files archive info for Project 1 with files
      | file          |
      | file1.tar.gz  |
      | file2.sqlite3 |
    Then I should see json for "Project 1" data files archive given I already have files
      | file          |
      | file1.tar.gz  |
      | file2.sqlite3 |

  Scenario: Cannot see data files archive info if project doesn't exist
    Given I have project "Project 1"
    And I requested the android data files archive info for Project 2
    Then I should see bad request page

  Scenario: Download data files
    Given I have project "Project 1"
    And I have data files for "Project 1"
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |
    Then I archive and download data files for "Project 1"

  Scenario: Download new data files
    Given I have project "Project 1"
    And I have data files for "Project 1"
      | file                        |
      | file1.tar.gz                |
      | file2.sqlite3               |
      | file3.txt                   |
      | dir1/dir2/dir3/file4.tar.gz |
    Then I archive and download data files for "Project 1" given I already have files
      | file          |
      | file1.tar.gz  |
      | file2.sqlite3 |

  Scenario: Cannot download data files no new files to download
    Given I have project "Project 1"
    And I requested the android data files download link for Project 1
    Then I should see bad request page

  Scenario: Cannot download data files if project doesn't exist
    Given I have project "Project 1"
    And I requested the android data files download link for Project 2
    Then I should see bad request page

  Scenario: Upload data files
    Given I have project "Project 1"
    And I upload data files "test_files.tar.gz" to Project 1 succeeds
    Then I should have stored data files "test_files.tar.gz" for Project 1

  Scenario: Cannot upload data files if project doesn't exist
    Given I have project "Project 1"
    And I upload app files "test_files.tar.gz" to Project 2 fails

  Scenario: Pull a list of projects
    Given I have projects
      | name      |
      | Project 1 |
      | Project 2 |
      | Project 3 |
    And I requested the android projects page
    Then I should see json for projects

Feature: Project file manager
  In order manage project files
  As a user
  I want to upload, list and delete project files

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am on the login page
    And I am logged in as "faimsadmin@intersect.org.au"
    And I should see "Logged in successfully."
    And I have a projects dir

  @javascript
  Scenario: Add project files
    Given I have project "Project 1"
    And I am on upload data files page for Project 1
    And I upload project files
      | dir  | file          |
      | data | file1.tar.gz  |
      | data | file2.sqlite3 |
      | data | file3.txt     |
    Then I should see project files
      | dir  | file          |
      | data | file1.tar.gz  |
      | data | file2.sqlite3 |
      | data | file3.txt     |

  @javascript
  Scenario: Add project directories
    Given I have project "Project 1"
    And I am on upload data files page for Project 1
    And I create project directories
      | dir   | child_dir |
      | data  | test1     |
      | test1 | test2     |
      | test2 | test3     |
      | data  | test4     |
    Then I should see project directories
      | dir   | child_dir |
      | data  | test1     |
      | test1 | test2     |
      | test2 | test3     |
      | data  | test4     |

  @javascript
  Scenario: Add project files within directories
    Given I have project "Project 1"
    And I am on upload data files page for Project 1
    And I create project directories
      | dir   | child_dir |
      | data  | test1     |
      | test1 | test2     |
    Then I should see project directories
      | dir   | child_dir |
      | data  | test1     |
      | test1 | test2     |
    And I upload project files
      | dir   | file          |
      | data  | file1.tar.gz  |
      | test1 | file2.sqlite3 |
      | test2 | file3.txt     |
    Then I should see project files
      | dir   | file          |
      | data  | file1.tar.gz  |
      | test1 | file2.sqlite3 |
      | test2 | file3.txt     |

  @javascript
  Scenario: Delete project files
    Given I have project "Project 1"
    And I am on upload data files page for Project 1
    And I upload project files
      | dir  | file          |
      | data | file1.tar.gz  |
      | data | file2.sqlite3 |
      | data | file3.txt     |
    And I delete project files
      | dir  | file          |
      | data | file1.tar.gz  |
      | data | file2.sqlite3 |
    Then I should see project files
      | dir  | file      |
      | data | file3.txt |
    And I should not see project files
      | dir  | file          |
      | data | file1.tar.gz  |
      | data | file2.sqlite3 |
    And I should see "Deleted file"

  @javascript
  Scenario: Delete project directories
    Given I have project "Project 1"
    And I am on upload data files page for Project 1
    And I create project directories
      | dir   | child_dir |
      | data  | test1     |
      | test1 | test2     |
      | data  | test4     |
      | data  | test5     |
      | test5 | test6     |
      | test6 | test7     |
    And I delete project directories
      | dir   | child_dir |
      | data  | test1     |
      | data  | test4     |
      | test5 | test6     |
    Then I should see project directories
      | dir   | child_dir |
      | data  | test5     |
    Then I should not see project directories
      | dir   | child_dir |
      | data  | test1     |
      | data  | test4     |
      | test5 | test6     |
    And I should see "Deleted directory"

  @javascript
  Scenario: Delete root directory
    Given I have project "Project 1"
    And I am on upload data files page for Project 1
    And I create project directories
      | dir   | child_dir |
      | data  | test1     |
      | test1 | test2     |
      | data  | test4     |
      | data  | test5     |
      | test5 | test6     |
      | test6 | test7     |
    And I delete root directory
    Then I should not see project directories
      | dir   | child_dir |
      | data  | test1     |
      | data  | test4     |
      | data  | test5     |
    And I should see "Deleted directory"

  @javascript
  Scenario: Can delete dir if files in directory
    Given I have project "Project 1"
    And I am on upload data files page for Project 1
    And I create project directories
      | dir  | child_dir |
      | data | test1     |
    And I upload project files
      | dir   | file          |
      | test1 | file2.sqlite3 |
    And I delete project directories
      | dir  | child_dir |
      | data | test1     |
    Then I should not see project files
      | dir   | file          |
      | test1 | file2.sqlite3 |
    Then I should not see project directories
      | dir   | child_dir |
      | data  | test1     |
    And I should see "Deleted directory"

  @javascript
  Scenario: Cannot add project file if file already exists
    Given I have project "Project 1"
    And I am on upload data files page for Project 1
    And I upload project files
      | dir  | file         |
      | data | file1.tar.gz |
      | data | file1.tar.gz |
    Then I should see project files
      | dir  | file         |
      | data | file1.tar.gz |
    And I should see "File already exists"

  @javascript
  Scenario: Cannot add project file if files locked
    Given I have project "Project 1"
    And I am on upload data files page for Project 1
    And files are locked for "Project 1"
    And I upload project files
      | dir  | file         |
      | data | file1.tar.gz |
    Then I should not see project files
      | dir  | file         |
      | data | file1.tar.gz |
    And I should see "Could not upload file. Files are currently locked"

  @javascript
  Scenario: Cannot add directory if directory already exists
    Given I have project "Project 1"
    And I am on upload data files page for Project 1
    And I create project directories
      | dir  | child_dir |
      | data | test1     |
      | data | test1     |
    Then I should see project directories
      | dir  | child_dir |
      | data | test1     |
    And I should see "Directory already exists"

  @javascript
  Scenario: Cannot add directory if directory if files are locked
    Given I have project "Project 1"
    And I am on upload data files page for Project 1
    And files are locked for "Project 1"
    And I create project directories
      | dir  | child_dir |
      | data | test1     |
    Then I should not see project directories
      | dir  | child_dir |
      | data | test1     |
    And I should see "Could not create directory. Files are currently locked"

  @javascript
  Scenario: Cannot delete file if files are locked
    Given I have project "Project 1"
    And I am on upload data files page for Project 1
    And I upload project files
      | dir  | file          |
      | data | file1.tar.gz  |
    And files are locked for "Project 1"
    And I delete project files
      | dir  | file          |
      | data | file1.tar.gz  |
    Then I should see project files
      | dir  | file          |
      | data | file1.tar.gz  |
    And I should see "Could not delete file. Files are currently locked"

  @javascript
  Scenario: Cannot delete directory if files are locked
    Given I have project "Project 1"
    And I am on upload data files page for Project 1
    And I create project directories
      | dir   | child_dir |
      | data  | test1     |
    And files are locked for "Project 1"
    And I delete project directories
      | dir   | child_dir |
      | data  | test1     |
    Then I should see project directories
      | dir   | child_dir |
      | data  | test1     |
    And I should see "Could not delete directory. Files are currently locked"

  Scenario: I upload batch file
    Given I have project "Project 1"
    And I am on upload data files page for Project 1
    And I pick file "batch.tar.gz" for "project_file"
    And I press "Upload"
    And I should see project files
      | dir   | file  |
      | test1 | test3 |
      | data  | test2 |

  Scenario: Cannot upload batch file if archive is invalid
    Given I have project "Project 1"
    And I am on upload data files page for Project 1
    And I pick file "file3.txt" for "project_file"
    And I press "Upload"
    And I should see "Could not upload file. Please ensure file is a valid archive."
    Then I should not see project files
      | dir   | file  |
      | test1 | test3 |
      | data  | test2 |

  Scenario: Cannot upload batch file if files are locked
    Given I have project "Project 1"
    And I am on upload data files page for Project 1
    And files are locked for "Project 1"
    And I pick file "batch.tar.gz" for "project_file"
    And I press "Upload"
    And I should see "Could not upload archive. Files are currently locked"
    Then I should not see project files
      | dir   | file  |
      | test1 | test3 |
      | data  | test2 |




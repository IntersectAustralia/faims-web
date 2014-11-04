Feature: Project module file manager
  In order manage project module files
  As a user
  I want to upload, list and delete project module files

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am on the login page
    And I am logged in as "faimsadmin@intersect.org.au"
    And I should see "Logged in successfully."
    And I have a project modules dir

  @javascript
  Scenario: Add project module files
    Given I have project module "Module 1"
    And I am on upload data files page for Module 1
    And I upload project module files
      | dir  | file          |
      | data | file1.tar.gz  |
      | data | file2.sqlite3 |
      | data | file3.txt     |
    Then I should see project module files for "Module 1"
      | dir  | file          | full_dir   |
      | data | file1.tar.gz  | files/data |
      | data | file2.sqlite3 | files/data |
      | data | file3.txt     | files/data |

  @javascript
  Scenario: Add project module directories
    Given I have project module "Module 1"
    And I am on upload data files page for Module 1
    And I create project module directories
      | dir   | child_dir |
      | data  | test1     |
      | test1 | test2     |
      | test2 | test3     |
      | data  | test4     |
    Then I should see project module directories
      | dir   | child_dir |
      | data  | test1     |
      | test1 | test2     |
      | test2 | test3     |
      | data  | test4     |

  @javascript
  Scenario: Add project module files within directories
    Given I have project module "Module 1"
    And I am on upload data files page for Module 1
    And I create project module directories
      | dir   | child_dir |
      | data  | test1     |
      | test1 | test2     |
    Then I should see project module directories
      | dir   | child_dir |
      | data  | test1     |
      | test1 | test2     |
    And I upload project module files
      | dir   | file          |
      | data  | file1.tar.gz  |
      | test1 | file2.sqlite3 |
      | test2 | file3.txt     |
    Then I should see project module files for "Module 1"
      | dir   | file          | full_dir               |
      | data  | file1.tar.gz  | files/data             |
      | test1 | file2.sqlite3 | files/data/test1       |
      | test2 | file3.txt     | files/data/test1/test2 |

  @javascript
  Scenario: Delete project module files
    Given I have project module "Module 1"
    And I am on upload data files page for Module 1
    And I upload project module files
      | dir  | file          |
      | data | file1.tar.gz  |
      | data | file2.sqlite3 |
      | data | file3.txt     |
    And I have package archive for "Module 1"
    And I should have package archive for "Module 1"
    And I delete project module files
      | dir  | file          |
      | data | file1.tar.gz  |
      | data | file2.sqlite3 |
    And I wait 2 seconds
    Then I should see project module files for "Module 1"
      | dir  | file      | full_dir   |
      | data | file3.txt | files/data |
    And I should not see project module files for "Module 1"
      | dir  | file          | full_dir   |
      | data | file1.tar.gz  | files/data |
      | data | file2.sqlite3 | files/data |
    And I should see "Deleted file"
    And I should not have package archive for "Module 1"

  @javascript
  Scenario: Delete project module directories
    Given I have project module "Module 1"
    And I am on upload data files page for Module 1
    And I create project module directories
      | dir   | child_dir |
      | data  | test1     |
      | test1 | test2     |
      | data  | test4     |
      | data  | test5     |
      | test5 | test6     |
      | test6 | test7     |
    And I have package archive for "Module 1"
    And I should have package archive for "Module 1"
    And I delete project module directories
      | dir   | child_dir |
      | data  | test1     |
      | data  | test4     |
      | test5 | test6     |
    Then I should see project module directories
      | dir  | child_dir |
      | data | test5     |
    Then I should not see project module directories
      | dir   | child_dir |
      | data  | test1     |
      | data  | test4     |
      | test5 | test6     |
    And I should see "Deleted directory"
    And I should not have package archive for "Module 1"

  @javascript
  Scenario: Delete root directory
    Given I have project module "Module 1"
    And I am on upload data files page for Module 1
    And I create project module directories
      | dir   | child_dir |
      | data  | test1     |
      | test1 | test2     |
      | data  | test4     |
      | data  | test5     |
      | test5 | test6     |
      | test6 | test7     |
    And I have package archive for "Module 1"
    And I should have package archive for "Module 1"
    And I delete root directory
    Then I should not see project module directories
      | dir  | child_dir |
      | data | test1     |
      | data | test4     |
      | data | test5     |
    And I should see "Deleted directory"
    And I should not have package archive for "Module 1"

  @javascript
  Scenario: Can delete dir if files in directory
    Given I have project module "Module 1"
    And I am on upload data files page for Module 1
    And I create project module directories
      | dir  | child_dir |
      | data | test1     |
    And I upload project module files
      | dir   | file          |
      | test1 | file2.sqlite3 |
    And I have package archive for "Module 1"
    And I should have package archive for "Module 1"
    And I delete project module directories
      | dir  | child_dir |
      | data | test1     |
    Then I should not see project module files for "Module 1"
      | dir   | file          | full_dir         |
      | test1 | file2.sqlite3 | files/data/test1 |
    Then I should not see project module directories
      | dir  | child_dir |
      | data | test1     |
    And I should see "Deleted directory"
    And I should not have package archive for "Module 1"

  @javascript
  Scenario: Cannot add project module file if file already exists
    Given I have project module "Module 1"
    And I am on upload data files page for Module 1
    And I upload project module files
      | dir  | file         |
      | data | file1.tar.gz |
      | data | file1.tar.gz |
    Then I should see project module files for "Module 1"
      | dir  | file         | full_dir   |
      | data | file1.tar.gz | files/data |
    And I should see "File already exists"

  @javascript
  Scenario: Cannot add project module file if files locked
    Given I have project module "Module 1"
    And I am on upload data files page for Module 1
    And data files are locked for "Module 1"
    And I upload project module files
      | dir  | file         |
      | data | file1.tar.gz |
    Then I should not see project module files for "Module 1"
      | dir  | file         | full_dir   |
      | data | file1.tar.gz | files/data |
    And I should see "Could not process request as project is currently locked"

  @javascript
  Scenario: Cannot add directory if directory already exists
    Given I have project module "Module 1"
    And I am on upload data files page for Module 1
    And I create project module directories
      | dir  | child_dir |
      | data | test1     |
      | data | test1     |
    Then I should see project module directories
      | dir  | child_dir |
      | data | test1     |
    And I should see "Directory already exists"

  @javascript
  Scenario: Cannot add directory if directory if files are locked
    Given I have project module "Module 1"
    And I am on upload data files page for Module 1
    And data files are locked for "Module 1"
    And I create project module directories
      | dir  | child_dir |
      | data | test1     |
    Then I should not see project module directories
      | dir  | child_dir |
      | data | test1     |
    And I should see "Could not process request as project is currently locked"

  @javascript
  Scenario: Cannot delete file if files are locked
    Given I have project module "Module 1"
    And I am on upload data files page for Module 1
    And I upload project module files
      | dir  | file         |
      | data | file1.tar.gz |
    And data files are locked for "Module 1"
    And I delete project module files
      | dir  | file         |
      | data | file1.tar.gz |
    Then I should see project module files for "Module 1"
      | dir  | file         | full_dir   |
      | data | file1.tar.gz | files/data |
    And I should see "Could not process request as project is currently locked"

  @javascript
  Scenario: Cannot delete directory if files are locked
    Given I have project module "Module 1"
    And I am on upload data files page for Module 1
    And I create project module directories
      | dir  | child_dir |
      | data | test1     |
    And data files are locked for "Module 1"
    And I delete project module directories
      | dir  | child_dir |
      | data | test1     |
    Then I should see project module directories
      | dir  | child_dir |
      | data | test1     |
    And I should see "Could not process request as project is currently locked"

  Scenario: I upload batch file
    Given I have project module "Module 1"
    And I am on upload data files page for Module 1
    And I pick file "batch.tar.gz" for "project_module_file"
    And I press "Upload"
    And I should see project module files for "Module 1"
      | dir   | file  | full_dir         |
      | test1 | test3 | files/data/test1 |
      | data  | test2 | files/data       |

  Scenario: Cannot upload batch file if archive is invalid
    Given I have project module "Module 1"
    And I am on upload data files page for Module 1
    And I pick file "file3.txt" for "project_module_file"
    And I press "Upload"
    And I should see "Could not upload file. Please ensure file is a valid archive."
    Then I should not see project module files for "Module 1"
      | dir   | file  | full_dir         |
      | test1 | test3 | files/data/test1 |
      | data  | test2 | files/data       |

  Scenario: Cannot upload batch file if files are locked
    Given I have project module "Module 1"
    And I am on upload data files page for Module 1
    And data files are locked for "Module 1"
    And I pick file "batch.tar.gz" for "project_module_file"
    And I press "Upload"
    And I should see "Could not process request as project is currently locked"
    Then I should not see project module files for "Module 1"
      | dir   | file  | full_dir         |
      | test1 | test3 | files/data/test1 |
      | data  | test2 | files/data       |




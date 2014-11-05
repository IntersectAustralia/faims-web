Feature: Manage exporters
  In order to export the module i need to be able to install, run and uninstall exporters

  Background:
    And I have role "superuser"
    And I have a user "faimsadmin@intersect.org.au" with role "superuser"
    And I am logged in as "faimsadmin@intersect.org.au"
    And I have a project modules dir
    And I have a project exporters dir
    Given I have users
      | first_name | last_name | email                  |
      | User1      | Last1     | user1@intersect.org.au |

  Scenario: List exporters
    Given I have project exporters
      | name       |
      | Exporter 1 |
      | Exporter 2 |
      | Exporter 3 |
    And I am on the project exporters page
    Then I should see project exporters
      | name       |
      | Exporter 1 |
      | Exporter 2 |
      | Exporter 3 |

  Scenario: List exporters with update
    Given I am on the the upload project exporters page
    And I upload exporter "exporter_with_interface.tar.gz"
    And I am on the the upload project exporters page
    And I upload exporter "exporter_with_repo.tar.gz"
    And I am on the project exporters page
    Then I should see project exporters
      | name           |
      | Interface Test |
      | Update Test    |
    And I should not see "Update" button for exporter "Interface Test"
    And I should see "Update" button for exporter "Update Test"

  Scenario: Cannot list exporters if not admin
    Given I logout
    And I am logged in as "user1@intersect.org.au"
    And I am on the project exporters page
    Then I should see "You are not authorized to access this page."

  Scenario: Install exporter
    Given I am on the project exporters page
    And I follow "Upload Exporter"
    And I upload exporter with
      | name       |
      | Exporter 1 |
    Then I should see "Exporter installed."
    And I should be on the project exporters page
    And I should see project exporters
      | name       |
      | Exporter 1 |

  Scenario: Update exporter
    Given I am on the the upload project exporters page
    And I upload exporter "exporter_with_repo.tar.gz"
    And I am on the project exporters page
    And I fake updating exporter
    And I press "Update" for exporter "Update Test"
    Then I should see "Exporter updated."

  Scenario: Upgrade exporter
    Given I am on the project exporters page
    And I follow "Upload Exporter"
    And I upload exporter with
      | name       | version | key        |
      | Exporter 1 | 1       | 1234567890 |
    Then I should see "Exporter installed."
    And I should be on the project exporters page
    And I should see project exporters
      | name       | version |
      | Exporter 1 | 1       |
    And I follow "Upload Exporter"
    And I upload exporter with
      | name       | version | key        |
      | Exporter 1 | 2       | 1234567890 |
    Then I should see "Exporter installed."
    And I should be on the project exporters page
    And I should see project exporters
      | name       | version |
      | Exporter 1 | 2       |

  Scenario: Cannot install exporter if not admin
    Given I logout
    And I am logged in as "user1@intersect.org.au"
    Given I am on the upload project exporters page
    Then I should see "You are not authorized to access this page."

  Scenario Outline: Cannot install exporter due to corrupt tarball
    Given I am on the project exporters page
    And I follow "Upload Exporter"
    And I upload exporter "<file>"
    Then I should see "<error>"
  Examples:
    | file         | error                            |
    | db.sqlite3   | Cannot extract archive           |
    | empty.tar.gz | Cannot find directory in archive |

  Scenario Outline: Cannot install exporter due to missing files
    Given I am on the project exporters page
    And I follow "Upload Exporter"
    And I upload exporter "Exporter 1" without "<file>"
    Then I should see "Please correct the errors in the exporter."
    And I should see "<error>"
  Examples:
    | file             | error                        |
    | skip_config      | Cannot find config           |
    | skip_installer   | Cannot find install script   |
    | skip_uninstaller | Cannot find uninstall script |
    | skip_exporter    | Cannot find export script    |

  Scenario Outline: Cannot install exporter due to config errors
    Given I am on the project exporters page
    And I follow "Upload Exporter"
    And I upload exporter "Exporter 1" setting "<setting>" as "<value>"
    Then I should see "Please correct the errors in the exporter."
    And I should see "<error>"
  Examples:
    | setting | value | error                              |
    | name    |       | Config is missing exporter name    |
    | version |       | Config is missing exporter version |
    | key     |       | Config is missing exporter key     |

  Scenario: Cannot install exporter due to installer fail
    Given I am on the project exporters page
    And I follow "Upload Exporter"
    And I upload exporter with
      | name       | install_script  |
      | Exporter 1 | install_fail.sh |
    Then I should see "Exporter failed to install. Please correct the errors in the install script."

  Scenario: Cannot install exporter if exporter already exists
    Given I am on the project exporters page
    And I follow "Upload Exporter"
    And I upload exporter with
      | name       | version | key        |
      | Exporter 1 | 1       | 1234567890 |
    Then I should see "Exporter installed."
    And I should be on the project exporters page
    And I should see project exporters
      | name       | version |
      | Exporter 1 | 1       |
    And I follow "Upload Exporter"
    And I upload exporter with
      | name       | version | key        |
      | Exporter 1 | 1       | 1234567890 |
    Then I should see "Exporter 'Exporter 1' already exists with version '1'"

  Scenario: Uninstall exporter
    Given I am on the project exporters page
    And I follow "Upload Exporter"
    And I upload exporter with
      | name       |
      | Exporter 1 |
    And I follow "Upload Exporter"
    And I upload exporter with
      | name       |
      | Exporter 2 |
    And I should see project exporters
      | name       |
      | Exporter 1 |
      | Exporter 2 |
    And I press "Uninstall" for exporter "Exporter 2"
    Then I should see "Exporter uninstalled."
    And I should see project exporters
      | name       |
      | Exporter 1 |

  Scenario: Cannot uninstall exporter due to uninstaller fail
    Given I am on the project exporters page
    And I follow "Upload Exporter"
    And I upload exporter with
      | name       | uninstall_script  |
      | Exporter 1 | uninstall_fail.sh |
    And I follow "Upload Exporter"
    And I upload exporter with
      | name       | uninstall_script  |
      | Exporter 2 | uninstall_fail.sh |
    And I should see project exporters
      | name       |
      | Exporter 1 |
      | Exporter 2 |
    And I press "Uninstall" for exporter "Exporter 2"
    Then I should see "Exporter failed to uninstall. Please correct the errors in the uninstall script."

  Scenario: Cannot uninstall if not admin
    Given I logout
    And I am logged in as "user1@intersect.org.au"
    Given I am on the project exporters page
    Then I should see "You are not authorized to access this page."


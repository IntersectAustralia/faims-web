Feature: Manage users
  In order to allow users to access the system
  As an administrator
  I want to manage users

  Background:
    Given I am the admin
      | first_name | last_name | email                     |
      | Georgina   | Edwards   | georgina@intersect.org.au |
    And I am logged in as "georgina@intersect.org.au"

  Scenario: View users list
    Given I have users
      | first_name | last_name | email                  |
      | User1      | Last1     | user1@intersect.org.au |
      | User2      | Last2     | user2@intersect.org.au |
    And I follow "Show Users"
    Then I should see users
      | first_name | last_name | email                  |
      | User1      | Last1     | user1@intersect.org.au |
      | User2      | Last2     | user2@intersect.org.au |

  Scenario: Add new user
    Given I have users
      | first_name | last_name | email                  |
      | User1      | Last1     | user1@intersect.org.au |
      | User2      | Last2     | user2@intersect.org.au |
    And I follow "Show Users"
    And I follow "Add User"
    And I fill in "First Name" with "User3"
    And I fill in "Last Name" with "Last3"
    And I fill in "Email" with "user3@intersect.org.au"
    And I fill in "Password" with "Pass.123"
    And I fill in "Password Confirmation" with "Pass.123"
    And I press "Submit"
    Then I should see users
      | first_name | last_name | email                  |
      | User1      | Last1     | user1@intersect.org.au |
      | User2      | Last2     | user2@intersect.org.au |
      | User3      | Last3     | user3@intersect.org.au |

  Scenario Outline: Add new user has errors
    Given I have users
      | first_name | last_name | email                  |
      | User1      | Last1     | user1@intersect.org.au |
      | User2      | Last2     | user2@intersect.org.au |
    And I follow "Show Users"
    And I follow "Add User"
    And I wait
    And I fill in "<field>" with "<value>"
    And I press "Submit"
    Then I should see "<field>" with error "<error>"
  Examples:
    | field      | value                  | error                  |
    | First Name |                        | can't be blank         |
    | Last Name  |                        | can't be blank         |
    | Email      |                        | can't be blank         |
    | Email      | user1@intersect.org.au | has already been taken |
    | Email      | user1                  | is invalid             |
    | Password   |                        | can't be blank         |

  Scenario Outline: Add new user has password errors
    Given I have users
      | first_name | last_name | email                  |
      | User1      | Last1     | user1@intersect.org.au |
      | User2      | Last2     | user2@intersect.org.au |
    And I follow "Show Users"
    And I follow "Add User"
    And I wait
    And I fill in "<field1>" with "<value1>"
    And I fill in "<field2>" with "<value2>"
    And I press "Submit"
    Then I should see "<field1>" with error "<error>"
  Examples:
    | field1    | field2                | value1   | value2   | error                                                                                                                              |
    | Password | Password Confirmation | dd       |          | doesn't match confirmation                                                                                                         |
    | Password | Password Confirmation | dd       | dd       | is too short (minimum is 6 characters)                                                                                             |
    | Password | Password Confirmation | dddddddd | dddddddd | must be between 6 and 20 characters long and contain at least one uppercase letter, one lowercase letter, one digit and one symbol |

  Scenario: Delete user
    Given I have users
      | first_name | last_name | email                  |
      | User1      | Last1     | user1@intersect.org.au |
      | User2      | Last2     | user2@intersect.org.au |
    And I follow "Show Users"
    And I delete user "user2@intersect.org.au"
    Then I should see users
      | first_name | last_name | email                  |
      | User1      | Last1     | user1@intersect.org.au |

  Scenario: Cannot delete current user
    Given I follow "Show Users"
    And I cannot delete user "georgina@intersect.org.au"

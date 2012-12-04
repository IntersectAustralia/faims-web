Feature: Logging In
  In order to use the system
  As a user
  I want to login

  Background:
    Given I have roles
      | name       |
      | superuser  |
      | Researcher |
    And I have permissions
      | entity | action          | roles     |
      | User   | read            | superuser |
      | User   | admin           | superuser |
      | User   | access_requests | superuser |
    And I have a user "georgina@intersect.org.au"
    And "georgina@intersect.org.au" has role "superuser"

  Scenario: Successful login
    Given I am on the login page
    When I fill in "Email" with "georgina@intersect.org.au"
    And I fill in "Password" with "Pas$w0rd"
    And I press "Log in"
    Then I should see "Logged in successfully."
    And I should be on the home page

  Scenario: Successful login from home page
    Given I am on the home page
    When I fill in "Email" with "georgina@intersect.org.au"
    And I fill in "Password" with "Pas$w0rd"
    And I press "Log in"
    Then I should see "Logged in successfully."
    And I should be on the home page

  Scenario: Should be redirected to the login page when trying to access a secure page
    Given I am on the list users page
    Then I should see "You need to log in before continuing."
    And I should be on the login page

  Scenario: Should be redirected to requested page after logging in following a redirect from a secure page
    Given I am on the list users page
    When I fill in "Email" with "georgina@intersect.org.au"
    And I fill in "Password" with "Pas$w0rd"
    And I press "Log in"
    Then I should see "Logged in successfully."
    And I should be on the list users page

  Scenario Outline: Failed logins due to missing/invalid details
    Given I am on the login page
    When I fill in "Email" with "<email>"
    And I fill in "Password" with "<password>"
    And I press "Log in"
    Then I should see "Invalid email or password."
    And I should be on the login page
  Examples:
    | email                     | password         | explanation    |
    |                           |                  | nothing        |
    |                           | Pas$w0rd         | missing email  |
    | georgina@intersect.org.au |                  | missing password |
    | fred@intersect.org.au     | Pas$w0rd         | invalid email  |
    | georgina@intersect.org.au | blah             | wrong password |

  Scenario Outline: Logging in as a deactivated / pending approval / rejected as spam with correct password
    Given I have a deactivated user "deact@intersect.org.au"
    And I have a rejected as spam user "spammer@intersect.org.au"
    And I have a pending approval user "pending@intersect.org.au"
    And I am on the login page
    When I fill in "Email" with "<email>"
    And I fill in "Password" with "<password>"
    And I press "Log in"
    Then I should see "Your account is not active."
  Examples:
    | email                    | password |
    | deact@intersect.org.au   | Pas$w0rd |
    | spammer@intersect.org.au | Pas$w0rd |
    | pending@intersect.org.au | Pas$w0rd |

  Scenario Outline: Logging in as a deactivated / pending approval / rejected as spam / with incorrect password should not reveal if user exists
    Given I have a deactivated user "deact@intersect.org.au"
    And I have a rejected as spam user "spammer@intersect.org.au"
    And I have a pending approval user "pending@intersect.org.au"
    And I am on the login page
    When I fill in "Email" with "<email>"
    And I fill in "Password" with "<password>"
    And I press "Log in"
    Then I should see "Invalid email or password."
    And I should not see "Your account is not active."
  Examples:
    | email                    | password |
    | deact@intersect.org.au   | pa       |
    | spammer@intersect.org.au | pa       |
    | pending@intersect.org.au | pa       |

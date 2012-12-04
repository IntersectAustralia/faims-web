Feature: Request an account
  In order to use the system
  As a user
  I want to request an account

  Background:
    Given I have no users
    Given I have the usual roles and permissions
    And I have a user "diego.alonso@intersect.org.au" with role "superuser"

  Scenario: Request account
    Given I am on the request account page
    When I fill in the following:
      | Email            | georgina@intersect.org.au |
      | Password         | paS$w0rd                  |
      | Confirm Password | paS$w0rd                  |
      | First Name       | Fred                      |
      | Last Name        | Bloggs                    |
    And I press "Submit Request"
    Then I should see "Thanks for requesting an account. You will receive an email when your request has been approved."
    And I should not see "Your account is not active"
    And I should be on the home page
    And I should see "Please enter your email and password to log in"

  Scenario: Email to superuser upon account request and clicking through to access requests page
    Given I am on the request account page
    When I fill in the following:
      | Email            | georgina@intersect.org.au |
      | Password         | paS$w0rd                  |
      | Confirm Password | paS$w0rd                  |
      | First Name       | Fred                      |
      | Last Name        | Bloggs                    |
    And I press "Submit Request"
    Then "diego.alonso@intersect.org.au" should receive an email with subject "faims - There has been a new access request"
    When they open the email
    Then they should see "An access request has been made with the following details:" in the email body
    And they should see "Email: georgina@intersect.org.au" in the email body
    And they should see "First name: Fred" in the email body
    And they should see "Last name: Bloggs" in the email body
    And they should see "You can view unapproved access requests here" in the email body
    When they click the first link in the email
    Then I should be on the login page
    And I fill in "Email" with "diego.alonso@intersect.org.au"
    And I fill in "Password" with "Pas$w0rd"
    And I press "Log in"
    Then I should be on the access requests page
    And I should see "access_requests" table with
      | First name | Last name | Email                     |
      | Fred       | Bloggs    | georgina@intersect.org.au |

  Scenario: Requesting an account with mismatched password confirmation should be rejected
    Given I am on the request account page
    When I fill in the following:
      | Email            | georgina@intersect.org.au |
      | Password         | paS$w0rd                  |
      | Confirm Password | pa                        |
      | First Name       | Fred                      |
      | Last Name        | Bloggs                    |
    And I press "Submit Request"
    And the "Password" field should have the error "doesn't match confirmation"
    And the "First Name" field should have no errors
    And the "Last Name" field should have no errors
    And the "Email" field should have no errors

  Scenario: Password fields should be cleared out on validation error
    Given I am on the request account page
    When I fill in the following:
      | Email            | georgina@intersect.org.au |
      | Password         | paS$w0rd                  |
      | Confirm Password | paS$w0rd                  |
    And I press "Submit Request"
    And the "First Name" field should have the error "can't be blank"
    And the "Last Name" field should have the error "can't be blank"
    And the "Password" field should contain ""
    And the "Confirm Password" field should contain ""

  Scenario: Newly requested account should not be able to log in yet
    Given I am on the request account page
    And I fill in the following:
      | Email            | georgina@intersect.org.au |
      | Password         | paS$w0rd                  |
      | Confirm Password | paS$w0rd                  |
      | First Name       | Fred                      |
      | Last Name        | Bloggs                    |
    And I press "Submit Request"
    And I am on the login page
    When I fill in "Email" with "georgina@intersect.org.au"
    And I fill in "Password" with "paS$w0rd"
    And I press "Log in"
    Then I should see "Your account is not active."
    And I should be on the login page

  Scenario: Deactivated supers shouldn't get the email
    Given I have a user "fred@intersect.org.au" with role "superuser"
    And "fred@intersect.org.au" is deactivated
    And I am on the request account page
    When I fill in the following:
      | Email            | georgina@intersect.org.au |
      | Password         | paS$w0rd                  |
      | Confirm Password | paS$w0rd                  |
      | First Name       | Fred                      |
      | Last Name        | Bloggs                    |
    And I press "Submit Request"
    Then "diego.alonso@intersect.org.au" should receive an email with subject "faims - There has been a new access request"
    Then "fred@intersect.org.au" should receive no emails

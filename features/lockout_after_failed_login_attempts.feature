Feature: Locking out users after multiple failed password attempts
  In order prevent brute-force password guessing attacks
  As the system owner
  I want users to be locked out after 3 failed attempts

  Background:
    Given I have the usual roles and permissions
    And I have a user "georgina@intersect.org.au" with role "superuser"

  Scenario: 3 consecutive no longer locks account
    When I attempt to login with "georgina@intersect.org.au" and "blah"
    Then I should see "Invalid email or password."
    And I should be on the login page
    When I attempt to login with "georgina@intersect.org.au" and "blah"
    Then I should see "Invalid email or password."
    And I should be on the login page
    When I attempt to login with "georgina@intersect.org.au" and "blah"
    Then I should see "Invalid email or password."

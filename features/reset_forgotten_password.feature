Feature: Reset forgotten password
  In order to access the system
  As a user
  I want to be able to reset my password if I forgot it

  Background:
    Given a clear email queue

  Scenario: Reset forgotten password
    Given I have a user "georgina@intersect.org.au"
    And I am on the home page
    When I follow "Forgot your password?"
    Then I should see "Contact your administrator for a new password"
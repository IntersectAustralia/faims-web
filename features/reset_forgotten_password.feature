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
    And I fill in "Email" with "georgina@intersect.org.au"
    And I press "Send me reset password instructions"
    Then I should see "If the email address you entered was valid, you will receive an email with instructions about how to reset your password in a few minutes."
    And I should be on the login page
    And "georgina@intersect.org.au" should receive an email
    When I open the email
    Then I should see "Someone has requested a link to change your password on the faims site, and you can do this through the link below." in the email body
    When I follow "Change my password" in the email
    Then I should see "Change Your Password"
    When I fill in "Password" with "Pass.456"
    And I fill in "Confirm Password" with "Pass.456"
    And I press "Change Your Password"
    Then I should see "Your password was changed successfully. You are now signed in."
    And I should be able to log in with "georgina@intersect.org.au" and "Pass.456"
    
  Scenario: Deactivated user gets an email saying they can't reset their password
    Given I have a deactivated user "deac@intersect.org.au"
    When I request a reset for "deac@intersect.org.au"
    Then I should see "If the email address you entered was valid, you will receive an email with instructions about how to reset your password in a few minutes."
    And I should be on the login page
    And "deac@intersect.org.au" should receive an email
    When I open the email
    Then I should see "Someone has requested a link to change your password on the faims site. However your account is not active so you cannot reset your password." in the email body

  Scenario: Pending approval user gets an email saying they can't reset their password
    Given I have a pending approval user "pa@intersect.org.au"
    When I request a reset for "pa@intersect.org.au"
    Then I should see "If the email address you entered was valid, you will receive an email with instructions about how to reset your password in a few minutes."
    And I should be on the login page
    And "pa@intersect.org.au" should receive an email
    When I open the email
    Then I should see "Someone has requested a link to change your password on the faims site. However your account is not active so you cannot reset your password." in the email body

  Scenario: Rejected as spam user trying to request a reset just sees default message but doesn't get email (so we don't reveal which users exist)
    Given I have a rejected as spam user "spam@intersect.org.au"
    When I request a reset for "spam@intersect.org.au"
    Then I should see "If the email address you entered was valid, you will receive an email with instructions about how to reset your password in a few minutes."
    And I should be on the login page
    But "spam@intersect.org.au" should receive no emails

  Scenario: Non existent user trying to request a reset just sees default message but doesn't get email (so we don't reveal which users exist)
    Given I am on the home page
    When I request a reset for "noexist@intersect.org.au"
    Then I should see "If the email address you entered was valid, you will receive an email with instructions about how to reset your password in a few minutes."
    And I should be on the login page
    But "noexist@intersect.org.au" should receive no emails

  Scenario: Non existent user trying to request a reset just sees default message but doesn't get email (so we don't reveal which users exist)
    Given I am on the home page
    When I request a reset for "noexist@intersect.org.au"
    Then I should see "If the email address you entered was valid, you will receive an email with instructions about how to reset your password in a few minutes."
    And I should be on the login page
    But "noexist@intersect.org.au" should receive no emails

  Scenario: Error displayed if email left blank
    Given I am on the home page
    When I request a reset for ""
    Then I should see "Email can't be blank"
    And I should see "Forgot Your Password?"

   Scenario: New password and confirmation must match
     Given I have a user "georgina@intersect.org.au"
     When I request a reset for "georgina@intersect.org.au"
     And "georgina@intersect.org.au" should receive an email
     And I open the email
     And I follow "Change my password" in the email
     And I fill in "Password" with "Pass.456"
     And I fill in "Confirm Password" with "Pass.123"
     And I press "Change Your Password"
     Then I should see "Password doesn't match confirmation"

   Scenario: New password must meet minimum requirements
     Given I have a user "georgina@intersect.org.au"
     When I request a reset for "georgina@intersect.org.au"
     And "georgina@intersect.org.au" should receive an email
     And I open the email
     And I follow "Change my password" in the email
     And I fill in "Password" with "Pass"
     And I fill in "Confirm Password" with "Pass"
     And I press "Change Your Password"
     Then I should see "Password must be between 6 and 20 characters long and contain at least one uppercase letter, one lowercase letter, one digit and one symbol"

  Scenario: Link in email should only work once
    Given I have a user "georgina@intersect.org.au"
    When I request a reset for "georgina@intersect.org.au"
    And "georgina@intersect.org.au" should receive an email
    And I open the email
    And I follow "Change my password" in the email
    And I fill in "Password" with "Pass.456"
    And I fill in "Confirm Password" with "Pass.456"
    And I press "Change Your Password"
    Then I should see "Your password was changed successfully. You are now signed in."
    When I follow "Logout"
    And I open the email
    And I follow "Change my password" in the email
    And I fill in "Password" with "Pass.000"
    And I fill in "Confirm Password" with "Pass.000"
    And I press "Change Your Password"
    Then I should see "Reset password token is invalid"
    And I should be able to log in with "georgina@intersect.org.au" and "Pass.456"

  Scenario: Can't go to get new password page without the token in the email
    Given I have a user "georgina@intersect.org.au"
    When I go to the reset password page
    Then I should see "You canoot access this page without coming from a password reset email. If you do come from a password reset email, please make sure you used the full URL provided."

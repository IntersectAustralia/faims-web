Feature: Approve access requests
  In order to allow users to access the system
  As an administrator
  I want to approve access requests

  Background:
    Given I have roles
      | name       |
      | superuser  |
      | Researcher |
    And I have permissions
      | entity | action          | roles  |
      | User   | read            | superuser |
      | User   | admin           | superuser |
      | User   | reject          | superuser |
      | User   | approve         | superuser |
    And I have a user "georgina@intersect.org.au" with role "superuser"
    And I have access requests
      | email                  | first_name | last_name        |
      | ryan@intersect.org.au  | Ryan       | Braganza         |
      | diego@intersect.org.au | Diego      | Alonso de Marcos |
    And I am logged in as "georgina@intersect.org.au"

  Scenario: View a list of access requests
    Given I am on the access requests page
    Then I should see "access_requests" table with
      | First name | Last name        | Email                  |
      | Diego      | Alonso de Marcos | diego@intersect.org.au |
      | Ryan       | Braganza         | ryan@intersect.org.au  |

  Scenario: Approve an access request from the list page
    Given I am on the access requests page
    When I follow "Approve" for "diego@intersect.org.au"
    And I select "superuser" from "Role"
    And I press "Approve"
    Then I should see "The access request for diego@intersect.org.au was approved."
    And I should see "access_requests" table with
      | First name | Last name | Email                 |
      | Ryan       | Braganza  | ryan@intersect.org.au |
    And "diego@intersect.org.au" should receive an email with subject "faims - Your access request has been approved"
    When they open the email
    Then they should see "You made a request for access to the faims System. Your request has been approved. Please visit" in the email body
    And they should see "Hello Diego Alonso de Marcos," in the email body
    When they click the first link in the email
    Then I should be on the home page

  Scenario: Cancel out of approving an access request from the list page
    Given I am on the access requests page
    When I follow "Approve" for "diego@intersect.org.au"
    And I select "superuser" from "Role"
    And I follow "Back"
    Then I should be on the access requests page
    And I should see "access_requests" table with
      | First name | Last name        | Email                  |
      | Diego      | Alonso de Marcos | diego@intersect.org.au |
      | Ryan       | Braganza         | ryan@intersect.org.au  |

  Scenario: View details of an access request
    Given I am on the access requests page
    When I follow "View Details" for "diego@intersect.org.au"
    Then I should see "diego@intersect.org.au"
    Then I should see field "Email" with value "diego@intersect.org.au"
    Then I should see field "First name" with value "Diego"
    Then I should see field "Last name" with value "Alonso de Marcos"
    Then I should see field "Role" with value ""
    Then I should see field "Status" with value "Pending Approval"

  Scenario: Approve an access request from the view details page
    Given I am on the access requests page
    When I follow "View Details" for "diego@intersect.org.au"
    And I follow "Approve"
    And I select "superuser" from "Role"
    And I press "Approve"
    Then I should see "The access request for diego@intersect.org.au was approved."
    And I should see "access_requests" table with
      | First name | Last name | Email                 |
      | Ryan       | Braganza  | ryan@intersect.org.au |

  Scenario: Cancel out of approving an access request from the view details page
    Given I am on the access requests page
    When I follow "View Details" for "diego@intersect.org.au"
    And I follow "Approve"
    And I select "superuser" from "Role"
    And I follow "Back"
    Then I should be on the access requests page
    And I should see "access_requests" table with
      | First name | Last name        | Email                  |
      | Diego      | Alonso de Marcos | diego@intersect.org.au |
      | Ryan       | Braganza         | ryan@intersect.org.au  |

  Scenario: Go back to the access requests page from the view details page without doing anything
    Given I am on the access requests page
    And I follow "View Details" for "diego@intersect.org.au"
    When I follow "Back"
    Then I should be on the access requests page
    And I should see "access_requests" table with
      | First name | Last name        | Email                  |
      | Diego      | Alonso de Marcos | diego@intersect.org.au |
      | Ryan       | Braganza         | ryan@intersect.org.au  |

  Scenario: Role should be mandatory when approving an access request
    Given I am on the access requests page
    When I follow "Approve" for "diego@intersect.org.au"
    And I press "Approve"
    Then I should see "Please select a role for the user."

  Scenario: Approved user should be able to log in
    Given I am on the access requests page
    When I follow "Approve" for "diego@intersect.org.au"
    And I select "superuser" from "Role"
    And I press "Approve"
    And I am on the home page
    And I follow "Logout"
    Then I should be able to log in with "diego@intersect.org.au" and "Pas$w0rd"

  Scenario: Approved user roles should be correctly saved
    Given I am on the access requests page
    And I follow "Approve" for "diego@intersect.org.au"
    And I select "superuser" from "Role"
    And I press "Approve"
    And I am on the list users page
    When I follow "View Details" for "diego@intersect.org.au"
    And I should see field "Role" with value "superuser"

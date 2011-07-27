@atrium_exhibits

Feature: Exhibits
  In order to create a custom browse of a collection
  As as user
  I want to create and configure an exhibit

  Scenario: Listing Exhibits if none exist yet
    Given I am on the base search page
    I should see a "p" element containing "No exhibits have been created yet.  Click the button below to start creating an exhibit."
    And I should see a "Create a new Exhibit" button
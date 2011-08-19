@atrium_exhibits

Feature: Exhibits
  In order to create a custom browse of a collection
  As as user
  I want to create and configure an exhibit

  Scenario: Listing exhibits in home page
    Given I am on the home page
    Then I should see "Browse Current Exhibits"
    And I should see "No exhibits found."

  Scenario: Editor views the search results page and sees the add exhibit button
    Given I am logged in as "archivist1"
    Given I am on the home page
    Then I should see a "Create New Exhibit" button

  Scenario: Adding an Exhibit
    Given I am logged in as "archivist1"
    Given I am on the home page
    When I press "Create New Exhibit"
    Then I should be on the new exhibit page
    And I should see a "label" element containing "Title:"
    And I should see "" within  "#atrium_exhibit_title"
    And I should see a "label" element containing "Exhibit Scope Query:"
    And I should see "" within "#atrium_exhibit_solr_filter_query"
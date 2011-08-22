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
    #should see show and back to search links at top and bottom
    And I should not see "Show"
    And I should see "Back to Search"
    And I should see a "label" element containing "Title:"
    And I should see "" within  "#atrium_exhibit_title"
    And I should see a "label" element containing "Exhibit Scope Query:"
    And I should see "" within "#atrium_exhibit_solr_filter_query"
    #browse level edit section
    #search facet edit section
    And I should see "Back to Search"
    When I fill in "atrium_exhibit_title" with "My Test Title"
    And I fill in "atrium_exhibit_solr_filter_query" with "id:test"
    And I press "Update"
    Then I should be on the edit exhibit page
    And I should see "Exhibit created successfully."
    #after save then the show links should show up
    And I should see "Show"
    And I should see "Back to Search"
    And I should see "My Test Title" within  "#atrium_exhibit_title"
    And I should see "id:test" within "#atrium_exhibit_solr_filter_query"
    
    
    
    
  Scenario: Adding a Browse Level to new exhibit
  Scenario: Adding a Browse Level to existing exhibit
  Scenario: Editing a Browse Level in an exhibit
  Scenario: Adding another Browse Level to an exhibit
  Scenario: Removing a Browse Level from an exhibit
  Scenario: Adding a Search Facet to a new exhibit
  Scenario: Adding a Search Facet to existing exhibit
  Scenario: Removing a Search Facet from an exhibit
  Scenario: Follow Show Exhibit Link from Exhibit Edit Page
    
  Scenario: Follow Back Link from Exhibit Edit Page
  Scenario: Delete Exhibit
  
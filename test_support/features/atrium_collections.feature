@atrium_collections

Feature: Collections
  In order to create a custom browse of a collection
  As as user
  I want to create and configure an collection

  Scenario: Listing collections in home page
    Given I am logged in as "test"
    Given I am on the home page
    Then I should see "Collections"
    And I should see "No collections found."

  Scenario: Editor views the search results page and sees the add collection button
    Given I am logged in as "test"
    Given I am on the home page
    Then I should see a "Create New Collection" button

  Scenario: Adding an Collection
    Given I am logged in as "test"
    Given I am on the home page
    When I press "Create New Collection"
    Then I should be on the configure collection page
    #should see show and back to search links at top and bottom
    And I should not see "Show"
    And I should see "Back to Search"
    And I should see a "label" element containing "Title:"
    And I should see "" within  "#atrium_collection_title"
    And I should see a "label" element containing "Collection Scope Query:"
    And I should see "" within "#atrium_collection_solr_filter_query"
    #browse level edit section
    #search facet edit section
    And I should see "Back to Search"
    When I fill in "atrium_collection_title" with "My Test Title"
    And I fill in "atrium_collection_solr_filter_query" with "id:test"
    And I press "Update"
    Then I should be on the configure collection page
    And I should see "Collection updated successfully."
    #after save then the show links should show up
    And I should see "Show"
    And I should see "Back to Search"
    And I should see "My Test Title" within  "#atrium_collection_title"
    And I should see "id:test" within "#atrium_collection_solr_filter_query"
    
  Scenario: Adding a Browse Set to an collection
  Scenario: Adding a Browse level to a browse set
  Scenario: Editing a Browse Level in a browse set
  Scenario: Adding another Browse Level to a browse set
  Scenario: Removing a Browse Level from a browse set
  Scenario: Remove a browse set
  Scenario: Add another browse set
  Scenario: Toggle between view on one browse set and another
  #Scenario: Adding a Search Facet to a new collection
  #Scenario: Adding a Search Facet to existing collection
  #Scenario: Removing a Search Facet from an collection
  #Scenario: Follow Show collection Link from Configure collection Page
    
  #Scenario: Follow Back Link from collection Edit Page
  Scenario: Delete Collection
  
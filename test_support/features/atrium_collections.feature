@atrium_collections

Feature: Collections
  In order to create a custom browse of a collection
  As as user
  I want to create and configure an collection

  Scenario: Listing collections in home page
    Given I am logged in as "test"
    Given I am on the home page
    Then I should see "No Collection defined"

  Scenario: Editor views the search results page and sees the add collection button
    Given I am logged in as "test"
    Given I am on the home page
    Then I should see a "Create New Collection" button

  Scenario: Adding an Collection
    Given I am logged in as "test"
    Given I am on the home page
    When I press "Create New Collection"
    Then I should be on the edit collection page for id 1
    And I should see a "h1" element containing "Editing Collection"

  Scenario: Configure a Collection
    Given I am logged in as "test"
    Given I am on the home page
    When I press "Create New Collection"
    And I am on the edit collection page for id 1
    And I fill in "atrium_collection_title" with "My Test Title"
    And I select "Language" from "atrium_collection_search_facet_names"
    And I press "Update Collection Configuration"
    Then I should see "My Test Title"
    And I should see select list "select#atrium_collection_search_facet_names" with "Language" selected

    
  Scenario: Adding a Scope to an collection
    Given I am logged in as "test"
    And I am on the home page
    And I press "Create New Collection"
    And I am on the edit collection page for id 1
    And I follow "Set Collection Scope"
    Then I should be on the catalog page
    And I should see a "div" tag with a "class" attribute of "ui-state-highlight"
    And I should see a "Set Collection Scope to Here" button

   Scenario: Adding a Scope to an collection
    Given I am logged in as "test"
    And I am on the home page
    And I press "Create New Collection"
    And I am on the edit collection page for id 1
    And I follow "Set Collection Scope"
    And I should see a "Set Collection Scope to Here" button
    And I follow "Book"
    And I press "Set Collection Scope to Here"
    Then I should be on the edit collection page for id 1
    And I should see a "li" element containing "formatBook"

  Scenario: Deleting Scope From collection
    Pending

  Scenario: Adding Exhibit to Collection
    Given I am logged in as "test"
    And I am on the home page
    And I press "Create New Collection"
    And I am on the edit collection page for id 1
    And I press "Add a Exhibit to this Collection"
    Then I should see "Exhibit 1"
    And I should see "Configure" link

  Scenario: Remove a Search Facet from existing collection
    pending

  Scenario: Follow Show collection Link from Configure collection Page
    Given I am logged in as "test"
    And I am on the home page
    And I press "Create New Collection"
    And I am on the edit collection page for id 1
    And I follow "View Collection"
    Then I am on the collection home page for id 1

  Scenario: Follow Back Link from collection Edit Page
    pending

  Scenario: Delete Collection
    Given I am logged in as "test"
    And I am on the home page
    And I press "Create New Collection"
    And I am on the edit collection page for id 1
    And I should see "Delete this Collection" link
  